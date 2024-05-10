tableextension 60002 "MFCC01 G/L Entry" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here

        field(60001; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No.";
        }
        field(60002; "Source Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(60003; "Approver ID"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(60004; "Description 2"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }
}