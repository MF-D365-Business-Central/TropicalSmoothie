page 60023 StatisticalLedger
{
    PageType = List;
    SourceTable = "Statistical Ledger Entry";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            Repeater(Control1)
            {

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date of the ledger entry.';
                }
                field("Statistical Account No."; Rec."Statistical Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the statistical account number of the ledger entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the ledger entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the ledger entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the ledger entry.';
                }
                field(DEPT; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Global Dimension 1, which is one of dimension codes that you set up in the General Ledger Setup window.';
                }
                field(MARKET; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Global Dimension 2, which is one of dimension codes that you set up in the General Ledger Setup window.';
                }
                field(CAFE; Rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 3, which is one of dimension codes that you set up in the General Ledger Setup window.';
                }
                field(FMM; Rec."Shortcut Dimension 4 Code")
                {

                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 4, which is one of dimension codes that you set up in the General Ledger Setup window.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }


}