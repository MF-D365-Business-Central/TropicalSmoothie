pageextension 60001 "MFCC01GenJournalImportExt" extends "General Journal"
{
    layout
    {

        modify("Document Type")
        {
            Visible = false;
        }
        modify("VAT Reporting Date")
        {
            Visible = false;
        }
        modify("Document Date")
        {
            Visible = false;
        }
        modify("Incoming Document Entry No.")
        {
            Visible = false;
        }

        modify("External Document No.")
        {
            Visible = false;
        }
        modify("Applies-to Ext. Doc. No.")
        {
            Visible = false;
        }
        modify(GenJnlLineApprovalStatus)
        {
            Visible = false;
        }

        modify("Gen. Posting Type")
        {
            Visible = false;
        }
        modify("Gen. Bus. Posting Group")
        {
            Visible = false;
        }
        modify("Gen. Prod. Posting Group")
        {
            Visible = false;
        }
        modify("Tax Liable")
        {
            Visible = false;
        }
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Tax Group Code")
        {
            Visible = false;
        }
        modify("Bal. Gen. Posting Type")
        {
            Visible = false;
        }
        modify("Bal. Gen. Bus. Posting Group")
        {
            Visible = false;
        }
        modify("Bal. Gen. Prod. Posting Group")
        {
            Visible = false;
        }
        modify("Amount (LCY)")
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }

        modify("Transaction Information")
        {
            Visible = true;
        }

        modify("Payer Information")
        {
            Visible = true;
        }
        addafter(Description)
        {
            field("Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
            }
        }
        // Add changes to page layout here
        moveafter("Posting Date"; Comment)
        moveafter(Comment; "Document No.")
        moveafter("Document No."; "Account Type")
        moveafter("Account Type"; "Account No.")
        moveafter("Account No."; AccountName)
        moveafter(AccountName; Description)
        moveafter("Description 2"; "Debit Amount")
        moveafter("Debit Amount"; "Credit Amount")
        moveafter("Credit Amount"; Amount)
        moveafter(Amount; "Payer Information")
        moveafter("Payer Information"; "Transaction Information")
        moveafter("Transaction Information"; "Bal. Account Type")
        moveafter("Bal. Account Type"; "Bal. Account No.")
        moveafter("Bal. Account No."; "Deferral Code")
        moveafter("Deferral Code"; Correction)
        modify(ShortcutDimCode3)
        {
            trigger OnAfterValidate()
            Begin
                CurrPage.Update();
            End;
        }
        // addafter(Description)
        // {
        //     field("Recipient Bank Account"; Rec."Recipient Bank Account")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.';
        //     }
        //     field("Agreement No."; Rec."Agreement No.")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Agreement No. field.';
        //     }
        // }
        addlast(Control1)
        {
            field("Approver ID"; Rec."Approver ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Approver ID field.';
            }
        }
    }
    actions
    {
        addafter(Dimensions)
        {
            action(ImportFromExcel)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    GenJournalExcelImport: Report "Gen. Journal Excel Import";
                begin
                    GenJournalExcelImport.SetValues(Rec."Journal Template Name", rec."Journal Batch Name");
                    GenJournalExcelImport.RunModal();
                end;
            }
        }
        addfirst(Category_Process)
        {
            actionref(ImportFromExcel_Promoted; ImportFromExcel)
            {
            }
        }
    }
}
