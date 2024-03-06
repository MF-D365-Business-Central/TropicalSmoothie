table 60011 "MFCC01 Snowflake Entry"
{
    Caption = 'Snowflake Entries';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; "Net Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(25; Remarks; Text[500])
        {
            DataClassification = CustomerContent;
        }
        field(30; Status; Enum "MFCC01 Snowflake Status")
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

    fieldgroups
    {
        // Add changes to field groups here
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