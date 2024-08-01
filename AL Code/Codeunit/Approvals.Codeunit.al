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
    var
        ApporvalChainIsUnsupportedMsg: Label 'Only Direct Approver is supported as Approver Limit Type option for %1. The approval request will be approved automatically.', Comment = 'Only Direct Approver is supported as Approver Limit Type option for Stat. Journal Batch DEFAULT, CASH. The approval request will be approved automatically.';

    begin
        case ApprovalEntryArgument."Table ID" of
            DATABASE::"Statistical Acc. Journal Line":
                Begin
                    IsSufficient := IsSufficientGLAccountApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
                    IsHandled := true;
                End;
        end;
        if not IsHandled then
            if ApprovalEntryArgument."Table ID" = Database::"Statistical Acc. Journal Batch" then
                Message(ApporvalChainIsUnsupportedMsg, Format(ApprovalEntryArgument."Record ID to Approve"));

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

    procedure IsStatJournalBatchApprovalsWorkflowEnabled(var StatJournalBatch: Record "Statistical Acc. Journal Batch") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsStatJournalBatchApprovalsWorkflowEnabled(StatJournalBatch, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(WorkflowManagement.CanExecuteWorkflow(StatJournalBatch,
            RunWorkflowOnSendStatJournalBatchForApprovalCode()));
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsStatJournalBatchApprovalsWorkflowEnabled(var StatJournalBatch: Record "Statistical Acc. Journal Batch"; var Result: Boolean; var IsHandled: Boolean)
    begin
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


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Stat. Acc. Jnl. Line Post", 'OnBeforeInsertStatisticalLedgerEntry', '', false, false)]
    // procedure PostApprovalEntriesMoveStatJournalLine(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    // begin
    //     ApprovalMgmt.PostApprovalEntries(StatisticalAccJournalLine.RecordId, StatisticalLedgerEntry.RecordId, StatisticalAccJournalLine."Document No.");
    // end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    procedure DeleteApprovalEntriesAfterDeleteStatJournalLine(var Rec: Record "Statistical Acc. Journal Line"; RunTrigger: Boolean)
    var
        StatAccJnlBatch: Record "Statistical Acc. Journal Batch";
    begin
        if Rec.IsTemporary then
            exit;
        IF StatAccJnlBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
            ApprovalMgmt.DeleteApprovalEntries(StatAccJnlBatch.RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Stat. Acc. Jnl. Line Post", 'OnBeforeInsertStatisticalLedgerEntry', '', false, false)]
    procedure PostApprovalEntriesMoveStatJournalBatch(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
        StatAccJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        IF StatAccJournalBatch.Get(StatisticalAccJournalLine."Journal Template Name", StatisticalAccJournalLine."Journal Batch Name") then
            if ApprovalMgmt.PostApprovalEntries(StatAccJournalBatch.RecordId, StatisticalLedgerEntry.RecordId, '') then begin
                RecordRestrictionMgt.AllowRecordUsage(StatAccJournalBatch);
                ApprovalMgmt.DeleteApprovalEntries(StatAccJournalBatch.RecordId);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Batch", 'OnAfterDeleteEvent', '', false, false)]
    procedure DeleteApprovalEntriesAfterDeleteStatJournalBatch(var Rec: Record "Statistical Acc. Journal Batch"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
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


    procedure GetStatJnlBatchApprovalStatus(StatJournalLine: Record "Statistical Acc. Journal Line"; var GenJnlBatchApprovalStatus: Text[20]; EnabledstatJnlBatchWorkflowsExist: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        Clear(GenJnlBatchApprovalStatus);
        if not EnabledstatJnlBatchWorkflowsExist then
            exit;
        if not StatJournalBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name") then
            exit;

        if ApprovalMgmt.FindApprovalEntryByRecordId(ApprovalEntry, StatJournalBatch.RecordId) then
            GenJnlBatchApprovalStatus := GetApprovalStatusFromApprovalEntry(ApprovalEntry, StatJournalBatch);
    end;

    procedure GetGenJnlLineApprovalStatus(StaJournalLine: Record "Statistical Acc. Journal Line"; var StatJnlLineApprovalStatus: Text[20]; EnabledGenJnlLineWorkflowsExist: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        Clear(StatJnlLineApprovalStatus);
        if not EnabledGenJnlLineWorkflowsExist then
            exit;

        if ApprovalMgmt.FindApprovalEntryByRecordId(ApprovalEntry, StaJournalLine.RecordId) then
            StatJnlLineApprovalStatus := GetApprovalStatusFromApprovalEntry(ApprovalEntry, StaJournalLine);
    end;

    local procedure GetApprovalStatusFromApprovalEntry(var ApprovalEntry: Record "Approval Entry"; StatJournalBatch: Record "Statistical Acc. Journal Batch"): Text[20]
    var
        RestrictedRecord: Record "Restricted Record";
        StatJournalLine: Record "Statistical Acc. Journal Line";
        FieldRef: FieldRef;
        ApprovalStatusName: Text;
    begin
        GetApprovalEntryStatusFieldRef(FieldRef, ApprovalEntry);
        ApprovalStatusName := GetApprovalEntryStatusValueName(FieldRef, ApprovalEntry);
        if ApprovalStatusName = 'Open' then
            exit(CopyStr(PendingApprovalLbl, 1, 20));
        if ApprovalStatusName = 'Approved' then begin
            RestrictedRecord.SetRange(Details, RestrictBatchUsageDetailsLbl);
            if not RestrictedRecord.IsEmpty() then begin
                RestrictedRecord.Reset();
                StatJournalLine.ReadIsolation(IsolationLevel::ReadUncommitted);
                StatJournalLine.SetLoadFields("Journal Template Name", "Journal Batch Name", "Line No.");
                StatJournalLine.SetRange("Journal Template Name", StatJournalBatch."Journal Template Name");
                StatJournalLine.SetRange("Journal Batch Name", StatJournalBatch.Name);
                if StatJournalLine.FindSet() then
                    repeat
                        RestrictedRecord.SetRange("Record ID", StatJournalLine.RecordId);
                        if not RestrictedRecord.IsEmpty() then
                            exit(CopyStr(ImposedRestrictionLbl, 1, 20));
                    until StatJournalLine.Next() = 0;
            end;
        end;
        exit(CopyStr(GetApprovalEntryStatusValueCaption(FieldRef, ApprovalEntry), 1, 20));
    end;

    var
        PendingApprovalLbl: Label 'Pending Approval';
        RestrictBatchUsageDetailsLbl: Label 'The restriction was imposed because the journal batch requires approval.';
        ImposedRestrictionLbl: Label 'Imposed restriction';

    local procedure GetApprovalStatusFromApprovalEntry(var ApprovalEntry: Record "Approval Entry"; StatJournalLine: Record "Statistical Acc. Journal Line"): Text[20]
    var
        RestrictedRecord: Record "Restricted Record";
        FieldRef: FieldRef;
        ApprovalStatusName: Text;
    begin
        GetApprovalEntryStatusFieldRef(FieldRef, ApprovalEntry);
        ApprovalStatusName := GetApprovalEntryStatusValueName(FieldRef, ApprovalEntry);
        if ApprovalStatusName = 'Open' then
            exit(CopyStr(PendingApprovalLbl, 1, 20));
        if ApprovalStatusName = 'Approved' then begin
            RestrictedRecord.SetRange("Record ID", StatJournalLine.RecordId);
            if not RestrictedRecord.IsEmpty() then
                exit(CopyStr(ImposedRestrictionLbl, 1, 20));
        end;
        exit(CopyStr(GetApprovalEntryStatusValueCaption(FieldRef, ApprovalEntry), 1, 20));
    end;

    local procedure GetApprovalEntryStatusFieldRef(var FieldRef: FieldRef; var ApprovalEntry: Record "Approval Entry")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(ApprovalEntry);
        FieldRef := RecordRef.Field(ApprovalEntry.FieldNo(Status));
    end;

    local procedure GetApprovalEntryStatusValueName(var FieldRef: FieldRef; ApprovalEntry: Record "Approval Entry"): Text
    begin
        exit(FieldRef.GetEnumValueName(ApprovalEntry.Status.AsInteger() + 1));
    end;

    local procedure GetApprovalEntryStatusValueCaption(var FieldRef: FieldRef; ApprovalEntry: Record "Approval Entry"): Text
    begin
        exit(FieldRef.GetEnumValueCaption(ApprovalEntry.Status.AsInteger() + 1));
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