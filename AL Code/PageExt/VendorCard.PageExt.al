pageextension 60018 MFCC01VendorCard extends "Vendor Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Balance (LCY)")
        {

            field("Purchases (LCY)"; Rec."Purchases (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Purchases (LCY) field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify(SendApprovalRequest)
        {
            trigger OnAfterAction()
            var
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                MFCC01Approvals: Codeunit MFCC01Approvals;
                VendorBank: Record "Vendor Bank Account";
            begin
                if ApprovalsMgmt.CheckVendorApprovalsWorkflowEnabled(Rec) then Begin
                    VendorBank.SetRange("Vendor No.", Rec."No.");
                    VendorBank.SetRange("First Time Approval", true);
                    VendorBank.SetRange(Status, VendorBank.Status::Open);
                    IF VendorBank.FindFirst() then
                        if MFCC01Approvals.IsVBAApprovalsWorkflowEnabled(VendorBank) then
                            MFCC01Approvals.OnSendVBADocForApproval(VendorBank);
                End;

            End;
        }
        modify(CancelApprovalRequest)
        {

            trigger OnAfterAction()
            var
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                MFCC01Approvals: Codeunit MFCC01Approvals;
                VendorBank: Record "Vendor Bank Account";
            begin
                VendorBank.SetRange("Vendor No.", Rec."No.");
                VendorBank.SetRange("First Time Approval", true);
                VendorBank.SetRange(Status, VendorBank.Status::"Pending Approval");
                IF VendorBank.FindFirst() then
                    MFCC01Approvals.OnCancelVBAApprovalRequest(VendorBank);

            End;
        }
    }



}