tableextension 60010 MFCC01CustLedgerEntry extends "Cust. Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
    }

    keys
    {
        // Add changes to keys here
        key(Bank; "Customer No.", "Recipient Bank Account")
        {

        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}