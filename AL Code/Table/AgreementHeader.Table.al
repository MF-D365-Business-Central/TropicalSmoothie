table 60003 "MFCC01 Agreement Header"
{
    Caption = 'Agreement Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            // trigger OnValidate()
            // begin

            //     TestNoSeries();
            // end;
        }

        field(10; "Effective Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
                CheckDates();
            End;
        }

        field(11; "Opening Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
                CheckDates();
            End;
        }
        field(12; "Term Expiration Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }

        field(13; "Royalty Reporting Start Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }
        field(14; "Renewal FA Effective Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }
        field(15; "Renewal Fee-First($)(OTF)"; Decimal)
        {
            Caption = 'Renewal Fee-First($)(Only 1 time fee)';
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }
        field(16; "License Type"; Enum "MFCC01 License Type")
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }
        field(17; Status; Enum "MFCC01 Agreement Status")
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }

        field(18; "Franchie Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }
        field(19; "Royalty Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            Begin
                TestStatusOpen(Rec);
            End;
        }


        field(23; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "No.")
        {
            Clustered = true;
        }
    }



    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        // if "No." = '' then begin
        //     CustSetup.Get();
        //     CustSetup.TestField("Agreement Nos.");
        //     NoSeriesMgt.InitSeries(CustSetup."Agreement Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        // end;
    End;



    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
        AgreementUsers: Record "MFCC01 Agreement Users";
    begin
        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        IF Not AgreementLine.IsEmpty() then
            AgreementLine.DeleteAll();

        AgreementUsers.SetRange("Customer No.", Rec."Customer No.");
        AgreementUsers.SetRange("Agreement No.", Rec."No.");
        IF Not AgreementUsers.IsEmpty() then
            AgreementUsers.DeleteAll();
    end;


    local procedure CheckDates()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
    begin

        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        IF AgreementLine.FindSet() then
            repeat
                IF (AgreementLine."Ending Date" <> 0D) And (
                     AgreementLine."Starting Date" < Rec."Opening Date") then
                    Error(OpenDateSTDateErrorLbl, AgreementLine."Starting Date", Rec."Opening Date");
                IF (AgreementLine."Ending Date" <> 0D) And (
                     AgreementLine."Starting Date" < Rec."Effective Date") then
                    Error(EffDateSTDateErrorLbl, AgreementLine."Starting Date", Rec."Effective Date");
                IF (AgreementLine."Ending Date" <> 0D) AND (AgreementLine."Ending Date" < Rec."Opening Date")
                     then
                    Error(OpenDateEDDateErrorLbl, AgreementLine."Ending Date", Rec."Opening Date");
                IF (AgreementLine."Ending Date" <> 0D) AND
                    (AgreementLine."Ending Date" < Rec."Effective Date") then
                    Error(EffDateEDDateErrorLbl, AgreementLine."Ending Date", Rec."Effective Date");

            Until AgreementLine.Next() = 0;






    end;

    trigger OnRename()
    begin

    end;

    var

        CustSetup: Record "MFCC01 Customisation Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        OpenDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Opening Date %2';
        EffDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Effective Date %2';

        OpenDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Opening Date %2';
        EffDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Effective Date %2';

    local procedure TestNoSeries()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        // if "No." <> xRec."No." then
        //     if not AgreementHeader.Get(Rec."Customer No.", Rec."No.") then begin
        //         CustSetup.Get();
        //         NoSeriesMgt.TestManual(CustSetup."Agreement Nos.");
        //         "No. Series" := '';

        //     end;
    end;

    procedure AssistEdit(OldAgreementHeader: Record "MFCC01 Agreement Header"): Boolean
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin

        // AgreementHeader := Rec;
        // CustSetup.Get();
        // CustSetup.TestField("Agreement Nos.");
        // if NoSeriesMgt.SelectSeries(CustSetup."Agreement Nos.", OldAgreementHeader."No. Series", "No. Series") then begin
        //     NoSeriesMgt.SetSeries(AgreementHeader."No.");
        //     Rec := AgreementHeader;
        //     OnAssistEditOnBeforeExit(AgreementHeader);
        //     exit(true);
        // end;

    end;

    procedure TestStatusOpen(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        AgreementHeader.TestField(Status, AgreementHeader.Status::Open);
    end;

    procedure SetStatusOpen(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        AgreementHeader.TestField(Status, Status::Active);
        AgreementHeader.Status := AgreementHeader.Status::Open;
        AgreementHeader.Modify();
    end;

    procedure SetStatusActive(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        CheckLinesExist(AgreementHeader, true);
        AgreementHeader.TestField(Status, AgreementHeader.Status::Open);
        AgreementHeader.Status := AgreementHeader.Status::Active;
        AgreementHeader.Modify();

    end;

    procedure SetStatusTerminate(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        CheckLinesExist(AgreementHeader, true);
        AgreementHeader.TestField(Status, Status::Active);
        AgreementHeader.Status := AgreementHeader.Status::Terminated;
        AgreementHeader.Modify();
    end;

    local procedure CheckLinesExist(AgreementHeader: Record "MFCC01 Agreement Header"; ShowError: Boolean) Found: Boolean
    var
        AgreementLine: Record "MFCC01 Agreement Line";
        NoLinesError: Label 'Agreement Lines does not exist.';
    begin
        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        Found := Not AgreementLine.IsEmpty();
        IF ShowError and (Not Found) then
            Error(NoLinesError);

    end;



    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var AgreementHeader: Record "MFCC01 Agreement Header"; xAgreementHeader: Record "MFCC01 Agreement Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var AgreementHeader: Record "MFCC01 Agreement Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssistEditOnBeforeExit(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
    end;
}