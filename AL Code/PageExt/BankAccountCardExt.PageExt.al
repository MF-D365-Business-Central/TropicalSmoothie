pageextension 60008 "Bank Account Card Ext" extends "Bank Account Card"
{
    layout
    {
        addlast(Transfer)
        {
            field("Receivables Export Format"; Rec."Receivables Export Format")
            {
                ApplicationArea = all;
                ToolTip = 'Receivables Export Format';
            }
            field("E-Recevbl Exp. File Name"; Rec."E-Recevbl Exp. File Name")
            {
                ApplicationArea = all;
                ToolTip = 'E-Receivables Export File Name';
            }
            field("EFT Export Code Format"; Rec."EFT Export Code Format")
            {
                ApplicationArea = all;
                ToolTip = 'EFT Export Code Format';
            }
        }
    }


    actions
    {
        // Add changes to page actions here
    }


}