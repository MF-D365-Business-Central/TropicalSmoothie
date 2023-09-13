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

        IF AgreementHeader."Posted Agreement Amount" = 0 then
            IF PostAgreementAmount(AgreementHeader, AccountType::Customer, AgreementHeader."Customer No.", BalAccountType::"G/L Account", CZSetup."Agreement Def. Account", AgreementHeader."Franchising Commission") then Begin
                AgreementHeader."Posted Agreement Amount" := AgreementHeader."Agreement Amount";
            End;
        IF AgreementHeader."Posted Comission Amount" = 0 then
            IF PostAgreementAmount(AgreementHeader, AccountType::"G/L Account", CZSetup."Commission Def. Account", BalAccountType::"G/L Account", CZSetup."Commission Payable Account", AgreementHeader."Franchising Commission") then Begin
                AgreementHeader."Posted Comission Amount" := AgreementHeader."SalesPerson Commission";
            End;
        AgreementHeader.Modify(true);
    end;

    local procedure PostAgreementAmount(Var AgreementHeader: Record "MFCC01 Agreement Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
    BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document No." := AgreementHeader."No.";
        //Posting to Customer Account
        GenJnlLine.Validate("Account Type", AccountType);
        GenJnlLine.Validate("Account No.", AccountNo);
        //Posting to Agreement Def. Account
        GenJnlLine.Validate("Bal. Account Type", BalAccountType);
        GenJnlLine.Validate("Bal. Account No.", BalAccountNo);
        //Posting Agreement Amount
        GenJnlLine.Validate(Amount, Amount);
        //Customer Dimensions
        InitDefaultDimSource(DefaultDimSource, AgreementHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        Exit(GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0);

    end;

    local procedure PostComissionAmount(Var AgreementHeader: Record "MFCC01 Agreement Header"; Amount: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document No." := AgreementHeader."No.";
        //Posting to Customer Account
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", CZSetup."Commission Def. Account");
        //Posting to Agreement Def. Account
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", CZSetup."Commission Payable Account");
        //Posting Agreement Amount
        GenJnlLine.Validate(Amount, Amount);
        //Customer Dimensions
        InitDefaultDimSource(DefaultDimSource, AgreementHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);

        IF GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0 then begin
            AgreementHeader."Posted Comission Amount" := Amount;
            AgreementHeader.Modify();
        end;
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", AgreementHeader."Customer No.");
    end;

    var
        CZSetup: Record "MFCC01 Customization Setup";
        DimMgt: Codeunit DimensionManagement;
}