codeunit 60002 "MFCC01 Agreement Management"
{

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"MFCC01 Agreement Header", OnaferActivateEvent, '', false, false)]
    local procedure OnaferActivateEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        ProcessOnActivate(AgreementHeader);
    end;

    procedure ProcessOnActivate(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        AccountType: Enum "Gen. Journal Account Type";
        BalAccountType: Enum "Gen. Journal Account Type";
        DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
    begin


        CZSetup.GetRecordonce();
        GLEntry.LockTable();
        IF AgreementHeader."Posted Agreement Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", CZSetup."Agreement Def. Account", AgreementHeader."Agreement Amount") then Begin
                AgreementHeader."Posted Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Comission Amount" = 0 then
            IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup."Commission Payable Account", BalAccountType::"G/L Account", CZSetup."Commission Def. Account", AgreementHeader."SalesPerson Commission") then Begin
                AgreementHeader."Posted Comission Amount" := AgreementHeader."SalesPerson Commission";
            End;

        IF PostStatsAmounts(AgreementHeader, CZSetup."Revenue Statistical Account", CZSetup.DeferredRevenueStatisticalAcc, CZSetup.NonGapInitialRevenueRecognised) then Begin
            AgreementHeader.PostedRevenueStatisticalAmount := CZSetup.NonGapInitialRevenueRecognised;
        End;

        IF PostStatsAmounts(AgreementHeader, CZSetup."Commission Expense Account", CZSetup.CommissionDeferredExpenseAcc, AgreementHeader."SalesPerson Commission") then Begin
            AgreementHeader.PostedCommissionExpenseAmount := AgreementHeader."SalesPerson Commission";
        End;
        DeferralUtility.CreatedeferralScheduleFromAgreement(AgreementHeader);
        AgreementHeader.Modify(true);
    end;

    local procedure PostAgreementAmounts(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
    BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document No." := AgreementHeader."No.";
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
        Codeunit.Run(Codeunit::"Stat. Acc. Jnl. Line Post", StatisticalJnlLine);
        Commit();
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