tableextension 60010 MFCC01CustLedgerEntry extends "Cust. Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(60001; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No." where("Customer No." = field("Customer No."));
        }
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

}