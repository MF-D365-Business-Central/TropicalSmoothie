table 60005 "MFCC01 Agreement Users"
{
    Caption = 'Agreement Users';
    DataClassification = CustomerContent;
    LookupPageId = "MFCC01 Agreement Users";
    DrillDownPageId = "MFCC01 Agreement Users";
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
        field(10; "Owner First Name"; Text[50])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                UpdateHeaderInfo();
            End;
        }
        field(11; "Owner Last Name"; Text[50])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                UpdateHeaderInfo();
            End;
        }
        field(12; "E-Mail"; Text[80])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                UpdateHeaderInfo();
            End;
        }
        field(13; Phone; Text[80])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
            trigger OnValidate()
            Begin
                TestStatusOpen();
                UpdateHeaderInfo();
            End;
        }
        field(14; Active; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Agreement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure TestStatusOpen()
    Var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        // AgreementHeader.Get(Rec."Agreement No.");
        // AgreementHeader.TestField(Status, AgreementHeader.Status::"Not Signed");
    end;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;

    procedure UpdateHeaderInfo()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        IF AgreementHeader.Get(Rec."Agreement No.") then;
        Rec."Customer No." := AgreementHeader."Customer No.";

    end;

}