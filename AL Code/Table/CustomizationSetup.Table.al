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
        field(10; "Revenue Recognised GAAP"; Code[20])
        {
            Caption = 'Revenue Recognised';
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
        field(49; "Agreement Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
        }

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
        field(56; "Commission Payble Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(57; "Prepaid Commision"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(58; "Def Revenue Cafes in Operation"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(59; "Deferred Revenue Operational"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(60; "Revenue Recognised"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(61; CommissionDeferredExpenseAcc; Code[20])
        {
            Caption = 'Commission Deferred Expense Account';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(62; "Commission Expense Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(63; NonGapInitialRevenueRecognised; Decimal)
        {
            Caption = 'Non Gap Initial Revenue Recognised';
            DataClassification = CustomerContent;
        }
        field(64; "Deferred Revenue Development"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(65; "Revenue Recognised Development"; Code[20])
        {
            Caption = 'Revenue Recognised Development';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(66; "Non GAAP Consolidation Company"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(67; "Commission Recognised GAAP"; Code[20])
        {
            Caption = 'Commission Recognised';
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