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
    begin
        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");

        GLEntry.LockTable();
        IF AgreementHeader."Posted Agreement Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, AgreementHeader."Agreement Amount", true, AgreementHeader."Royalty Bank Account") then Begin
                AgreementHeader."Posted Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Commission Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, BalAccountType::"G/L Account", CZSetup."Accrued Fran Bonus GAAP", AgreementHeader."SalesPerson Commission", true, '') then Begin
                AgreementHeader."Posted Commission Amount" := AgreementHeader."SalesPerson Commission";
            End;

        IF AgreementHeader.PostedRevenueStatisticalAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.RevenueRecognized, '', -CZSetup.NonGapInitialRevenueRecognized) then
                IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, '', -AgreementHeader."Agreement Amount" + CZSetup.NonGapInitialRevenueRecognized) then Begin
                    AgreementHeader.PostedRevenueStatisticalAmount := CZSetup.NonGapInitialRevenueRecognized;
                End;
        IF AgreementHeader.PostedCommissionExpenseAmount = 0 then
            IF PostStatsAmounts(AgreementHeader, CZSetup.PrepaidCommisionLT, '', AgreementHeader."SalesPerson Commission") then Begin
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

        CZSetup.GetRecordonce();
        Customer.Get(AgreementHeader."Customer No.");
        IF Customer."Franchisee Status" <> Customer."Franchisee Status"::Operational then Begin

            GLEntry.LockTable();

            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DeferredRevenueDevelopmentGAPP, BalAccountType::"G/L Account", CZSetup.DefRevenueCafesinOperationGAAP, AgreementHeader."Agreement Amount", false, '') then Begin
                IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup.DefCommisionsinOperationsGAAP, BalAccountType::"G/L Account", CZSetup.PrepaidCommisionLTGAAP, AgreementHeader."SalesPerson Commission", false, '') then Begin

                    IF PostStatsAmounts(AgreementHeader, CZSetup.DeferredRevenueDevelopment, CZSetup.DefRevenueCafesinOperation, AgreementHeader."Agreement Amount" - CZSetup.NonGapInitialRevenueRecognized) then
                        IF PostStatsAmounts(AgreementHeader, CZSetup.DefRevenueCafesinOperation, CZSetup.RevenueRecognized, AgreementHeader."Agreement Amount" - CZSetup.NonGapInitialRevenueRecognized) then
                            IF PostStatsAmounts(AgreementHeader, CZSetup.DefCommisionsinOperations, CZSetup.PrepaidCommisionLT, AgreementHeader."SalesPerson Commission") then
                                IF PostStatsAmounts(AgreementHeader, CZSetup.CommissionRecognized, CZSetup.DefCommisionsinOperations, AgreementHeader."SalesPerson Commission") then Begin

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
    end;

    local procedure PostAgreementAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
    BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal; Invoice: Boolean; BankAcc: Code[20]): Boolean
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
        GenJnlLine."Agreement No." := AgreementHeader."No.";
        GenJnlLine."Recipient Bank Account" := BankAcc;
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
        GenJnlLine."Agreement No." := AgreementHeader."No.";
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
        else Begin
            Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine);
            Exit(true);
        End;


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




    var
        CZSetup: Record "MFCC01 Customization Setup";
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";


}