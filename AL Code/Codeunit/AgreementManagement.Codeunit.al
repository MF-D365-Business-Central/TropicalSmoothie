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

        IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup."Revenue Statistical Account", BalAccountType::"G/L Account", CZSetup.DeferredRevenueStatisticalAcc, CZSetup.NonGapInitialRevenueRecognised) then Begin
            AgreementHeader.PostedRevenueStatisticalAmount := CZSetup.NonGapInitialRevenueRecognised;
        End;

        IF PostAgreementAmounts(AgreementHeader, AccountType::"G/L Account", CZSetup."Commission Expense Account", BalAccountType::"G/L Account", CZSetup.CommissionDeferredExpenseAcc, AgreementHeader."SalesPerson Commission") then Begin
            AgreementHeader.PostedCommissionExpenseAmount := AgreementHeader."SalesPerson Commission";
        End;

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

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", AgreementHeader."Customer No.");
    end;


    var
        CZSetup: Record "MFCC01 Customization Setup";
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";
}