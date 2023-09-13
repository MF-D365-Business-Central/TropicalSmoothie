page 60011 "MFCC01 FranchiseLedgerEntries"
{
    Caption = 'Franchise Ledger Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 FranchiseLedgerEntry";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Agreement ID"; Rec."Agreement ID")
                {
                    ToolTip = 'Specifies the value of the Agreement ID field.';
                }
                field("Net Sales"; Rec."Net Sales")
                {
                    ToolTip = 'Specifies the value of the Net Sales field.';
                }
                field("Royalty Fee"; Rec."Royalty Fee")
                {
                    ToolTip = 'Specifies the value of the Royalty Fee field.';
                }
                field("Ad Fee"; Rec."Ad Fee")
                {
                    ToolTip = 'Specifies the value of the Ad Fee field.';
                }
                field("Other Fee"; Rec."Other Fee")
                {
                    ToolTip = 'Specifies the value of the Other Fee field.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
                field("Shortcut Dimension 3 Code"; Rec."Shortcut Dimension 3 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 3 Code field.';
                }
                field("Shortcut Dimension 4 Code"; Rec."Shortcut Dimension 4 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 4 Code field.';
                }
                field("Shortcut Dimension 5 Code"; Rec."Shortcut Dimension 5 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 5 Code field.';
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 6 Code field.';
                }
                field("Shortcut Dimension 7 Code"; Rec."Shortcut Dimension 7 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 7 Code field.';
                }
                field("Shortcut Dimension 8 Code"; Rec."Shortcut Dimension 8 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 8 Code field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Dimensions)
            {
                ApplicationArea = All;
                Image = Dimensions;
                trigger OnAction()
                begin
                    Rec.ShowDim();
                end;
            }
        }
    }


}