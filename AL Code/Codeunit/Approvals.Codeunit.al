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
        ApprovalReqCanceledForSelectedLinesMsg: Label 'The approval request for the selected record has been canceled.';
        PendingJournalBatchApprovalExistsErr: Label 'An approval request already exists.', Comment = '%1 is the Document No. of the journal line';
        ApprovedJournalBatchApprovalExistsMsg: Label 'An approval request for this batch has already been sent and approved. Do you want to send another approval request?';

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


    [IntegrationEvent(false, false)]
    local procedure OnHasOpenApprovalEntriesForCurrentUserOnAfterSetApprovalEntryFilters(var ApprovalEntry: Record "Approval Entry")
    begin
    end;


    procedure RunWorkflowOnSendStatJournalBatchForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDStatJournalBATCHFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelStatJournalBatchApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELStatJournalBATCHAPPROVALREQUEST');
    end;

    procedure RunWorkflowOnSendStatJournalLineForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDStatJournalLINEFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelStatJournalLineApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELStatJournalLINEAPPROVALREQUEST');
    end;

    procedure RunWorkflowOnStatJournalBatchBalancedCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSTATJournalBATCHBALANCED');
    end;

    procedure RunWorkflowOnStatJournalBatchNotBalancedCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSTATJournalBATCHNOTBALANCED');
    end;

    procedure CheckStatJournalBatchBalanceCode(): Code[128]
    begin
        exit('CHECKSTATJOURNALBATCHBALANCE');
    end;

    procedure ApproveStatJournalLineRequest(StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        StatJournalBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name");
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalBatch.RecordId) then
            ApprovalMgmt.ApproveRecordApprovalRequest(StatJournalBatch.RecordId);
        Clear(ApprovalEntry);
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalLine.RecordId) then
            ApprovalMgmt.ApproveRecordApprovalRequest(StatJournalLine.RecordId);
    end;

    procedure RejectStatJournalLineRequest(StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        StatJournalBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name");
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalBatch.RecordId) then
            ApprovalMgmt.RejectRecordApprovalRequest(StatJournalBatch.RecordId);
        Clear(ApprovalEntry);
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalLine.RecordId) then
            ApprovalMgmt.RejectRecordApprovalRequest(StatJournalLine.RecordId);
    end;

    procedure DelegateStatJournalLineRequest(StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        StatJournalBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name");
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalBatch.RecordId) then
            ApprovalMgmt.DelegateRecordApprovalRequest(StatJournalBatch.RecordId);
        Clear(ApprovalEntry);
        if ApprovalMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, StatJournalLine.RecordId) then
            ApprovalMgmt.DelegateRecordApprovalRequest(StatJournalLine.RecordId);
    end;

    local procedure IsSufficientStatJournalLineApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry") Result: Boolean
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
        RecRef: RecordRef;
        IsHandled: Boolean;
    begin
        RecRef.Get(ApprovalEntryArgument."Record ID to Approve");
        RecRef.SetTable(StatJournalLine);

        IsHandled := false;
        OnIsSufficientStatJournalLineApproverOnAfterRecRefSetTable(UserSetup, ApprovalEntryArgument, StatJournalLine, Result, IsHandled);
        if IsHandled then
            exit;

        exit(IsSufficientGLAccountApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)"));

        exit(true);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnIsSufficientStatJournalLineApproverOnAfterRecRefSetTable(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; StatJournalLine: Record "Statistical Acc. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure OnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean; var IsHandled: Boolean)
    begin
        case ApprovalEntryArgument."Table ID" of
            DATABASE::"Statistical Acc. Journal Line", Database::"Statistical Acc. Journal Batch":
                Begin
                    IsSufficient := IsSufficientGLAccountApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
                    IsHandled := true;
                End;
        end;
    end;

    local procedure IsSufficientGLAccountApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Unlimited Request Approval" or
            ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and (UserSetup."Request Amount Approval Limit" <> 0))
        then
            exit(true);

        exit(false);
    end;

    procedure IsStatJournalLineApprovalsWorkflowEnabled(var StatJournalLine: Record "Statistical Acc. Journal Line") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsStatJournalLineApprovalsWorkflowEnabled(StatJournalLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(WorkflowManagement.CanExecuteWorkflow(StatJournalLine,
            RunWorkflowOnSendStatJournalLineForApprovalCode()));
    end;

    procedure CheckStatJournalLineApprovalsWorkflowEnabled(var StatJournalLine: Record "Statistical Acc. Journal Line"): Boolean
    begin
        if not
           WorkflowManagement.CanExecuteWorkflow(StatJournalLine,
             RunWorkflowOnSendStatJournalLineForApprovalCode())
        then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Stat. Acc. Jnl. Line Post", 'OnBeforeInsertStatisticalLedgerEntry', '', false, false)]
    procedure PostApprovalEntriesMoveStatJournalLine(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    begin
        ApprovalMgmt.PostApprovalEntries(StatisticalAccJournalLine.RecordId, StatisticalLedgerEntry.RecordId, StatisticalAccJournalLine."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    procedure DeleteApprovalEntriesAfterDeleteStatJournalLine(var Rec: Record "Statistical Acc. Journal Line"; RunTrigger: Boolean)
    begin
        if not Rec.IsTemporary then
            ApprovalMgmt.DeleteApprovalEntries(Rec.RecordId);
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Batch", 'OnMoveStatJournalBatch', '', false, false)]
    // procedure PostApprovalEntriesMoveStatJournalBatch(var Sender: Record "Statistical Acc. Journal Batch"; ToRecordID: RecordID)
    // var
    //     RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    // begin
    //     if ApprovalMgmt.PostApprovalEntries(Sender.RecordId, ToRecordID, '') then begin
    //         RecordRestrictionMgt.AllowRecordUsage(Sender);
    //         ApprovalMgmt.DeleteApprovalEntries(Sender.RecordId);
    //     end;
    // end; RGU

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Batch", 'OnAfterDeleteEvent', '', false, false)]
    procedure DeleteApprovalEntriesAfterDeleteStatJournalBatch(var Rec: Record "Statistical Acc. Journal Batch"; RunTrigger: Boolean)
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        if Rec.IsTemporary then
            exit;

        if GenJnlTemplate.Get(Rec."Journal Template Name") then
            if not GenJnlTemplate."Increment Batch Name" then
                ApprovalMgmt.DeleteApprovalEntries(Rec.RecordId);
    end;

    procedure HasAnyOpenJournalLineApprovalEntries(JournalTemplateName: Code[20]; JournalBatchName: Code[20]): Boolean
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
        ApprovalEntry: Record "Approval Entry";
        StatJournalLineRecRef: RecordRef;
        StatJournalLineRecordID: RecordID;
    begin
        ApprovalEntry.SetRange("Table ID", DATABASE::"Statistical Acc. Journal Line");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Related to Change", false);
        OnHasAnyOpenJournalLineApprovalEntriesOnAfterApprovalEntrySetFilters(ApprovalEntry);
        if ApprovalEntry.IsEmpty() then
            exit(false);

        StatJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        StatJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if StatJournalLine.IsEmpty() then
            exit(false);

        if StatJournalLine.Count < ApprovalEntry.Count then begin
            StatJournalLine.FindSet();
            repeat
                if ApprovalMgmt.HasOpenApprovalEntries(StatJournalLine.RecordId) then
                    exit(true);
            until StatJournalLine.Next() = 0;
        end else begin
            ApprovalEntry.FindSet();
            repeat
                StatJournalLineRecordID := ApprovalEntry."Record ID to Approve";
                StatJournalLineRecRef := StatJournalLineRecordID.GetRecord();
                StatJournalLineRecRef.SetTable(StatJournalLine);
                if (StatJournalLine."Journal Template Name" = JournalTemplateName) and
                   (StatJournalLine."Journal Batch Name" = JournalBatchName)
                then
                    exit(true);
            until ApprovalEntry.Next() = 0;
        end;

        exit(false)
    end;

    procedure TrySendJournalBatchApprovalRequest(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        GetStatJournalBatch(StatJournalBatch, StatJournalLine);
        CheckStatJournalBatchApprovalsWorkflowEnabled(StatJournalBatch);
        if ApprovalMgmt.HasOpenApprovalEntries(StatJournalBatch.RecordId) or
           HasAnyOpenJournalLineApprovalEntries(StatJournalBatch."Journal Template Name", StatJournalBatch.Name)
        then
            Error(PendingJournalBatchApprovalExistsErr);
        if ApprovalMgmt.HasApprovedApprovalEntries(StatJournalBatch.RecordId) then
            if not Confirm(ApprovedJournalBatchApprovalExistsMsg) then
                exit;
        OnSendStatJournalBatchForApproval(StatJournalBatch);
    end;

    procedure CheckStatJournalBatchApprovalsWorkflowEnabled(var StatJournalBatch: Record "Statistical Acc. Journal Batch"): Boolean
    begin
        if not
           WorkflowManagement.CanExecuteWorkflow(StatJournalBatch,
             RunWorkflowOnSendStatJournalBatchForApprovalCode())
        then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    procedure TrySendJournalLineApprovalRequests(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
        OnBeforeTrySendJournalLineApprovalRequests(StatJournalLine);
        if StatJournalLine.Count = 1 then
            CheckStatJournalLineApprovalsWorkflowEnabled(StatJournalLine);

        repeat
            OnTrySendJournalLineApprovalRequestsOnBeforeLoopIteration(StatJournalLine);
            if WorkflowManagement.CanExecuteWorkflow(StatJournalLine,
                 RunWorkflowOnSendStatJournalLineForApprovalCode()) and
               not ApprovalMgmt.HasOpenApprovalEntries(StatJournalLine.RecordId)
            then begin
                OnSendStatJournalLineForApproval(StatJournalLine);
            end;
        until StatJournalLine.Next() = 0;
    end;

    procedure TryCancelJournalBatchApprovalRequest(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        GetStatJournalBatch(StatJournalBatch, StatJournalLine);
        OnCancelStatJournalBatchApprovalRequest(StatJournalBatch);
        WorkflowWebhookManagement.FindAndCancel(StatJournalBatch.RecordId);
    end;

    procedure TryCancelJournalLineApprovalRequests(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        repeat
            if ApprovalMgmt.HasOpenApprovalEntries(StatJournalLine.RecordId) then
                OnCancelStatJournalLineApprovalRequest(StatJournalLine);
            WorkflowWebhookManagement.FindAndCancel(StatJournalLine.RecordId);
        until StatJournalLine.Next() = 0;
        Message(ApprovalReqCanceledForSelectedLinesMsg);
    end;

    procedure ShowJournalApprovalEntries(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        ApprovalEntry: Record "Approval Entry";
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        GetStatJournalBatch(StatJournalBatch, StatJournalLine);

        ApprovalEntry.SetFilter("Table ID", '%1|%2', DATABASE::"Statistical Acc. Journal Batch", DATABASE::"Statistical Acc. Journal Line");
        ApprovalEntry.SetFilter("Record ID to Approve", '%1|%2', StatJournalBatch.RecordId, StatJournalLine.RecordId);
        ApprovalEntry.SetRange("Related to Change", false);
        PAGE.Run(PAGE::"Approval Entries", ApprovalEntry);
    end;

    local procedure GetStatJournalBatch(var StatJournalBatch: Record "Statistical Acc. Journal Batch"; var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
        if not StatJournalBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name") then
            StatJournalBatch.Get(StatJournalLine.GetFilter("Journal Template Name"), StatJournalLine.GetFilter("Journal Batch Name"));
    end;

    procedure SendJournalLinesApprovalRequests(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := StatJournalLine.Count();

        if NoOfSelected = 1 then begin
            TrySendJournalLineApprovalRequests(StatJournalLine);
            exit;
        end;

        repeat
            if not ApprovalMgmt.HasOpenApprovalEntries(StatJournalLine.RecordId) then
                StatJournalLine.Mark(true);
        until StatJournalLine.Next() = 0;
        StatJournalLine.MarkedOnly(true);
        if StatJournalLine.Find('-') then;
        NoOfSkipped := NoOfSelected - StatJournalLine.Count();
        BatchProcessingMgt.BatchProcess(StatJournalLine, Codeunit::"Approvals Journal Line Request", Enum::"Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnHasAnyOpenJournalLineApprovalEntriesOnAfterApprovalEntrySetFilters(var ApprovalEntry: Record "Approval Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendStatJournalBatchForApproval(var StatJournalBatch: Record "Statistical Acc. Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStatJournalBatchApprovalRequest(var StatJournalBatch: Record "Statistical Acc. Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendStatJournalLineForApproval(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStatJournalLineApprovalRequest(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsStatJournalLineApprovalsWorkflowEnabled(var StatJournalLine: Record "Statistical Acc. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrySendJournalLineApprovalRequestsOnBeforeLoopIteration(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTrySendJournalLineApprovalRequests(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
    end;
}