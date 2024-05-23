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
        modify(Register)
        {
            trigger OnBeforeAction()
            Var
                EventHandelr: Codeunit "Event handler";
                StatJournalBatch: Record "Statistical Acc. Journal Batch";
            BEgin
                StatJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
                EventHandelr.CheckStatJournalBatchHasUsageRestrictions(StatJournalBatch);
            End;
        }

        // Add changes to page actions here
        addlast(navigation)
        {
            action(Approvals)
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction()
                var
                    [SecurityFiltering(SecurityFilter::Filtered)]
                    StatJournalLine: Record "Statistical Acc. Journal Line";
                    ApprovalsMgmt: Codeunit MFCC01Approvals;
                begin
                    GetCurrentlySelectedLines(StatJournalLine);
                    ApprovalsMgmt.ShowJournalApprovalEntries(StatJournalLine);
                end;
            }
        }
        addlast(Process)
        {

            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrAnyJnlLineExist AND CanRequestFlowApprovalForBatchAndAllLines AND EnabledStatJnlBatchWorkflowsExist;

                        Image = SendApprovalRequest;
                        ToolTip = 'Send all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit MFCC01Approvals;
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                    action(SendApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrCurrJnlLineExist AND CanRequestFlowApprovalForBatchAndCurrentLine AND EnabledStatJnlLineWorkflowsExist;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send selected journal lines for approval.';
                        Visible = false;
                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            StatJournalLine: Record "Statistical Acc. Journal Line";
                            ApprovalsMgmt: Codeunit MFCC01Approvals;
                        begin
                            GetCurrentlySelectedLines(StatJournalLine);
                            ApprovalsMgmt.SendJournalLinesApprovalRequests(StatJournalLine);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                }
                group(CancelApprovalRequest)
                {
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = CanCancelApprovalForJnlBatch OR CanCancelFlowApprovalForBatch;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit MFCC01Approvals;
                        begin
                            ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                    action(CancelApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = CanCancelApprovalForJnlLine OR CanCancelFlowApprovalForLine;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending selected journal lines for approval.';
                        Visible = false;
                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            StatJournalLine: Record "Statistical Acc. Journal Line";
                            ApprovalsMgmt: Codeunit MFCC01Approvals;
                        begin
                            GetCurrentlySelectedLines(StatJournalLine);
                            ApprovalsMgmt.TryCancelJournalLineApprovalRequests(StatJournalLine);
                        end;
                    }
                }
            }

            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit MFCC01Approvals;
                    begin
                        ApprovalsMgmt.ApproveStatJournalLineRequest(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit MFCC01Approvals;
                    begin
                        ApprovalsMgmt.RejectStatJournalLineRequest(Rec);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit MFCC01Approvals;
                    begin
                        ApprovalsMgmt.DelegateStatJournalLineRequest(Rec);
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser or ApprovalEntriesExistSentByCurrentUser;

                    trigger OnAction()
                    var
                        StatJournalBatch: Record "Statistical Acc. Journal Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlLineExist then
                            ApprovalsMgmt.GetApprovalComment(Rec)
                        else
                            if OpenApprovalEntriesOnJnlBatchExist then
                                if StatJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
                                    ApprovalsMgmt.GetApprovalComment(StatJournalBatch);
                    end;
                }
            }
        }
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