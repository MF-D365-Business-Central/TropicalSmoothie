pageextension 60014 "BankAccountLedgerEntriesExt" extends "Bank Account Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Posting Date")
        {

            field("Document Date"; Rec."Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Document Date field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}