table 60012 "MFCC01 Agreement Renewal"
{
    Caption = 'Agreement Renewal';
    DataClassification = CustomerContent;
    LookupPageId = "MFCC01 Agreement Renewal";
    DrillDownPageId = "MFCC01 Agreement Renewal";
    fields
    {

        field(2; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(13; "Renewal Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                Chageallowed();
                TestStatusOpen();
            End;
        }
        field(14; "Effective Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                Chageallowed();
                TestStatusOpen();
                CheckDateAllowed();
            End;
        }
        field(15; "Term Expiration Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                Chageallowed();
                TestStatusOpen();
                CheckDateAllowed();
            End;
        }
        field(10; "Renewal Fees"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                Chageallowed();
                TestStatusOpen();
            End;
        }
        field(53; "RenewalscheduleNo."; Code[20])
        {
            Caption = 'Renewal Schedule No.';
            TableRelation = "MFCC01 Deferral Header"."Document No.";
            Editable = false;
        }
        field(54; "Posted Renewal Fees"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; Status; Enum "MFCC01 Agreement Status")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "No. of Periods"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Agreement No.", "Renewal Date")
        {
            Clustered = true;
        }
    }


    var
        CZ: Record "MFCC01 Customization Setup";
        ChangeErr: Label 'Changes not allowed as renewal fee already processed.';
        ExpDateErr: Label 'Effective Date %2 must be later than Agreement expiration Date %2';
        DuplicateErr: Label 'Term period already within the range';

    procedure TestStatusOpen()
    Var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        AgreementHeader.Get(Rec."Agreement No.");
        AgreementHeader.TestField(Status, AgreementHeader.Status::Opened);
    end;

    local procedure Chageallowed()
    begin
        IF Rec."Posted Renewal Fees" <> 0 then
            Error(ChangeErr);
    end;

    local procedure CheckDateAllowed()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        Renewal: Record "MFCC01 Agreement Renewal";
    begin
        IF (Rec."Effective Date" = 0D) or (Rec."Term Expiration Date" = 0D) then
            exit;

        //CalcExpirationDate();

        AgreementHeader.Get(Rec."Agreement No.");
        IF AgreementHeader."Term Expiration Date" > Rec."Effective Date" then
            Error(ExpDateErr, Rec."Effective Date", AgreementHeader."Term Expiration Date");

        Renewal.SetRange("Agreement No.", Rec."Agreement No.");
        Renewal.FilterGroup(-1);
        Renewal.SetFilter("Effective Date", '%1..%2', Rec."Effective Date", Rec."Term Expiration Date");
        Renewal.SetFilter("Term Expiration Date", '%1..%2', Rec."Term Expiration Date");
        IF Renewal.FindFirst() then
            Error(DuplicateErr);
        CalcPeriods();
    end;

    local procedure CalcPeriods()
    var
        DeferalUtilities: Codeunit "MFCC01 Deferral Utilities";
    begin
        IF (Rec."Effective Date" <> 0D) And (Rec."Term Expiration Date" <> 0D) then
            Rec."No. of Periods" := DeferalUtilities.CalcNoOfPeriods(Rec."Effective Date", Rec."Term Expiration Date");
    end;


    procedure SetStatusSigned()
    var
        CZSetup: Record "MFCC01 Customization Setup";
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        Rec.TestField("No. of Periods");
        CZSetup.GetRecordonce();
        CZSetup.TestField("Franchise Renewal Fee GAAP");
        CZSetup.TestField("Renewal Deferral Template");
        CZSetup.TestField("Deferred Renewal Fee GAAP");
        CZSetup.TestField("Franchise Renewal Fee");
        CZSetup.TestField("Deferred Renewal Fee");

        AgreementHeader.Get(Rec."Agreement No.");
        AgreementHeader.TestField(Status, AgreementHeader.Status::Opened);
        Rec.Status := AgreementHeader.Status::Signed;
        Rec.Modify();
        OnaferSignEvent(Rec);
    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::InDevelopment);
    end;

    trigger OnRename()
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnaferSignEvent(var Renewal: Record "MFCC01 Agreement Renewal")
    begin
    end;
}