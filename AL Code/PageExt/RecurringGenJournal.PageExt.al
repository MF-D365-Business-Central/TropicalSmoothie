pageextension 60009 "MFCCI01RecurringGeneralJournal" extends "Recurring General Journal"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Account Type")
        {
            field("Transaction Information"; Rec."Transaction Information")
            {
                ApplicationArea = All;
            }
            field("Payer Information"; Rec."Payer Information")
            {
                ApplicationArea = All;
            }
        }
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