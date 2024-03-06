tableextension 60009 "MFCC01StatisticalAccJournal" extends "Statistical Acc. Journal Line"
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