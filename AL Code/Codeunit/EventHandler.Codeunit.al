codeunit 60005 "Event handler"
{
    trigger OnRun()
    begin
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkFlowEvent: Codeunit "Workflow Event Handling";
        WorkflowResponse: Codeunit "Workflow Response Handling";
        MFCC01Approvals: Codeunit MFCC01Approvals;
        VBADocSendForApprovalEventDescTxt: Label 'Approval of a Bank for Vendor document is requested.';
        VBADocApprReqCancelledEventDescTxt: Label 'An approval request for a Bank for Vendor document is canceled.';
        VBADocReleasedEventDescTxt: Label 'A Bank for Vendor document is released.';

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", OnAfterCopyGLEntryFromGenJnlLine, '', false, false)]
    local procedure OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        FixedAsset: Record "Fixed Asset";
    begin
        GLEntry."Agreement No." := GenJournalLine."Agreement No.";
        GLEntry."Approver ID" := GenJournalLine."Approver ID";
        Case GLEntry."Source Type" of

            GLEntry."Source Type"::"Bank Account":
                Begin
                    BankAccount.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := BankAccount.Name;
                End;
            GLEntry."Source Type"::Customer:
                Begin
                    Customer.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Customer.Name;
                End;
            GLEntry."Source Type"::Employee:
                Begin
                    Employee.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Employee.FullName();
                End;
            GLEntry."Source Type"::"Fixed Asset":
                Begin
                    FixedAsset.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := FixedAsset.Description;
                End;
            GLEntry."Source Type"::Vendor:
                Begin
                    Vendor.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Vendor.Name;
                End;
        End;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateShortcutDimCode', '', false, false)]
    // local procedure TBL_81_OnAfterValidateShortcutDimCode(var GenJournalLine: Record "Gen. Journal Line"; var xGenJournalLine: Record "Gen. Journal Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; CallingFieldNo: Integer)
    // var
    //     Customer: Record Customer;
    //     TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
    //     DimensionSetEntry: Record "Dimension Set Entry";
    //     DefDimension: Record "Default Dimension";
    //     GLSetup: Record "General Ledger Setup";
    //     DimMgmt: Codeunit DimensionManagement;
    //     CafeCode: Code[20];
    // begin
    //     IF (GenJournalLine."Dimension Set ID" <> xGenJournalLine."Dimension Set ID") then begin
    //         GLSetup.Get();
    //         DimensionSetEntry.SetRange("Dimension Set ID", GenJournalLine."Dimension Set ID");
    //         DimensionSetEntry.SetRange(DimensionSetEntry."Dimension Code", GLSetup."Shortcut Dimension 3 Code");
    //         IF DimensionSetEntry.FindSet() then
    //             IF DimensionSetEntry."Dimension Value Code" <> GenJournalLine."Cafe No." then
    //                 GenJournalLine.Validate("Cafe No.", DimensionSetEntry."Dimension Value Code");
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Page, Page::"Generate EFT Files", 'OnOpenPageOnBeforeUpdateSubForm', '', false, false)]
    // local procedure Page_10810_OnOpenPageOnBeforeUpdateSubForm(var SettlementDate: date; var BankAccountNo: Code[20])
    // var
    //     SigleInstance: Codeunit "MFCC01 Single Instance";
    // begin
    //     IF BankAccountNo = '' then
    //         BankAccountNo := SigleInstance.GetBank();
    // end;

    //VendorBankAccount

    #region Codeunit1535

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterPopulateApprovalEntryArgument', '', false, false)]
    local procedure CU_1535_OnAfterPopulateApprovalEntryArgument(WorkflowStepInstance: Record "Workflow Step Instance"; var ApprovalEntryArgument: Record "Approval Entry"; var IsHandled: Boolean; var RecRef: RecordRef)

    Var
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VEndorBankAcc);
                    ApprovalEntryArgument."Document Type" := 0;
                    ApprovalEntryArgument."Document No." := VendorBankAcc."Code";
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure CU_1535_OnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean; var IsHandled: Boolean)
    begin
        case ApprovalEntryArgument."Table ID" of
            DATABASE::"Vendor Bank Account":
                IsSufficient := IsSufficientVBAApprover(UserSetup, IsHandled);
        End;
    ENd;

    local procedure IsSufficientVBAApprover(UserSetup: Record "User Setup"; var IsHandled: Boolean): Boolean
    var
    begin
        IsHandled := True;
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Approver ID" = '' then
            exit(true);

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure CU_1535_OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        case RecRef.Number of

            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAcc);
                    VendorBankAcc.Validate(Status, VendorBankAcc.Status::"Pending Approval");
                    VendorBankAcc.Modify();
                    Variant := VendorBankAcc;
                    IsHandled := True;
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsSufficientVBAApprover(UserSetup: Record "User Setup"; var IsSufficient: Boolean; var IsHandled: Boolean)
    begin
    end;
    #endregion Codeunit1535

    #region Codeunit1520
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure CU_1520_OnAddWorkflowEventsToLibrary()
    begin
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode(), DATABASE::"Vendor Bank Account",
  VBADocSendForApprovalEventDescTxt, 0, false);
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode(), DATABASE::"Vendor Bank Account",
          VBADocApprReqCancelledEventDescTxt, 0, false);
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnAfterReleaseVBADocCode(), DATABASE::"Vendor Bank Account",
          VBADocReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventPredecessorsToLibrary, '', false, false)]
    local procedure CU_1520_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode():
                WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnCancelSalesApprovalRequestCode(), WorkFlowEvent.RunWorkflowOnSendSalesDocForApprovalCode());
            WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                end;
            WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                end;
            WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnSendVBADocForApproval', '', false, false)]
    procedure RunWorkflowOnSendVBADocForApproval(var VBA: Record "Vendor Bank Account")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode(), VBA);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnCancelVBAApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelVBAApprovalRequest(var VBA: Record "Vendor Bank Account")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode(), VBA);
    end;

    #endregion Codeunit1520

    #region Codeunit1521
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure CU_1520_OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        VBA: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VBA);
                    VBA.Validate(Status, VBA.Status::Released);
                    VBA.Modify();
                    Handled := true;
                end;
        End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure CU_1520_OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        VBA: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VBA);
                    VBA.Validate(Status, VBA.Status::Open);
                    VBA.Modify();
                    Handled := true;
                end;
        End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure CU_1520_OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    Begin
        case ResponseFunctionName of
            WorkflowResponse.SetStatusToPendingApprovalCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SetStatusToPendingApprovalCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                end;
            WorkflowResponse.CreateApprovalRequestsCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CreateApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                end;
            WorkflowResponse.SendApprovalRequestForApprovalCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SendApprovalRequestForApprovalCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                end;
            WorkflowResponse.OpenDocumentCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(WorkflowResponse.OpenDocumentCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                end;
            WorkflowResponse.CancelAllApprovalRequestsCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CancelAllApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                end;
        end;
    End;
    #endregion Codeunit1521

    #Region Codeunit2624
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Stat. Acc. Jnl. Line Post", 'OnBeforeInsertStatisticalLedgerEntry', '', false, false)]
    // local procedure CU_2624_OnBeforeInsertStatisticalLedgerEntry(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    // begin
    //     StatisticalLedgerEntry."Agreement No." := StatisticalAccJournalLine."Agreement No.";
    // end;

    #endRegion Codeunit2624
}