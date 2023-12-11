// profile "Journal"
// {
//     ProfileDescription = 'Journal';
//     RoleCenter = "Business Manager Role Center";
//     Customizations = "MFCC01General Journal";
//     Caption = 'Journal';
// }
// pagecustomization "MFCC01General Journal" customizes "General Journal"
// {
//     layout
//     {
//         modify("Document Type")
//         {
//             Visible = false;
//         }
//         modify("VAT Reporting Date")
//         {
//             Visible = false;
//         }
//         modify("Document Date")
//         {
//             Visible = false;
//         }
//         modify("Incoming Document Entry No.")
//         {
//             Visible = false;
//         }

//         modify("External Document No.")
//         {

//             Visible = false;
//         }
//         modify("Applies-to Ext. Doc. No.")
//         {

//             Visible = false;
//         }
//         modify(GenJnlLineApprovalStatus)
//         {

//             Visible = false;
//         }
//         // Add changes to page layout here
//         moveafter("Posting Date"; Comment)
//         moveafter(Comment; "Document No.")
//         moveafter("Document No."; "Account Type")
//         moveafter("Account Type"; "Account No.")
//         moveafter("Account No."; AccountName)
//         moveafter(AccountName; Description)
//         moveafter(Description; Amount)
//         moveafter(Amount; "Debit Amount")
//         moveafter("Debit Amount"; "Credit Amount")
//         moveafter("Credit Amount"; "Bal. Account Type")
//         moveafter("Bal. Account Type"; "Bal. Account No.")
//         moveafter("Bal. Account No."; "Deferral Code")
//         moveafter("Deferral Code"; Correction)
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     //Variables, procedures and triggers are not allowed on Page Customizations
// }