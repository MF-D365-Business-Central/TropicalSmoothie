codeunit 60002 "MFCC01 Agreement Management"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Header", 'OnaferSignEvent', '', false, false)]
    local procedure TBL_60003_OnaferSignEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        ProcessOnSign(AgreementHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Header", 'OnaferOpenEvent', '', false, false)]
    local procedure TBL_60003_OnaferOpenEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        ProcessOnOpen(AgreementHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Renewal", 'OnaferReneweEvent', '', false, false)]
    local procedure TBL_60012_OnaferReneweEvent(var Renewal: Record "MFCC01 Agreement Renewal")
    begin
        ProcessRenewal(Renewal);
    end;

    procedure ProcessOnSign(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
    begin
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        SetPostingDate(AgreementHeader."Agreement Date");
        GLEntry.LockTable();
        IF AgreementHeader."Posted Agreement Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, AgreementHeader."Agreement Amount", true, AgreementHeader."Franchise Bank Account", 0, false) then Begin
                AgreementHeader."Posted Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Commission Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, BalAccountType::"G/L Account", CZSetup."Accrued Fran Bonus GAAP", AgreementHeader."SalesPerson Commission", false, '', 0, true) then Begin
                AgreementHeader."Posted Commission Amount" := AgreementHeader."SalesPerson Commission";
            End;

        IF AgreementHeader.PostedRevenueStatisticalAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.RevenueRecognized, '', -AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, '', -AgreementHeader."Agreement Amount" + AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then Begin
                    AgreementHeader.PostedRevenueStatisticalAmount := AgreementHeader.NonGapInitialRevenueRecognized;
                End;
        IF AgreementHeader.PostedCommissionExpenseAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.PrepaidCommisionLT, '', AgreementHeader."SalesPerson Commission", 0, true) then Begin
                AgreementHeader.PostedCommissionExpenseAmount := AgreementHeader."SalesPerson Commission";
            End;

        AgreementHeader.Modify(true);
    end;

    procedure ProcessOnOpen(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
    begin
        SetPostingDate(AgreementHeader."Franchise Revenue Start Date");
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        //IF Customer."Franchisee Status" <> Customer."Franchisee Status"::Operational then Begin

        GLEntry.LockTable();

        IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, BalAccountType::"G/L Account", CZSetup.DefRevenueCafesinOperationGAAP, AgreementHeader."Agreement Amount", false, '', 0, false) then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DefCommisionsinOperationsGAAP, BalAccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, AgreementHeader."SalesPerson Commission", false, '', 0, true) then
                IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, CZSetup.DefRevenueCafesinOperation, AgreementHeader."Agreement Amount" - AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                    IF PostStatsAmounts(AgreementHeader, CZSetup.DefRevenueCafesinOperation, CZSetup.RevenueRecognized, AgreementHeader."Agreement Amount" - AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                        IF PostStatsAmounts(AgreementHeader, CZSetup.DefCommisionsinOperations, CZSetup.PrepaidCommisionLT, AgreementHeader."SalesPerson Commission", 0, true) then
                            IF PostStatsAmounts(AgreementHeader, CZSetup.CommissionRecognized, CZSetup.DefCommisionsinOperations, AgreementHeader."SalesPerson Commission", 0, true) then Begin

                                Customer."Franchisee Status" := Customer."Franchisee Status"::Operational;
                                Customer."Franchisee Type" := Customer."Franchisee Type"::Active;
                                IF Customer."Opening Date" = 0D then
                                    Customer."Opening Date" := AgreementHeader."Agreement Date";
                                Customer.Modify();
                            End;

        DeferralUtility.CreatedeferralScheduleFromAgreement(AgreementHeader, true);
        //end;
    end;

    procedure ProcessCommission(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        //DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        ConfirmTxt: Label 'Do you want to Process commission.?';
        CompletedTxt: Label 'Commission Processed.';
    begin
        IF not Confirm(ConfirmTxt, false, true) then
            exit;
        //AgreementHeader.TestField(Status, AgreementHeader.status::Opened);
        SetPostingDate(AgreementHeader."Agreement Date");
        AgreementHeader.TestField(Status, AgreementHeader.Status::Signed);
        CZSetup.GetRecordonce();
        IF AgreementHeader."Posted Commission Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, BalAccountType::"G/L Account", CZSetup."Accrued Fran Bonus GAAP", AgreementHeader."SalesPerson Commission", false, '', 0, true) then Begin
                AgreementHeader."Posted Commission Amount" := AgreementHeader."SalesPerson Commission";
                AgreementHeader.Modify();
            End;

        IF AgreementHeader.PostedCommissionExpenseAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.PrepaidCommisionLT, '', AgreementHeader."SalesPerson Commission", 0, true) then Begin
                AgreementHeader.PostedCommissionExpenseAmount := AgreementHeader."SalesPerson Commission";
                AgreementHeader.Modify();
            End;
        //DeferralUtility.CreatedeferralScheduleFromAgreement(AgreementHeader);
        IF (AgreementHeader."Posted Commission Amount" <> 0) then
            Message(CompletedTxt);
    end;

    procedure ProcessRenewal(Var Renewal: Record "MFCC01 Agreement Renewal")
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        CounterRenewal: Record "MFCC01 Agreement Renewal";
    begin

        CZSetup.GetRecordonce();
        AgreementHeader.Get(Renewal."Agreement No.");
        CounterRenewal.SetRange("Agreement No.", Renewal."Agreement No.");
        SetPostingDate(Renewal."Renewal Date");
        //AgreementHeader."Agreement Date" := Renewal."Renewal Date";
        IF Renewal."Posted Renewal Fees" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", CZSetup."Deferred Renewal Fee GAAP", Renewal."Renewal Fees", true, AgreementHeader."Franchise Bank Account", CounterRenewal.Count, false) then
                IF PostStatsAmounts(AgreementHeader, '', CZSetup."Deferred Renewal Fee", Renewal."Renewal Fees", CounterRenewal.Count, false) then Begin
                    //IF PostStatsAmounts(AgreementHeader, CZSetup."Deferred Renewal Fee", CZSetup."Franchise Renewal Fee", Renewal."Renewal Fees", CounterRenewal.Count) then Begin
                    Renewal."Posted Renewal Fees" := Renewal."Renewal Fees";
                    Renewal.Modify();
                    AgreementHeader."License Type" := AgreementHeader."License Type"::Renewed;
                    AgreementHeader.Modify();
                    DeferralUtility.CreatedeferralScheduleFromRenewal(Renewal);
                end;
    end;

    local procedure PostAgreementAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
    BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal; Invoice: Boolean; BankAcc: Code[20]; counter: Integer; Commission: Boolean): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        IF Amount = 0 then
            Exit(True);
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        IF counter <> 0 then
            GenJnlLine."Document No." := AgreementHeader."No." + '/' + Format(counter)
        else
            GenJnlLine."Document No." := AgreementHeader."No.";
        If Invoice then
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine.Validate("Account Type", AccountType);
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine.Validate(Amount, Amount);
        //Customer Dimensions
        InitDefaultDimSource(DefaultDimSource, AgreementHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        IF Not Commission then
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Corp Department Code");
        GenJnlLine."Recipient Bank Account" := BankAcc;
        GenJnlLine."Agreement No." := AgreementHeader."No.";
        If Invoice then
            GenJnlLine.Description := 'Franchise Fee';
        IF counter <> 0 then
            GenJnlLine.Description := 'Renewal Franchise Fee';
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        IF counter <> 0 then
            GenJnlLine."Document No." := AgreementHeader."No." + '/' + Format(counter)
        else
            GenJnlLine."Document No." := AgreementHeader."No.";
        If Invoice then
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        //Posting to Customer Account
        GenJnlLine.Validate("Account Type", BalAccountType);
        GenJnlLine.Validate("Account No.", BalAccountNo);
        GenJnlLine.Validate(Amount, -Amount);
        //Customer Dimensions
        InitDefaultDimSource(DefaultDimSource, AgreementHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        IF Not Commission then
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Corp Department Code");
        GenJnlLine."Agreement No." := AgreementHeader."No.";
        Exit(GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0);
    end;

    local procedure PostStatsAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountNo: Code[20];
     BalAccountNo: Code[20]; Amount: Decimal; counter: Integer; Commission: Boolean): Boolean
    var
        StatisticalJnlLine: Record "Statistical Acc. Journal Line";
        StatAccJnlLinePost: Codeunit "Stat. Acc. Jnl. Line Post";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        IF Amount = 0 then
            Exit(True);
        IF AccountNo <> '' then Begin
            StatisticalJnlLine.Init();
            StatisticalJnlLine."Posting Date" := PostingDate;
            IF counter <> 0 then
                StatisticalJnlLine."Document No." := AgreementHeader."No." + '/' + Format(counter)
            else
                StatisticalJnlLine."Document No." := AgreementHeader."No.";
            //StatisticalJnlLine."Document No." := AgreementHeader."No.";
            StatisticalJnlLine.Validate("Statistical Account No.", AccountNo);
            StatisticalJnlLine.Validate(Amount, Amount);
            //Customer Dimensions
            StatisticalJnlLine."Agreement No." := AgreementHeader."No.";
            InitDefaultDimSource(DefaultDimSource, AgreementHeader);
            StatisticalJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', StatisticalJnlLine."Shortcut Dimension 1 Code", StatisticalJnlLine."Shortcut Dimension 2 Code",
            StatisticalJnlLine."Dimension Set ID", 0);
            iF Not Commission then
                StatisticalJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Corp Department Code");
            IF BalAccountNo <> '' then
                Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine)
            else Begin
                Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine);
                Exit(true);
            End;
        End;

        IF BalAccountNo <> '' then Begin
            StatisticalJnlLine.Init();
            StatisticalJnlLine."Posting Date" := PostingDate;
            StatisticalJnlLine."Document No." := AgreementHeader."No.";

            //Posting to Customer Account
            StatisticalJnlLine.Validate("Statistical Account No.", BalAccountNo);
            StatisticalJnlLine.Validate(Amount, -Amount);
            //Customer Dimensions
            InitDefaultDimSource(DefaultDimSource, AgreementHeader);
            StatisticalJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', StatisticalJnlLine."Shortcut Dimension 1 Code", StatisticalJnlLine."Shortcut Dimension 2 Code",
            StatisticalJnlLine."Dimension Set ID", 0);
            iF Not Commission then
                StatisticalJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Corp Department Code");
            Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine);
            Exit(true);
        End;
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", AgreementHeader."Customer No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure TBL_2633_OnBeforeInsertEvent(var Rec: Record "Statistical Ledger Entry"; RunTrigger: Boolean)
    begin
        Rec."Entry No." := InitNextEntryNo();
    end;

    local procedure InitNextEntryNo() NextEntryNo: Integer
    var
        LastStatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        LastStatisticalLedgerEntry.LockTable();
        if LastStatisticalLedgerEntry.FindLast() then;
        NextEntryNo := LastStatisticalLedgerEntry."Entry No." + 1;
    end;

    local procedure SetPostingDate(PostDate: Date)
    begin
        PostingDate := PostDate;
    end;

    var
        CZSetup: Record "MFCC01 Franchise Setup";
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";
        PostingDate: Date;


    #Region Phase2Transfer
    procedure ProcessTerminateOnSign(Var AgreementHeader: Record "MFCC01 Agreement Header"): Boolean
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        AgreementAmt: Decimal;
        CommissionAmt: Decimal;
    begin
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        SetPostingDate(WorkDate());
        GLEntry.LockTable();
        GetBalance(AgreementHeader, AgreementAmt, CommissionAmt);
        AgreementHeader."Fanchise Amt Closed" := AgreementAmt;
        AgreementHeader."Commission Amt Closed" := CommissionAmt;
        IF CommissionAmt <> 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.CommissionRecognizedGAAP, BalAccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, CommissionAmt, false, '', 0, true) then;
        IF AgreementAmt <> 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, BalAccountType::"G/L Account", CZSetup.RevenueRecognizedGAAP, AgreementAmt, false, '', 0, true) then;



        IF CommissionAmt <> 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.CommissionRecognized, CZSetup.PrepaidCommisionLT, CommissionAmt, 0, true) then;
        IF AgreementAmt <> 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, CZSetup.RevenueRecognized, AgreementAmt, 0, true) then;

        Exit(True);
    end;

    procedure ProcessTerminateOnOpen(Var AgreementHeader: Record "MFCC01 Agreement Header"): Boolean
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        AgreementAmt: Decimal;
        CommissionAmt: Decimal;
    begin
        SetPostingDate(WorkDate());
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        GLEntry.LockTable();
        GetBalance(AgreementHeader, AgreementAmt, CommissionAmt);
        AgreementHeader."Fanchise Amt Closed" := AgreementAmt;
        AgreementHeader."Commission Amt Closed" := CommissionAmt;
        IF CommissionAmt <> 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.CommissionRecognizedGAAP, BalAccountType::"G/L Account", CZSetup.DefCommisionsinOperationsGAAP, CommissionAmt, false, '', 0, true) then;
        IF AgreementAmt <> 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DefRevenueCafesinOperationGAAP, BalAccountType::"G/L Account", CZSetup.RevenueRecognizedGAAP, AgreementAmt, false, '', 0, true) then;
        Exit(true);
    end;

    local procedure GetBalance(AgreementHeader: Record "MFCC01 Agreement Header"; Var AgreementAmt: Decimal; Var CommissionAmt: Decimal)
    var
        DefHeader: Record "MFCC01 Deferral Header";
    begin
        AgreementAmt := 0;
        CommissionAmt := 0;
        IF DefHeader.Get(AgreementHeader."FranchiseFeescheduleNo.") then Begin
            DefHeader.CalcFields(Balance);
            AgreementAmt := DefHeader.Balance;
        End;
        IF DefHeader.Get(AgreementHeader."CommissionscheduleNo.") then Begin
            DefHeader.CalcFields(Balance);
            CommissionAmt := DefHeader.Balance;
        End;
    end;

    procedure CreateNewAgreement(FromAgreementHeader: Record "MFCC01 Agreement Header"; Showmessage: Boolean): Boolean
    var
        NewAgreementHeader: Record "MFCC01 Agreement Header";
        FromAgreementLine: Record "MFCC01 Agreement Line";
        NewAgreementLine: Record "MFCC01 Agreement Line";
        NewCafeTxt: Label 'New Cafe %1 is Created.';
    begin
        NewAgreementHeader.Init();
        NewAgreementHeader."No." := '';
        NewAgreementHeader.Validate("Customer No.", FromAgreementHeader."Customer No.");
        NewAgreementHeader.Insert(true);
        NewAgreementHeader."Agreement Amount" := FromAgreementHeader."Fanchise Amt Closed";
        NewAgreementHeader."SalesPerson Commission" := FromAgreementHeader."Commission Amt Closed";
        NewAgreementHeader."Royalty Bank Account" := FromAgreementHeader."Royalty Bank Account";
        NewAgreementHeader."Franchise Bank Account" := FromAgreementHeader."Franchise Bank Account";
        NewAgreementHeader.Modify();

        FromAgreementLine.SetRange("Agreement No.", FromAgreementHeader."No.");
        IF FromAgreementLine.FindSet() then
            repeat
                NewAgreementLine.TransferFields(FromAgreementLine);
                NewAgreementLine."Agreement No." := NewAgreementHeader."No.";
                NewAgreementLine.Insert(true);
            Until FromAgreementLine.Next() = 0;

        IF Showmessage then
            Message(NewCafeTxt, NewAgreementHeader."No.");
    end;


    #EndRegion Phase2Transfer

    #Region Phase2Cancel


    procedure ProcessOnSignCancel(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
    begin
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        SetPostingDate(WorkDate());
        GLEntry.LockTable();
        IF AgreementHeader."Posted Agreement Amount" <> 0 then
            IF PostAgreementAmounts(AgreementHeader, BalAccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, AccountType::Customer, AgreementHeader."Customer No.", AgreementHeader."Agreement Amount", true, AgreementHeader."Franchise Bank Account", 0, false) then Begin
                AgreementHeader."Cancled Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Commission Amount" <> 0 then
            IF PostAgreementAmounts(AgreementHeader, BalAccountType::"G/L Account", CZSetup."Accrued Fran Bonus GAAP", AccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, AgreementHeader."SalesPerson Commission", false, '', 0, true) then Begin
                AgreementHeader."Cancled Commission Amount" := AgreementHeader."SalesPerson Commission";
            End;

        IF AgreementHeader.PostedRevenueStatisticalAmount <> 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.RevenueRecognized, '', AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, '', AgreementHeader."Agreement Amount" + AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then Begin
                    AgreementHeader.CancelRevenueStatisticalAmount := AgreementHeader.NonGapInitialRevenueRecognized;
                End;
        IF AgreementHeader.PostedCommissionExpenseAmount <> 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.PrepaidCommisionLT, '', -AgreementHeader."SalesPerson Commission", 0, true) then Begin
                AgreementHeader.CancelCommissionExpenseAmount := AgreementHeader."SalesPerson Commission";
            End;
        AgreementHeader.Modify(true);
    end;

    procedure ProcessOnOpencancel(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
    begin
        SetPostingDate(WorkDate());
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        //IF Customer."Franchisee Status" <> Customer."Franchisee Status"::Operational then Begin

        GLEntry.LockTable();

        IF PostAgreementAmounts(AgreementHeader, BalAccountType::"G/L Account", CZSetup.DefRevenueCafesinOperationGAAP, AccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, AgreementHeader."Agreement Amount", false, '', 0, false) then
            IF PostAgreementAmounts(AgreementHeader, BalAccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, AccountType::"G/L Account", CZSetup.DefCommisionsinOperationsGAAP, AgreementHeader."SalesPerson Commission", false, '', 0, true) then
                IF PostStatsAmounts(AgreementHeader, CZSetup.DefRevenueCafesinOperation, CZSetup.DeferredRevenueDevelopment, AgreementHeader."Agreement Amount" - AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                    IF PostStatsAmounts(AgreementHeader, CZSetup.RevenueRecognized, CZSetup.DefRevenueCafesinOperation, AgreementHeader."Agreement Amount" - AgreementHeader.NonGapInitialRevenueRecognized, 0, false) then
                        IF PostStatsAmounts(AgreementHeader, CZSetup.PrepaidCommisionLT, CZSetup.DefCommisionsinOperations, AgreementHeader."SalesPerson Commission", 0, true) then
                            IF PostStatsAmounts(AgreementHeader, CZSetup.DefCommisionsinOperations, CZSetup.CommissionRecognized, AgreementHeader."SalesPerson Commission", 0, true) then Begin

                                Customer."Franchisee Status" := Customer."Franchisee Status"::Canceled;
                                Customer."Franchisee Type" := Customer."Franchisee Type"::Active;
                                IF Customer."Opening Date" = 0D then
                                    Customer."Opening Date" := AgreementHeader."Agreement Date";
                                Customer.Modify();
                            End;

        //end;
    end;


    procedure ProcessCancel(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        DocumentType: Enum "Sales Document Type";
        GenjnlcheckLine: Codeunit "Gen. Jnl.-Check Line";
        RevertDate: Date;
        CopyDoc: Codeunit "Copy Document Mgt.";
        CLE: Record "Cust. Ledger Entry";
        TaxExNo: Text[30];
        GLEntries: Record "G/L Entry";
        ReverseDeff: Report "MFCC01 Reverse Deferral";
    begin
        CZSetup.GetRecordonce();
        CZSetup.TestField(CommissionRecognizedGAAP);
        CZSetup.TestField(RevenueRecognizedGAAP);
        CZSetup.TestField(DefCommisionsinOperationsGAAP);
        CZSetup.TestField(DefRevenueCafesinOperationGAAP);

        //Remove Payment application
        GLEntries.Reset();
        GLEntries.SetRange("Agreement No.", AgreementHeader."No.");
        IF GLEntries.FindSet() then
            repeat
                CLE.Reset();
                CLE.SetRange("Transaction No.", GLEntry."Transaction No.");
                CLE.SetRange("Document No.", GLEntries."Document No.");
                CLE.SetRange("Posting Date", GLEntries."Posting Date");
                CLE.SetRange("Customer No.", GLEntries."Source No.");
                IF CLE.FindFirst() then
                    repeat
                        IF CLE."Original Amount" <> CLE."Remaining Amount" then
                            Unapplypayment(CLE);
                    Until CLE.Next() = 0;
            Until GLEntries.Next() = 0;

        Case AgreementHeader.Status of

            AgreementHeader.Status::Signed:
                Begin
                    ProcessOnSignCancel(AgreementHeader);
                End;
            AgreementHeader.Status::Opened:
                Begin
                    ProcessOnOpencancel(AgreementHeader);
                    ReverseDeff.ReverseDifferalLines(AgreementHeader);
                End;
        End;


    end;


    local procedure Unapplypayment(CLEntryNo: Record "Cust. Ledger Entry")
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        CheckCustLedgEntryToUnapply(CLEntryNo."Entry No.", DtldCustLedgEntry2);
        ApplyUnapplyParameters."Document No." := CLEntryNo."Document No.";
        ApplyUnapplyParameters."Posting Date" := WorkDate();
        CustEntryApplyPostedEntries.PostUnApplyCustomer(DtldCustLedgEntry2, ApplyUnapplyParameters);
    end;

    procedure CheckCustLedgEntryToUnapply(CustLedgEntryNo: Integer; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        ApplicationEntryNo: Integer;
    begin
        Clear(DetailedCustLedgEntry);
        ApplicationEntryNo := FindLastApplEntry(CustLedgEntryNo);
        if ApplicationEntryNo <> 0 then
            DetailedCustLedgEntry.Get(ApplicationEntryNo);
    end;

    procedure FindLastApplEntry(CustLedgEntryNo: Integer): Integer
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplicationEntryNo: Integer;
    begin
        DtldCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntryNo);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        DtldCustLedgEntry.SetRange(Unapplied, false);
        //OnFindLastApplEntryOnAfterSetFilters(DtldCustLedgEntry);
        ApplicationEntryNo := 0;
        if DtldCustLedgEntry.Find('-') then
            repeat
                if DtldCustLedgEntry."Entry No." > ApplicationEntryNo then
                    ApplicationEntryNo := DtldCustLedgEntry."Entry No.";
            until DtldCustLedgEntry.Next() = 0;
        exit(ApplicationEntryNo);
    end;
    #EndRegion Phase2Cancel

}