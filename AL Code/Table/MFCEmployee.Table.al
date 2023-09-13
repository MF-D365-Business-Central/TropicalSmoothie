table 60010 "MFCC01 Employee"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Employee."No.";
        }
        field(2; "Employee Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Employee No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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