pageextension 60006 "MFCC01GeneralJournalBatches" extends "General Journal Batches"
{
    layout
    {
        // modify("Allow Payment Export")
        // {
        //     //Visible = false;
        // }
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Allow Cash Receipt"; Rec."Allow Cash Receipt")
            {
                ApplicationArea = all;
                ToolTip = 'Allow Cash Receipt Export';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    var
        IsPaymentTemplate: Boolean;

    trigger OnOpenPage()
    Begin
        ShowAllowPaymentExportForPaymentTemplate
    End;

    local procedure ShowAllowPaymentExportForPaymentTemplate()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        if GenJournalTemplate.Get(Rec."Journal Template Name") then
            IsPaymentTemplate := (GenJournalTemplate.Type = GenJournalTemplate.Type::Payments)
            OR
            (GenJournalTemplate.Type = GenJournalTemplate.Type::"Cash Receipts");
    end;
}