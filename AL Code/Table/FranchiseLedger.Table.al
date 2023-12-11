table 60009 "MFCC01 FranchiseLedgerEntry"
{
    Caption = 'Franchise Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Franchise Batch".Code;
        }
        field(2; "Batch Name"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Franchise Batch".Code;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;

        }
        field(4; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Document Date"; Date)
        {
            DataClassification = CustomerContent;

        }
        field(6; "Document Type"; Enum "MFCC01 Franchise Document Type")
        {
            DataClassification = CustomerContent;

        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(12; "Agreement ID"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No.";
        }
        field(13; "Net Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Royalty Fee"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Local Fee"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; "National Fee"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
        }
        field(34; "Shortcut Dimension 3 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(3));
        }
        field(35; "Shortcut Dimension 4 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(4));
        }
        field(36; "Shortcut Dimension 5 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,5';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(5));
        }
        field(37; "Shortcut Dimension 6 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,6';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(6));
        }
        field(38; "Shortcut Dimension 7 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,7';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(7));
        }
        field(39; "Shortcut Dimension 8 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,8';
            TableRelation = "Dimension Set Entry"."Dimension Value Code" where("Dimension Value ID" = field("Dimension Set ID"), "Global Dimension No." = const(8));
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

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption(), "Entry No."));
    end;

}