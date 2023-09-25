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
        field(3; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Useful Life In Months"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Method/Conv"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; "In Service Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Disposal Date"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(8; "Historical Cost/Other Basis"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "FMV Cost/Other Basis"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(10; "Accumulated Depreciation"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; NBV; Decimal)
        {
            DataClassification = CustomerContent;
        }


        field(89; "FA No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(90; Status; Enum "MFCC01 Staging Status")
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