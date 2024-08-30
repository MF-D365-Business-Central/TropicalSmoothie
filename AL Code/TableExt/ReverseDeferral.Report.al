report 60016 "MFCC01 Reverse Deferral"
{
    Caption = 'Reverse Franchise Deferral';
    ProcessingOnly = true;

    dataset
    {


    }




    Local procedure PostDeferralLine(DeferralHeader: Record "MFCC01 Deferral Header"; Var DeferralLine: Record "MFCC01 Deferral Line")
    var
        GenJnlLine: Record "Gen. Journal Line";

        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document No." := DeferralHeader."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");

        Case DeferralHeader.Type of
            DeferralHeader.Type::Commission:
                GenJnlLine.Validate("Account No.", CZSetup.DefCommisionsinOperationsGAAP);
            DeferralHeader.Type::"Franchise Fee",
            DeferralHeader.Type::Transferred:
                GenJnlLine.Validate("Account No.", CZSetup.RevenueRecognizedgaap);
            DeferralHeader.Type::Renewal:
                GenJnlLine.Validate("Account No.", CZSetup."Franchise Renewal Fee GAAP");
        End;
        GenJnlLine.Validate("Currency Code", DeferralLine."Currency Code");
        GenJnlLine.Validate(Amount, DeferralLine.Amount);
        InitDefaultDimSource(DefaultDimSource, DeferralHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
    GenJnlLine."Dimension Set ID", 0);
        GenJnlLine."Agreement No." := DeferralHeader."Agreement No.";
        DeferralLine.Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;

        //Balancing
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := WorkDate();
        GenJnlLine."Document No." := DeferralHeader."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        IF DeferralHeader.Type = DeferralHeader.Type::Commission then
            GenJnlLine.Validate("Account No.", CZSetup.CommissionRecognizedGAAP)
        Else
            GenJnlLine.Validate("Account No.", CZSetup.DefRevenueCafesinOperationGAAP);

        Case DeferralHeader.Type of
            DeferralHeader.Type::Commission:
                GenJnlLine.Validate("Account No.", CZSetup.CommissionRecognizedGAAP);
            DeferralHeader.Type::"Franchise Fee",
            DeferralHeader.Type::Transferred:
                GenJnlLine.Validate("Account No.", CZSetup.DefRevenueCafesinOperationGAAP);
            DeferralHeader.Type::Renewal:
                GenJnlLine.Validate("Account No.", CZSetup."Deferred Renewal Fee GAAP");
        End;
        GenJnlLine.Validate("Currency Code", DeferralLine."Currency Code");
        GenJnlLine.Validate(Amount, -DeferralLine.Amount);
        InitDefaultDimSource(DefaultDimSource, DeferralHeader);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        GenJnlLine."Agreement No." := DeferralHeader."Agreement No.";
        DeferralLine.Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;
        DeferralLine.Canceled := True;
        DeferralLine.Modify();
        //Commit();
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", DeferralHeader."Customer No.");
    end;

    procedure ReverseDifferalLines(AgreementHeader: Record "MFCC01 Agreement Header"; CorrectionType: Enum CorrectionType)
    var
        DeferralHeader: Record "MFCC01 Deferral Header";
    begin

        CZSetup.GetRecordonce();
        CZSetup.TestField(CommissionRecognizedGAAP);
        CZSetup.TestField(RevenueRecognizedGAAP);

        CZSetup.TestField(DefCommisionsinOperationsGAAP);
        CZSetup.TestField(DefRevenueCafesinOperationGAAP);

        GLEntry.LockTable();
        Case CorrectionType of
            CorrectionType::Fee:
                IF DeferralHeader.Get(AgreementHeader."FranchiseFeescheduleNo.") then Begin
                    ProcesLines(DeferralHeader);
                    DeferralHeader.Status := DeferralHeader.Status::Canceled;
                    DeferralHeader.Modify();
                End;
            CorrectionType::Commission:
                IF DeferralHeader.Get(AgreementHeader."CommissionscheduleNo.") then Begin
                    ProcesLines(DeferralHeader);
                    DeferralHeader.Status := DeferralHeader.Status::Canceled;
                    DeferralHeader.Modify();
                End;
            CorrectionType::Schedules:
                Begin
                    IF DeferralHeader.Get(AgreementHeader."CommissionscheduleNo.") then Begin
                        ProcesLines(DeferralHeader);
                        DeferralHeader.Status := DeferralHeader.Status::Canceled;
                        DeferralHeader.Modify();
                    End;
                    IF DeferralHeader.Get(AgreementHeader."FranchiseFeescheduleNo.") then Begin
                        ProcesLines(DeferralHeader);
                        DeferralHeader.Status := DeferralHeader.Status::Canceled;
                        DeferralHeader.Modify();
                    End;
                End;
        End;



    end;

    local procedure ProcesLines(DeferralHeader: Record "MFCC01 Deferral Header")
    var
        DeferralLine: Record "MFCC01 Deferral Line";
    begin
        DeferralLine.SetRange("Document No.", DeferralHeader."Document No.");
        DeferralLine.SetRange(Posted, true);
        DeferralLine.SetRange(Canceled, false);
        IF DeferralLine.FindSet() then
            repeat
                PostDeferralLine(DeferralHeader, DeferralLine);
            Until DeferralLine.Next() = 0;

        DeferralLine.Reset();
        DeferralLine.SetRange("Document No.", DeferralHeader."Document No.");
        DeferralLine.SetRange(Posted, false);
        IF DeferralLine.FindSet(True) then
            DeferralLine.Modifyall(Posted, true);

    end;


    var
        CZSetup: Record "MFCC01 Franchise Setup";
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";
}