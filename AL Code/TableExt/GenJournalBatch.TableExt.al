tableextension 60006 "MFCC01Gen. Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(60000; "Allow Cash Receipt"; Boolean)
        {
            Caption = 'Allow Cash Receipt Export';
            DataClassification = CustomerContent;
        }
    }
}