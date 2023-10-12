tableextension 60001 "MFCC01 Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here

        field(60001; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No." where("Customer No." = field("Account No."), Status = const(Opened));
        }
    }


}