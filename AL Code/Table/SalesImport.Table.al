table 60006 "MFCC01 Sales Import"
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
        field(4; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }

        field(5; "Bill-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }

        field(6; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(7; "External Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }



        field(50; "Type"; enum "Sales Line Type")
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

        field(57; "Unit Price"; Decimal)
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

    procedure CreateSalesHeader() SalesHeader: Record "Sales Header";

    begin
        SalesHeader.init();
        //Keys >>
        SalesHeader."Document Type" := Rec."Document Type";
        SalesHeader."No." := Rec."Document No.";
        //Keys <<
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Rec."Customer No.");
        SalesHeader.Validate("Document Date" , Rec."Posting Date");
        SalesHeader.Validate("Posting Date" , Rec."Posting Date");
        SalesHeader."External Document No." := Rec."External Document No.";
        SalesHeader.Modify();

    end;

    procedure CreateSalesLine(Var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.init();
        //Keys >>
        SalesLine."Document Type" := Rec."Document Type";
        SalesLine."Document No." := Rec."Document No.";
        SalesLine."Line No." := LineNo;
        LineNo += 10000;
        //Keys <<
        SalesLine.Insert(true);
        SalesLine.Validate("Type", Rec.Type);
        SalesLine.Validate("No.", Rec."No.");
        SalesLine.Description := Rec.Description;
        SalesLine.Validate(Quantity, Rec.Quantity);
        SalesLine.Validate("Unit Price", Rec."Unit Price");
        IF Rec."Department Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", Rec."Department Code");
        SalesLine.Modify();

    end;
}