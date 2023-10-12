pageextension 60001 "MFCC01GenJournalImportExt" extends "General Journal"
{
    layout
    {
        addafter(Description)
        {

            field("Recipient Bank Account"; Rec."Recipient Bank Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.';
            }
            field("Agreement No."; Rec."Agreement No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Agreement No. field.';
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
        addfirst(Category_Process)
        {
            actionref(ImportFromExcel_Promoted; ImportFromExcel)
            {
            }
        }
    }
}
