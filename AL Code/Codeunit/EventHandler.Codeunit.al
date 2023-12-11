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
        VendBankAccSendForApprovalEventDescTxt: Label 'Approval of a vendor bank account is requested.';
        VendBankAccApprReqCancelledEventDescTxt: Label 'An approval request for a vendor bank account is canceled.';
        VendBankAccReleasedEventDescTxt: Label 'A vendor bank account is released.';

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

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure TBL_81_OnAfterValidateShortcutDimCode(var GenJournalLine: Record "Gen. Journal Line"; var xGenJournalLine: Record "Gen. Journal Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; CallingFieldNo: Integer)
    var
        Customer: Record Customer;
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionSetEntry: Record "Dimension Set Entry";
        DefDimension: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";
        DimMgmt: Codeunit DimensionManagement;
        CafeCode: Code[20];
    begin
        IF (GenJournalLine."Dimension Set ID" <> xGenJournalLine."Dimension Set ID") then begin
            GLSetup.Get();
            DimensionSetEntry.SetRange("Dimension Set ID", GenJournalLine."Dimension Set ID");
            DimensionSetEntry.SetRange(DimensionSetEntry."Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            IF DimensionSetEntry.FindSet() then
                IF DimensionSetEntry."Dimension Value Code" <> GenJournalLine."Cafe No." then
                    GenJournalLine.Validate("Cafe No.", DimensionSetEntry."Dimension Value Code");
        end;
    end;

    // [EventSubscriber(ObjectType::Page, Page::"Generate EFT Files", 'OnOpenPageOnBeforeUpdateSubForm', '', false, false)]
    // local procedure Page_10810_OnOpenPageOnBeforeUpdateSubForm(var SettlementDate: date; var BankAccountNo: Code[20])
    // var
    //     SigleInstance: Codeunit "MFCC01 Single Instance";
    // begin
    //     IF BankAccountNo = '' then
    //         BankAccountNo := SigleInstance.GetBank();
    // end;

    //VendorBankAccount

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure CU_1520_OnAddWorkflowEventsToLibrary()
    begin
        WorkFlowEvent.AddEventToLibrary(
          MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode(), DATABASE::"Vendor Bank Account", VendBankAccSendForApprovalEventDescTxt, 0, false);

        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnCancelVendorBankAccApprovalRequestCode(), DATABASE::"Vendor Bank Account",
          VendBankAccApprReqCancelledEventDescTxt, 0, false);
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnAfterReleaseVendorBankAccCode(), DATABASE::"Vendor Bank Account",
          VendBankAccReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure CU_1520_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            MFCC01Approvals.RunWorkflowOnCancelVendorBankAccApprovalRequestCode():
                WorkFlowEvent.AddEventPredecessor(MFCC01Approvals.RunWorkflowOnCancelVendorBankAccApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());
            WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());
                end;
            WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());
                end;
            WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());
                end;
        end;

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnSendVendorBankAccForApproval', '', false, false)]
    procedure RunWorkflowOnSendVendorBankAccForApproval(var VendorBankAcc: Record "Vendor Bank Account")
    begin
        OnBeforeRunWorkflowOnSendVendorBankAccForApproval(VendorBankAcc);
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode(), VendorBankAcc);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnCancelVendorBankAccApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelVendorBankAccApprovalRequest(var VendorBankAcc: Record "Vendor Bank Account")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnCancelVendorBankAccApprovalRequestCode(), VendorBankAcc);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunWorkflowOnSendVendorBankAccForApproval(var VendorBankAcc: Record "Vendor Bank Account")
    begin
    end;


    //Response


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkFlowEvent: Codeunit "Workflow Event Handling";
    begin
        case ResponseFunctionName of
            WorkflowResponse.SetStatusToPendingApprovalCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SetStatusToPendingApprovalCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());

                end;
            WorkflowResponse.CreateApprovalRequestsCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CreateApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());

                end;
            WorkflowResponse.SendApprovalRequestForApprovalCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SendApprovalRequestForApprovalCode(), MFCC01Approvals.RunWorkflowOnSendVendorBankAccForApprovalCode());

                end;

            WorkflowResponse.CancelAllApprovalRequestsCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CancelAllApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnCancelVendorBankAccApprovalRequestCode());
                end;
        end;
        OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure CU_1521_OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin

        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAcc);
                    VendorBankAcc.Validate(Status, VendorBankAcc.Status::Released);
                    VendorBankAcc.Modify();
                    Handled := True;
                end;
        end;
    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure CU_1521_OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin

        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAcc);
                    VendorBankAcc.Validate(Status, VendorBankAcc.Status::Open);
                    VendorBankAcc.Modify();
                    Handled := True;
                end;
        end;
    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure CU_1535_OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                Begin
                    RecRef.SetTable(VendorBankAcc);
                    VendorBankAcc.Validate(Status, VendorBankAcc.Status::"Pending Approval");
                    VendorBankAcc.Modify();
                    Variant := VendorBankAcc;
                    IsHandled := True;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure CU_1535_OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAcc);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument."Document No." := VendorBankAcc."Code";
                    ApprovalEntryArgument."Salespers./Purch. Code" := '';

                end;
        End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAfterAllowRecordUsage', '', false, false)]
    local procedure CU_1521_OnAfterAllowRecordUsage(Variant: Variant; var RecRef: RecordRef)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJounaline: Record "Gen. Journal Line";
        ApprovalEntry2: Record "Approval Entry";

    begin

        Case RecRef.Number of
            DATABASE::"Gen. Journal Batch":
                begin
                    RecRef.SetTable(GenJournalBatch);
                    GenJounaline.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
                    GenJounaline.SetRange("Journal Batch Name", GenJournalBatch."Name");
                    GenJounaline.Modifyall("Approver ID", UserId)
                end;

            DATABASE::"Gen. Journal Line":
                begin
                    RecRef.SetTable(GenJounaline);
                    GenJounaline."Approver ID" := UserId;
                    GenJounaline.Modify();
                end;
        End;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', false, false)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::"Vendor Bank Account", 0,
                  DATABASE::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;
    //Response
    //Vendor BankAcoount
}