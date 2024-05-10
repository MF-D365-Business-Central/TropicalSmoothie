tableextension 60011 "MFCC01InvoicePostingBuffer" extends "Invoice Posting Buffer"
{
    fields
    {
        // Add changes to table fields here
        field(60005; "Description 2"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

}