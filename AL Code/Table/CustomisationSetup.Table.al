table 60000 "MFCC01 Customisation Setup"
{
    Caption = 'Customisation Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Bal. Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }

        field(12; "Deferral Template"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Deferral Template"."Deferral Code";
        }

        field(50; "Deferral Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
        }
        // field(51; "Agreement Nos."; Code[20])
        // {
        //     DataClassification = CustomerContent;
        //     TableRelation = "No. Series".Code;
        // }
    }

    keys
    {
        key(Key1; "Primary Key")
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