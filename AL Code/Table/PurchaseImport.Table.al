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

        field(3; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }

        field(4; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Invoice Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Due Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(7; "External Document No."; Code[20])
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
        field(93; "Market Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(94; "Cafe Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(100; Remarks; Text[500])
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
        PurchHeader."No." := '';
        //Keys <<
        PurchHeader.Insert(true);
        PurchHeader.SetHideValidationDialog(True);
        PurchHeader.Validate("Buy-from Vendor No.", Rec."Vendor No.");
        PurchHeader.Validate("Document Date", Rec."Invoice Date");
        PurchHeader.Validate("Posting Date", Rec."Posting Date");
        PurchHeader.Validate("Payment Terms Code", '');
        PurchHeader.Validate("Due Date", Rec."Due Date");
        IF Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
            PurchHeader."Vendor Cr. Memo No." := Rec."External Document No."
        else
            PurchHeader."Vendor Invoice No." := Rec."External Document No.";
        PurchHeader.Modify(true);

    end;

    procedure CreatePurchLine(Var LineNo: Integer; PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.init();
        //Keys >>
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := LineNo;
        LineNo += 10000;
        //Keys <<
        PurchLine.Insert(true);
        PurchLine.Validate("Type", PurchLine.Type::"G/L Account");
        PurchLine.Validate("No.", Rec."No.");
        PurchLine.Description := Rec.Description;
        PurchLine.Validate(Quantity, Rec.Quantity);
        PurchLine.Validate("Direct Unit Cost", Rec."Direct Unit Cost");
        IF Rec."Department Code" <> '' then
            PurchLine.Validate("Shortcut Dimension 1 Code", Rec."Department Code");
        IF Rec."Market Code" <> '' then
            PurchLine.Validate("Shortcut Dimension 2 Code", Rec."Market Code");
        IF Rec."Cafe Code" <> '' then
            PurchLine.ValidateShortcutDimCode(3, Rec."Cafe Code");
        PurchLine.Modify(true);

    end;

    local procedure GetSetId(Var DimSetID: Integer)
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin

    end;
}