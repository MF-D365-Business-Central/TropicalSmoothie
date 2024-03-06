pageextension 60012 "MFCCI01StatisticalAccJournal" extends "Statistical Accounts Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
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