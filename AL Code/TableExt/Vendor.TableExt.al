// tableextension 60014 MFCC01Vendor extends Vendor
// {
//     fields
//     {
//         // Add changes to table fields here
//         field(60000; "First Time Approval"; Boolean)
//         {
//             DataClassification = CustomerContent;
//         }
//     }

//     keys
//     {
//         // Add changes to keys here
//     }

//     fieldgroups
//     {
//         // Add changes to field groups here
//     }


//     trigger OnBeforeDelete()
//     Begin
//         Rec."First Time Approval" := True;
//     End;
// }