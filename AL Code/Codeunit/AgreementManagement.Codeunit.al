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

        DeferralUtility.CreatedeferralScheduleFromAgreement(AgreementHeader);
        //end;
    end;

    procedure ProcessCommission(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        //DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        ConfirmTxt: Label 'Do you want to Process commission.?';
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
}