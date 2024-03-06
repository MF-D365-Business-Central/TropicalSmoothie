pageextension 60009 "MFCCI01RecurringGeneralJournal" extends "Recurring General Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(Dimensions)
        {
            action(ImportFromExcel)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    GenJournalExcelImport: Report "Gen. Journal Excel Import";
                begin
                    GenJournalExcelImport.SetValues(Rec."Journal Template Name", rec."Journal Batch Name");
                    GenJournalExcelImport.RunModal();
                end;
            }
        }
    }

    var
        myInt: Integer;
}