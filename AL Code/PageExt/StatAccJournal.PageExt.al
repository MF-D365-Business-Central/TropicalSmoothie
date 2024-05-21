pageextension 60012 "MFCCI01StatisticalAccJournal" extends "Statistical Accounts Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
            // field("Agreement No."; Rec."Agreement No.")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the value of the Agreement No. field.';
            // }
        }
    }

    actions
    {
    }
    var
        ClientTypeManagement: Codeunit "Client Type Management";
        ApprovalEntriesExistSentByCurrentUser: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        OpenApprovalEntriesOnJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        EnabledStatJnlLineWorkflowsExist: Boolean;
        EnabledStatJnlBatchWorkflowsExist: Boolean;
        ShowWorkflowStatusOnBatch: Boolean;
        ShowWorkflowStatusOnLine: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        CanCancelApprovalForJnlLine: Boolean;
        CanRequestFlowApprovalForBatchAndAllLines: Boolean;
        CanRequestFlowApprovalForBatchAndCurrentLine: Boolean;
        CanCancelFlowApprovalForBatch: Boolean;
        CanCancelFlowApprovalForLine: Boolean;
        JournalErrorsMgt: Codeunit "Journal Errors Mgt.";
        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
        CanRequestFlowApprovalForBatch: Boolean;

    trigger OnAfterGetRecord()
    Begin
        SetControlAppearanceFromBatch();
    End;

    trigger OnAfterGetcurrRecord()
    Begin
        SetControlAppearanceFromBatch();
    End;

    local procedure SetControlAppearanceFromBatch()
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::ODataV4 then
            exit;

        if not StatJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
            exit;

        SetApprovalStateForBatch(StatJournalBatch, Rec, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesOnJnlBatchExist, OpenApprovalEntriesOnBatchOrAnyJnlLineExist, CanCancelApprovalForJnlBatch, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForBatch, CanRequestFlowApprovalForBatchAndAllLines, ApprovalEntriesExistSentByCurrentUser, EnabledStatJnlBatchWorkflowsExist, EnabledStatJnlLineWorkflowsExist);
    end;


    internal procedure SetApprovalStateForBatch(StatJournalBatch: Record "Statistical Acc. Journal Batch"; StatJournalLine: Record "Statistical Acc. Journal Line"; var OpenApprovalEntriesExistForCurrentUser: Boolean; var OpenApprovalEntriesOnJournalBatchExist: Boolean; var OpenApprovalEntriesOnBatchOrAnyJournalLineExist: Boolean; var CanCancelApprovalForJournalBatch: Boolean; var LocalCanRequestFlowApprovalForBatch: Boolean; var LocalCanCancelFlowApprovalForBatch: Boolean; var LocalCanRequestFlowApprovalForBatchAndAllLines: Boolean; var LocalApprovalEntriesExistSentByCurrentUser: Boolean; var EnabledStatJournalBatchWorkflowsExist: Boolean; var EnabledStatJournalLineWorkflowsExist: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        WorkflowEventHandling: Codeunit MFCC01Approvals;
        WorkflowManagement: Codeunit "Workflow Management";
        CanRequestFlowApprovalForAllLines: Boolean;
    begin
        OpenApprovalEntriesExistForCurrentUser := OpenApprovalEntriesExistForCurrentUser or ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(StatJournalBatch.RecordId);
        OpenApprovalEntriesOnJournalBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(StatJournalBatch.RecordId);
        OpenApprovalEntriesOnBatchOrAnyJournalLineExist := OpenApprovalEntriesOnJournalBatchExist or ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name");
        CanCancelApprovalForJournalBatch := ApprovalsMgmt.CanCancelApprovalForRecord(StatJournalBatch.RecordId);
        GetCanRequestAndCanCancelJournalBatch(StatJournalBatch, LocalCanRequestFlowApprovalForBatch, LocalCanCancelFlowApprovalForBatch, CanRequestFlowApprovalForAllLines);
        LocalCanRequestFlowApprovalForBatchAndAllLines := LocalCanRequestFlowApprovalForBatch and CanRequestFlowApprovalForAllLines;
        LocalApprovalEntriesExistSentByCurrentUser := ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(StatJournalBatch.RecordId) or ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(StatJournalLine.RecordId);

        EnabledStatJournalLineWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Statistical Acc. Journal Line", WorkflowEventHandling.RunWorkflowOnSendStatJournalLineForApprovalCode());
        EnabledStatJournalBatchWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Statistical Acc. Journal Batch", WorkflowEventHandling.RunWorkflowOnSendStatJournalBatchForApprovalCode());
    end;

    local procedure GetCurrentlySelectedLines(var StatJournalLine: Record "Statistical Acc. Journal Line"): Boolean
    begin
        CurrPage.SetSelectionFilter(StatJournalLine);
        exit(StatJournalLine.FindSet());
    end;


    procedure GetCanRequestAndCanCancelJournalBatch(StatJournalBatch: Record "Statistical Acc. Journal Batch"; var CanRequestBatchApproval: Boolean; var CanCancelBatchApproval: Boolean; var CanRequestLineApprovals: Boolean)
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        // Helper method to check the General Journal Batch and all its lines for ability to request/cancel approval.
        // Journal pages' ribbon buttons only let users request approval for the batch or its individual lines, but not both.

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(StatJournalBatch.RecordId, CanRequestBatchApproval, CanCancelBatchApproval);

        StatJournalLine.SetRange("Journal Template Name", StatJournalBatch."Journal Template Name");
        StatJournalLine.SetRange("Journal Batch Name", StatJournalBatch.Name);
        if StatJournalLine.IsEmpty() then begin
            CanRequestLineApprovals := true;
            exit;
        end;

        WorkflowWebhookEntry.SetRange(Response, WorkflowWebhookEntry.Response::Pending);
        if WorkflowWebhookEntry.FindSet() then
            repeat
                if StatJournalLine.Get(WorkflowWebhookEntry."Record ID") then
                    if (StatJournalLine."Journal Batch Name" = StatJournalBatch.Name) and (StatJournalLine."Journal Template Name" = StatJournalBatch."Journal Template Name") then begin
                        CanRequestLineApprovals := false;
                        exit;
                    end;
            until WorkflowWebhookEntry.Next() = 0;

        CanRequestLineApprovals := true;
    end;

}