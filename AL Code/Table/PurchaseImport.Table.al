table 60010 "MFCC01 Purchase Import"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Document Type"; Enum "Sales Document Type")
        {
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }

        field(5; "Pay-to Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }

        field(6; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(7; "External Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }



        field(50; "Type"; enum "Purchase Line Type")
        {
            DataClassification = CustomerContent;
        }
        field(51; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE

            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF (Type = CONST(Item)) Item;
        }
        field(52; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        // field(53; "Unit of Measure Code"; Code[10])
        // {
        //     DataClassification = CustomerContent;
        // }
        // field(54; "Variant Code"; Code[10])
        // {
        //     DataClassification = CustomerContent;
        // }
        // field(55; "Location Code"; Code[10])
        // {
        //     DataClassification = CustomerContent;
        // }
        field(56; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(57; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(59; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        // Job purpose
        field(90; Status; Enum "MFCC01 Staging Status")
        {
            DataClassification = CustomerContent;
        }
        field(91; "Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(92; "Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(93; Remarks; Text[500])
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

    procedure CreatePurchHeader() PurchHeader: Record "Purchase Header";

    begin
        PurchHeader.init();
        //Keys >>
        PurchHeader."Document Type" := Rec."Document Type";
        PurchHeader."No." := Rec."Document No.";
        //Keys <<
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", Rec."Vendor No.");
        PurchHeader.Validate("Document Date", Rec."Posting Date");
        PurchHeader.Validate("Posting Date", Rec."Posting Date");
        IF Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
            PurchHeader."Vendor Cr. Memo No." := Rec."External Document No."
        else
            PurchHeader."Vendor Invoice No." := Rec."External Document No.";
        PurchHeader.Modify();

    end;

    procedure CreatePurchLine(Var LineNo: Integer)
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.init();
        //Keys >>
        PurchLine."Document Type" := Rec."Document Type";
        PurchLine."Document No." := Rec."Document No.";
        PurchLine."Line No." := LineNo;
        LineNo += 10000;
        //Keys <<
        PurchLine.Insert(true);
        PurchLine.Validate("Type", Rec.Type);
        PurchLine.Validate("No.", Rec."No.");
        PurchLine.Description := Rec.Description;
        PurchLine.Validate(Quantity, Rec.Quantity);
        PurchLine.Validate("Direct Unit Cost", Rec."Direct Unit Cost");
        IF Rec."Department Code" <> '' then
            PurchLine.Validate("Shortcut Dimension 1 Code", Rec."Department Code");
        PurchLine.Modify();

    end;

}