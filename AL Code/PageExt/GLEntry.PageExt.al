pageextension 60004 "MFCC01General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
            field("Agreement No."; Rec."Agreement No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Agreement No. field.';
            }
        }
        addafter("Source No.")
        {
            
            field("Source Name"; Rec."Source Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Source Name field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}