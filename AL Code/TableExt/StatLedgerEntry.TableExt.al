tableextension 60008 "MFCC01Statistical Ledger Entry" extends "Statistical Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(60000; "Agreement No."; Code[20])
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

    var
        myInt: Integer;
}