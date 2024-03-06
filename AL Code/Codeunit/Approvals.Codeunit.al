codeunit 60007 MFCC01Approvals
{
    trigger OnRun()
    begin
    end;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponse: Codeunit "Workflow Response Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        DocStatusChangedMsg: Label '%1 %2 has been automatically approved. The status has been changed to %3.', Comment = 'Order 1001 has been automatically approved. The status has been changed to Released.';
        PendingApprovalMsg: Label 'An approval request has been sent.';

    [IntegrationEvent(false, false)]
    procedure OnSendVBADocForApproval(var VBA: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelVBAApprovalRequest(var VBA: Record "Vendor Bank Account")
    begin
    end;

    local procedure ShowVBAApprovalStatus(VBA: Record "Vendor Bank Account")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowVBAApprovalStatus(VBA, IsHandled);
        if IsHandled then
            exit;

        VBA.Find();

        case VBA.Status of
            VBA.Status::Released:
                Message(DocStatusChangedMsg, 0, VBA.Code, VBA.Status);
            VBA.Status::"Pending Approval":
                if ApprovalMgmt.HasOpenOrPendingApprovalEntries(VBA.RecordId) then
                    Message(PendingApprovalMsg);
        end;
    end;

    procedure IsVBAApprovalsWorkflowEnabled(var VBA: Record "Vendor Bank Account"): Boolean
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(VBA, RunWorkflowOnSendVBADocForApprovalCode()));
    end;

    procedure IsVBAPendingApproval(var VBA: Record "Vendor Bank Account"): Boolean
    begin
        if VBA.Status <> VBA.Status::Open then
            exit(false);

        exit(IsVBAApprovalsWorkflowEnabled(VBA));
    end;

    procedure CheckVBAApprovalPossible(var VBA: Record "Vendor Bank Account"): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckVBAApprovalPossible(VBA, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not IsVBAApprovalsWorkflowEnabled(VBA) then
            Error(NoWorkflowEnabledErr);

        OnAfterCheckVBAApprovalPossible(VBA);

        exit(true);
    end;

    procedure InformUserOnStatusChange(Variant: Variant; WorkflowInstanceId: Guid)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);

        case RecRef.Number of

            DATABASE::"Vendor Bank Account":
                ShowVBAApprovalStatus(Variant);
        end;
    end;

    procedure OpenApprovalsVBA(VBA: Record "Vendor Bank Account")

    begin
        ApprovalMgmt.RunWorkflowEntriesPage(
            VBA.RecordId(), DATABASE::"Vendor Bank Account", 0, VBA.Code);
    end;

    procedure RunWorkflowOnSendVBADocForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDVBADOCFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelVBAApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELVBAAPPROVALREQUEST');
    end;

    procedure RunWorkflowOnAfterReleaseVBADocCode(): Code[128]
    begin
        exit('RUNWORKFLOWONAFTERRELEASEVBADOC');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowVBAApprovalStatus(var VBA: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckVBAApprovalPossible(var vba: Record "Vendor Bank Account"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckVBAApprovalPossible(var vba: Record "Vendor Bank Account")
    begin
    end;
}