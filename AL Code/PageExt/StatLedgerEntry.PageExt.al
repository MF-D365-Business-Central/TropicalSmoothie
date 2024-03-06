pageextension 60011 "MFCCI01StatisticalLedgerEntry" extends "Statistical Ledger Entry List"
{
    layout
    {
        // Add changes to page layout here
        addfirst(Content)
        {
            field("Document No."; Rec."Document No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Document No. field.';
            }
            // field("Agreement No."; Rec."Agreement No.")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the value of the Agreement No. field.';
            // }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}