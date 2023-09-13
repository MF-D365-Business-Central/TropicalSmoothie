table 60000 "MFCC01 Customization Setup"
{
    Caption = 'Customization Setup';
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

        field(51; "Local Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code Where("Global Dimension No." = const(1));
        }

        field(52; "National Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code Where("Global Dimension No." = const(1));
        }

        field(53; "Royalty Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(54; "Local Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(55; "National Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }

        field(56; "Commission Def. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(57; "Commission Payable Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(58; "Agreement Def. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
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

    procedure GetRecordonce()
    begin
        IF Not ReadRecord then begin
            Rec.Get();
            ReadRecord := true;
        end;
    end;

    var
        ReadRecord: Boolean;

}