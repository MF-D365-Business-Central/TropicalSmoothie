table 60013 "MFCC01 Dimension Combination"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Parent Dimension Code"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Parent Dimension Value"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Dimension Code"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; "Child Dimension Value"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Parent Dimension Code", "Parent Dimension Value", "Dimension Code", "Child Dimension Value")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
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