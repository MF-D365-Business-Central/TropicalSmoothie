codeunit 60002 "MFCC01 Agreement Management"
{

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Header", 'OnaferSignEvent', '', false, false)]
    local procedure OnaferSignEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        ProcessOnSign(AgreementHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Header", 'OnaferOpenEvent', '', false, false)]
    local procedure OnaferOpenEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        ProcessOnOpen(AgreementHeader);
    end;


    procedure ProcessOnSign(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        Customer: Record Customer;
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        DefAccount: Code[20];
        RevAccount: Code[20];
    begin
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        IF Customer."Franchisee Status" = Customer."Franchisee Status"::Operational then Begin
            DefAccount := CZSetup."Revenue Recognised";
            RevAccount := CZSetup."Revenue Recognised Development";
        End else Begin
            DefAccount := CZSetup."Deferred Revenue Development";
            RevAccount := CZSetup."Revenue Recognised Development";
        End;
        GLEntry.LockTable();
        IF AgreementHeader."Posted Agreement Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", DefAccount, AgreementHeader."Agreement Amount", true) then Begin
                AgreementHeader."Posted Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Comission Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup."Prepaid Commision", BalAccountType::"G/L Account", CZSetup."Commission Payble Account", AgreementHeader."SalesPerson Commission", true) then Begin
                AgreementHeader."Posted Comission Amount" := AgreementHeader."SalesPerson Commission";
            End;
        IF AgreementHeader.PostedRevenueStatisticalAmount = 0 then
            IF AgreementHeader.NonGapInitialRevenueRecognised <> 0 then
                IF PostStatsAmounts(AgreementHeader, RevAccount, CZSetup."Deferred Revenue Operational", AgreementHeader.NonGapInitialRevenueRecognised) then Begin
                    IF PostStatsAmounts(AgreementHeader, CZSetup."Deferred Revenue Operational", '', AgreementHeader."Agreement Amount") then
                        AgreementHeader.PostedRevenueStatisticalAmount := CZSetup.NonGapInitialRevenueRecognised;
                End;
        IF AgreementHeader.PostedCommissionExpenseAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup."Commission Expense Account", CZSetup.CommissionDeferredExpenseAcc, AgreementHeader."SalesPerson Commission") then Begin
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
        DefAccount: Code[20];
    begin

        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        IF Customer."Franchisee Status" <> Customer."Franchisee Status"::Operational then Begin
            DefAccount := CZSetup."Def Revenue Cafes in Operation";

            GLEntry.LockTable();

            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", DefAccount, AgreementHeader."Agreement Amount", false) then Begin
                IF PostStatsAmounts(AgreementHeader, CZSetup."Revenue Recognised", CZSetup."Deferred Revenue Operational", AgreementHeader.NonGapInitialRevenueRecognised) then
                    IF PostStatsAmounts(AgreementHeader, CZSetup."Deferred Revenue Operational", '', AgreementHeader."Agreement Amount") then Begin
                        Customer."Franchisee Status" := Customer."Franchisee Status"::Operational;
                        Customer."Franchisee Type" := Customer."Franchisee Type"::Active;
                        IF Customer."Opening Date" = 0D then
                            Customer."Opening Date" := AgreementHeader."Agreement Date";
                        Customer.Modify();
                    End;

            End;
        End;

        DeferralUtility.CreatedeferralScheduleFromAgreement(AgreementHeader);
    end;

    local procedure PostAgreementAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
    BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal; Invoice: Boolean): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
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
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
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
        Exit(GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0);
    end;


    local procedure PostStatsAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountNo: Code[20];
     BalAccountNo: Code[20]; Amount: Decimal): Boolean
    var
        StatisticalJnlLine: Record "Statistical Acc. Journal Line";
        StatAccJnlLinePost: Codeunit "Stat. Acc. Jnl. Line Post";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin

        StatisticalJnlLine.Init();
        StatisticalJnlLine."Posting Date" := WorkDate();
        StatisticalJnlLine."Document No." := AgreementHeader."No.";
        StatisticalJnlLine.Validate("Statistical Account No.", AccountNo);
        StatisticalJnlLine.Validate(Amount, Amount);
        //Customer Dimensions
        InitDefaultDimSource(DefaultDimSource, AgreementHeader);
        StatisticalJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', StatisticalJnlLine."Shortcut Dimension 1 Code", StatisticalJnlLine."Shortcut Dimension 2 Code",
        StatisticalJnlLine."Dimension Set ID", 0);
        IF BalAccountNo <> '' then
            Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine)
        else
            Exit(Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine));
        Commit();
        IF BalAccountNo <> '' then Begin
            StatisticalJnlLine.Init();
            StatisticalJnlLine."Posting Date" := WorkDate();
            StatisticalJnlLine."Document No." := AgreementHeader."No.";

            //Posting to Customer Account
            StatisticalJnlLine.Validate("Statistical Account No.", BalAccountNo);
            StatisticalJnlLine.Validate(Amount, -Amount);
            //Customer Dimensions
            InitDefaultDimSource(DefaultDimSource, AgreementHeader);
            StatisticalJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', StatisticalJnlLine."Shortcut Dimension 1 Code", StatisticalJnlLine."Shortcut Dimension 2 Code",
            StatisticalJnlLine."Dimension Set ID", 0);
            Exit(Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine));

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




    var
        CZSetup: Record "MFCC01 Customization Setup";
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";


}