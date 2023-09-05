pageextension 60001 "Gen Journal Import Ext" extends "General Journal"
{
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
        addfirst(Category_Process)
        {
            actionref(ImportFromExcel_Promoted; ImportFromExcel)
            {
            }
        }
    }
}
