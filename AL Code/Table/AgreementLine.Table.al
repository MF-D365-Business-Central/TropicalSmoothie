table 60004 "MFCC01 Agreement Line"
{
    Caption = 'Agreement Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(2; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(9; Description; Text[100])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
            End;
        }
        field(10; "Royalty Fees"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
            End;
        }
        field(11; "Local Fees"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
            End;
        }

        field(12; "National Fees"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
            End;
        }
        field(13; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                CheckDates();
            End;
        }
        field(14; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                CheckDates();
            End;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Agreement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var

        EndDateErrorLbl: Label 'Ending Date %1 must be greater then Starting Date %2';
        OpenDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Opening Date %2';
        EffDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Effective Date %2';

        OpenDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Opening Date %2';
        EffDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Effective Date %2';

    procedure TestStatusOpen()
    Var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        AgreementHeader.Get(Rec."Customer No.", Rec."Agreement No.");
        AgreementHeader.TestField(Status, AgreementHeader.Status::Open);
    end;

    local procedure CheckDates()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        IF (Rec."Ending Date" <> 0D) ANd
             (Rec."Starting Date" > Rec."Ending Date") then
            Error(EndDateErrorLbl, Rec."Ending Date", Rec."Starting Date");


        AgreementHeader.Get(Rec."Customer No.", Rec."Agreement No.");
        IF (Rec."Starting Date" <> 0D) And
             (Rec."Starting Date" < AgreementHeader."Opening Date") then
            Error(OpenDateSTDateErrorLbl, Rec."Starting Date", AgreementHeader."Opening Date");
        IF (Rec."Starting Date" <> 0D) And
         (Rec."Starting Date" < AgreementHeader."Effective Date") then
            Error(EffDateSTDateErrorLbl, Rec."Starting Date", AgreementHeader."Effective Date");

        IF (Rec."Ending Date" <> 0D) And
            (Rec."Ending Date" < AgreementHeader."Opening Date") then
            Error(OpenDateEDDateErrorLbl, Rec."Ending Date", Rec."Starting Date");
        IF (Rec."Ending Date" <> 0D) And
             (Rec."Ending Date" < AgreementHeader."Effective Date") then
            Error(EffDateEDDateErrorLbl, Rec."Ending Date", AgreementHeader."Opening Date");

    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        Rec.TestStatusOpen();
    end;

    trigger OnRename()
    begin

    end;

}