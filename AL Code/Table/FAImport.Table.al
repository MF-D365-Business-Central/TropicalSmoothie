table 60011 "MFCC01 FA Import"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }


        field(2; Category; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[150])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Useful Life In Months"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Method/Conv"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Disposal Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Book Value"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(10; "Accumulated Depreciation"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(12; "FA Class Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "FA SubClass Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(14; "FA Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(89; "FA No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Fixed Asset"."No.";
            Editable = false;
        }
        field(90; Status; Enum "MFCC01 Staging Status")
        {
            DataClassification = CustomerContent;
        }
        field(91; ErrorText; Text[500])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }


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

}