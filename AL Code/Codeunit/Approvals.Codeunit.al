codeunit 60007 MFCC01Approvals
{
    trigger OnRun()
    begin

    end;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';

    [IntegrationEvent(false, false)]
    procedure OnSendVendorBankAccForApproval(var VendorBankAcc: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelVendorBankAccApprovalRequest(var VendorBankAcc: Record "Vendor Bank Account")
    begin
    end;

    procedure IsVendorBankAccApprovalsWorkflowEnabled(var VendorBankAcc: Record "Vendor Bank Account") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsVendorBankAccApprovalsWorkflowEnabled(VendorBankAcc, Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit(WorkflowManagement.CanExecuteWorkflow(VendorBankAcc, RunWorkflowOnSendVendorBankAccForApprovalCode()));
    end;

    procedure CheckVendorBankAccApprovalPossible(var VendorBankAcc: Record "Vendor Bank Account"): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckVendorBankAccApprovalPossible(VendorBankAcc, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not IsVendorBankAccApprovalsWorkflowEnabled(VendorBankAcc) then
            Error(NoWorkflowEnabledErr);


        OnAfterCheckVendorBankAccApprovalPossible(VendorBankAcc);

        exit(true);
    end;


    procedure RunWorkflowOnSendVendorBankAccForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDVENDORBANKACCFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelVendorBankAccApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELVENDORBANKACCAPPROVALREQUEST');
    end;

    procedure RunWorkflowOnAfterReleaseVendorBankAccCode(): Code[128]
    begin
        exit('RUNWORKFLOWONAFTERRELEASEVENDORBANKACC');
    end;

    procedure OpenApprovalsVandorBankAcc(var VendorBankAcc: Record "Vendor Bank Account")
    var
        AprrovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        AprrovalsMgmt.RunWorkflowEntriesPage(
            VendorBankAcc.RecordId(), DATABASE::"Vendor Bank Account", 0, VendorBankAcc.Code);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsVendorBankAccApprovalsWorkflowEnabled(var VendorBankAcc: Record "Vendor Bank Account"; var Result: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckVendorBankAccApprovalPossible(var VendorBankAcc: Record "Vendor Bank Account"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckVendorBankAccApprovalPossible(var VendorBankAcc: Record "Vendor Bank Account")
    begin
    end;
}