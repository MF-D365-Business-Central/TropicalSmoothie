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

        field(4; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }


        field(6; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }



        field(8; "Posting Description"; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(51; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";

        }
        field(52; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }

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
        SalesHeader."No." := '';
        //Keys <<
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Rec."Customer No.");
        SalesHeader.Validate("Document Date", Rec."Posting Date");
        SalesHeader.Validate("Posting Date", Rec."Posting Date");

        SalesHeader."Posting Description" := Rec."Posting Description";
        SalesHeader.Modify(True);

    end;

    procedure CreateSalesLine(Var LineNo: Integer; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.init();
        //Keys >>
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        LineNo += 10000;
        //Keys <<
        SalesLine.Insert(true);
        SalesLine.Validate("Type", SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", Rec."No.");
        SalesLine.Description := Rec.Description;
        SalesLine.Validate(Quantity, Rec.Quantity);
        SalesLine.Validate("Unit Price", Rec."Unit Price");
        IF Rec."Department Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", Rec."Department Code");
        SalesLine.Modify(true);

    end;
}