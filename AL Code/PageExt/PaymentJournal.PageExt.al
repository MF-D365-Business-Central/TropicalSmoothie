pageextension 60005 "MFCC01Payment Journal" extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
        modify(Control1900383207)
        {
            Visible = True;
        }
        modify(Control1905767507)
        {
            Visible = true;
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(ApplyEntries)
        {
            action(AmexExport)
            {
                ApplicationArea = All;
                Caption = 'Amex Export';
                Image = Export;
                trigger OnAction()
                var
                    GenJnLine: Record "Gen. Journal Line";
                Begin
                    GenJnLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJnLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    Report.RunModal(Report::"Amex Export", true, false, GenJnLine);
                End;
            }
        }
    }
}