codeunit 60005 "Event handler"
{
    trigger OnRun()
    begin
    end;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkFlowEvent: Codeunit "Workflow Event Handling";
        WorkflowResponse: Codeunit "Workflow Response Handling";
        MFCC01Approvals: Codeunit MFCC01Approvals;
        VBADocSendForApprovalEventDescTxt: Label 'Approval of a Bank for Vendor document is requested.';
        VBADocApprReqCancelledEventDescTxt: Label 'An approval request for a Bank for Vendor document is canceled.';
        VBADocReleasedEventDescTxt: Label 'A Bank for Vendor document is released.';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        StatJournalBatchSendForApprovalEventDescTxt: Label 'Approval of a Statistical account Journal batch is requested.';
        StatJournalBatchApprovalRequestCancelEventDescTxt: Label 'An approval request for a Statistical account Journal batch is canceled.';
        StatJournalLineSendForApprovalEventDescTxt: Label 'Approval of a Statistical account Journal line is requested.';
        StatJournalLineApprovalRequestCancelEventDescTxt: Label 'An approval request for a Statistical account Journal line is canceled.';
        StatJournalBatchBalancedEventDescTxt: Label 'A Statistical account Journal batch is balanced.';
        StatJournalBatchNotBalancedEventDescTxt: Label 'A Statistical account Journal batch is not balanced.';
        CheckStatJournalBatchBalanceTxt: Label 'Check if the Stat journal batch is balanced.';
        RecordRestrictedTxt: Label 'You cannot use %1 for this action.', Comment = 'You cannot use Customer 10000 for this action.';
        RestrictLineUsageDetailsTxt: Label 'The restriction was imposed because the line requires approval.';
        RestrictBatchUsageDetailsTxt: Label 'The restriction was imposed because the journal batch requires approval.';


    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", 'OnBeforeOpenUsingDocumentService', '', false, false)]
    local procedure OnBeforeOpenUsingDocumentService(FileNameServer: Text; FileName: Text; var Result: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
        Result := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Agreement No." := GenJournalLine."Agreement No.";
    end;

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
        GLEntry."Description 2" := GenJournalLine."Description 2";

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



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', false, false)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; var CardPageID: Integer)
    begin
        case RecordRef.Number of
            Database::"Statistical Acc. Journal Line":
                CardPageID := (PAGE::"Statistical Accounts Journal");
            Database::"Statistical Acc. Journal Batch":
                CardPageID := GetStatJournalBatchPageID(RecordRef);
        end;

    end;


    local procedure GetStatJournalBatchPageID(RecRef: RecordRef): Integer
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        StatJournalLine: Record "Statistical Acc. Journal Line";
    begin
        RecRef.SetTable(StatJournalBatch);

        StatJournalLine.SetRange("Journal Template Name", StatJournalBatch."Journal Template Name");
        StatJournalLine.SetRange("Journal Batch Name", StatJournalBatch.Name);
        if not StatJournalLine.FindFirst() then begin
            StatJournalLine."Journal Template Name" := StatJournalBatch."Journal Template Name";
            StatJournalLine."Journal Batch Name" := StatJournalBatch.Name;
            RecRef.GetTable(StatJournalLine);
            exit(PAGE::"General Journal");
        end;

        RecRef.GetTable(StatJournalLine);
        exit(Page::"Statistical Accounts Journal");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure CU_1535_OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")

    Var
        VendorBankAcc: Record "Vendor Bank Account";
        StatJournalLine: Record "Statistical Acc. Journal Line";
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        case RecRef.Number of
            DATABASE::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VEndorBankAcc);
                    ApprovalEntryArgument."Document Type" := 0;
                    ApprovalEntryArgument."Document No." := VendorBankAcc."Code";
                end;
            Database::"Statistical Acc. Journal Batch":
                RecRef.SetTable(StatJournalBatch);
            DATABASE::"Statistical Acc. Journal Line":
                begin
                    RecRef.SetTable(StatJournalLine);
                    ApprovalEntryArgument."Document Type" := 0;
                    ApprovalEntryArgument."Document No." := StatJournalLine."Document No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := '';
                    ApprovalEntryArgument.Amount := StatJournalLine.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := StatJournalLine.Amount;
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

        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode(), DATABASE::"Statistical Acc. Journal Batch",
          StatJournalBatchSendForApprovalEventDescTxt, 0, false);
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnCancelStatJournalBatchApprovalRequestCode(), DATABASE::"Statistical Acc. Journal Batch",
          StatJournalBatchApprovalRequestCancelEventDescTxt, 0, false);

        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode(), DATABASE::"Statistical Acc. Journal Line",
           StatJournalLineSendForApprovalEventDescTxt, 0, false);
        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnCancelStatJournalLineApprovalRequestCode(), DATABASE::"Statistical Acc. Journal Line",
          StatJournalLineApprovalRequestCancelEventDescTxt, 0, false);

        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode(), DATABASE::"Statistical Acc. Journal Batch",
          StatJournalBatchBalancedEventDescTxt, 0, false);

        WorkFlowEvent.AddEventToLibrary(MFCC01Approvals.RunWorkflowOnStatJournalBatchNotBalancedCode(), DATABASE::"Statistical Acc. Journal Batch",
          StatJournalBatchNotBalancedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventPredecessorsToLibrary, '', false, false)]
    local procedure CU_1520_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode():
                WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnCancelSalesApprovalRequestCode(), WorkFlowEvent.RunWorkflowOnSendSalesDocForApprovalCode());
            MFCC01Approvals.RunWorkflowOnCancelStatJournalBatchApprovalRequestCode():
                WorkFlowEvent.AddEventPredecessor(MFCC01Approvals.RunWorkflowOnCancelStatJournalBatchApprovalRequestCode(),
                  MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
            MFCC01Approvals.RunWorkflowOnCancelStatJournalLineApprovalRequestCode():
                WorkFlowEvent.AddEventPredecessor(MFCC01Approvals.RunWorkflowOnCancelStatJournalLineApprovalRequestCode(),
                  MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode());

            WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());

                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnApproveApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode());
                end;
            WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());

                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnRejectApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode());
                end;
            WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode():
                begin
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode());
                    WorkFlowEvent.AddEventPredecessor(WorkFlowEvent.RunWorkflowOnDelegateApprovalRequestCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode());
                end;
            MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode():
                WorkFlowEvent.AddEventPredecessor(MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
            MFCC01Approvals.RunWorkflowOnStatJournalBatchNotBalancedCode():
                WorkFlowEvent.AddEventPredecessor(MFCC01Approvals.RunWorkflowOnStatJournalBatchNotBalancedCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());


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


    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnSendStatJournalBatchForApproval', '', false, false)]
    procedure RunWorkflowOnSendStatJournalBatchForApproval(var StatJournalBatch: Record "Statistical Acc. Journal Batch")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode(), StatJournalBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnCancelStatJournalBatchApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelStatJournalBatchApprovalRequest(var StatJournalBatch: Record "Statistical Acc. Journal Batch")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnCancelStatJournalBatchApprovalRequestCode(), StatJournalBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnSendStatJournalLineForApproval', '', false, false)]
    procedure RunWorkflowOnSendStatJournalLineForApproval(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode(), StatJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MFCC01Approvals, 'OnCancelStatJournalLineApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelStatJournalLineApprovalRequest(var StatJournalLine: Record "Statistical Acc. Journal Line")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnCancelStatJournalLineApprovalRequestCode(), StatJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Batch", 'OnStatJournalBatchBalanced', '', false, false)]
    procedure RunWorkflowOnStatJournalBatchBalanced(var Sender: Record "Statistical Acc. Journal Batch")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode(), Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Batch", 'OnStatJournalBatchNotBalanced', '', false, false)]
    procedure RunWorkflowOnStatJournalBatchNotBalanced(var Sender: Record "Statistical Acc. Journal Batch")
    begin
        WorkflowManagement.HandleEvent(MFCC01Approvals.RunWorkflowOnStatJournalBatchNotBalancedCode(), Sender);
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
                    VBA."First Time Approval" := false;
                    VBA.Modify();
                    Handled := true;
                end;
        End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAfterAllowRecordUsage', '', false, false)]
    local procedure OnAfterAllowRecordUsage(Variant: Variant; var RecRef: RecordRef)
    var
        StatAccJournalBatch: Record "Statistical Acc. Journal Batch";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJounralLine: Record "Gen. Journal Line";
    begin
        case RecRef.Number of
            DATABASE::"Gen. Journal Batch":
                begin
                    RecRef.SetTable(GenJournalBatch);
                    GenJounralLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
                    GenJounralLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
                    GenJounralLine.ModifyAll("Approver ID", UserId);
                end;
            DATABASE::"Gen. Journal Line":
                begin
                    RecRef.SetTable(GenJounralLine);
                    GenJounralLine."Approver ID" := UserId;
                    GenJounralLine.Modify();
                end;

            DATABASE::"Statistical Acc. Journal Batch":
                begin
                    RecRef.SetTable(StatAccJournalBatch);
                    AllowStatJournalBatchUsage(StatAccJournalBatch);
                end;
        end;
    end;


    procedure AllowStatJournalBatchUsage(StatAccJournalBatch: Record "Statistical Acc. Journal Batch")
    var
        RecRes: Codeunit "Record Restriction Mgt.";
        StatAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        RecRes.AllowRecordUsage(StatAccJournalBatch);

        StatAccJournalLine.SetRange("Journal Template Name", StatAccJournalBatch."Journal Template Name");
        StatAccJournalLine.SetRange("Journal Batch Name", StatAccJournalBatch.Name);
        if StatAccJournalLine.FindSet() then
            repeat
                RecRes.AllowRecordUsage(StatAccJournalLine);
            until StatAccJournalLine.Next() = 0;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure CU_1520_OnAddWorkflowResponsesToLibrary()
    begin
        WorkflowResponse.AddResponseToLibrary(MFCC01Approvals.CheckstatJournalBatchBalanceCode(), 0, CheckStatJournalBatchBalanceTxt, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', false, false)]
    local procedure CU_1520_OnExecuteWorkflowResponse(var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse2: Record "Workflow Response";
    begin
        if WorkflowResponse2.Get(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse2."Function Name" of
                MFCC01Approvals.CheckstatJournalBatchBalanceCode():
                    Begin
                        CheckStatJournalBatchBalance(Variant);
                        ResponseExecuted := True;
                    End;
            End;
    end;
    // StatJournalLine: Record "Statistical Acc. Journal Line";
    //         RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    //         StatJnlBatch: Record "Statistical Acc. Journal Batch"

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Line", 'OnAfterInsertEvent', '', false, false)]
    procedure RestrictStatJournalLineAfterInsert(var Rec: Record "Statistical Acc. Journal Line"; RunTrigger: Boolean)
    begin
        RestrictStatJournalLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Statistical Acc. Journal Line", 'OnAfterModifyEvent', '', false, false)]
    procedure RestrictStatJournalLineAfterModify(var Rec: Record "Statistical Acc. Journal Line"; var xRec: Record "Statistical Acc. Journal Line"; RunTrigger: Boolean)
    begin
        if Format(Rec) = Format(xRec) then
            exit;
        RestrictStatJournalLine(Rec);
    end;



    local procedure RestrictStatJournalLine(var StatJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatJnlBatch: Record "Statistical Acc. Journal Batch";
        ApprovalsMgmt: Codeunit MFCC01Approvals;
        RecRes: Codeunit "Record Restriction Mgt.";
    begin


        if ApprovalsMgmt.IsStatJournalLineApprovalsWorkflowEnabled(StatJournalLine) then
            RecRes.RestrictRecordUsage(StatJournalLine, RestrictLineUsageDetailsTxt);

        if StatJnlBatch.Get(StatJournalLine."Journal Template Name", StatJournalLine."Journal Batch Name") then
            if ApprovalsMgmt.IsStatJournalBatchApprovalsWorkflowEnabled(StatJnlBatch) then
                RecRes.RestrictRecordUsage(StatJournalLine, RestrictBatchUsageDetailsTxt);
    end;

    procedure CheckStatJournalBatchHasUsageRestrictions(StatJnlBatch: Record "Statistical Acc. Journal Batch")
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
        RecRes: Codeunit "Record Restriction Mgt.";
    begin
        RecRes.CheckRecordHasUsageRestrictions(StatJnlBatch);

        StatJournalLine.SetRange("Journal Template Name", StatJnlBatch."Journal Template Name");
        StatJournalLine.SetRange("Journal Batch Name", StatJnlBatch.Name);
        if StatJournalLine.FindSet() then
            repeat
                RecRes.CheckRecordHasUsageRestrictions(StatJournalLine);
            until StatJournalLine.Next() = 0;
    end;


    local procedure CheckStatJournalBatchBalance(Variant: Variant)
    var
        StatJournalBatch: Record "Statistical Acc. Journal Batch";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);

        case RecRef.Number of
            DATABASE::"Statistical Acc. Journal Batch":
                begin
                    StatJournalBatch := Variant;
                    StatJournalBatch.CheckBalance();
                end;
        end;
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
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CreateApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalLineForApprovalCode());
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CreateApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CreateApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode());
                end;
            WorkflowResponse.SendApprovalRequestForApprovalCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SendApprovalRequestForApprovalCode(), MFCC01Approvals.RunWorkflowOnSendVBADocForApprovalCode());
                    WorkflowResponse.AddResponsePredecessor(WorkflowResponse.SendApprovalRequestForApprovalCode(), WorkflowEventHandling.RunWorkflowOnSendGeneralJournalLineForApprovalCode());
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SendApprovalRequestForApprovalCode(), MFCC01Approvals.RunWorkflowOnSendStatJournalBatchForApprovalCode());
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.SendApprovalRequestForApprovalCode(), MFCC01Approvals.RunWorkflowOnStatJournalBatchBalancedCode());
                end;
            WorkflowResponse.OpenDocumentCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(WorkflowResponse.OpenDocumentCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                    WorkflowResponse.AddResponsePredecessor(WorkflowResponse.OpenDocumentCode(), MFCC01Approvals.RunWorkflowOnCancelStatJournalLineApprovalRequestCode());
                    WorkflowResponse.AddResponsePredecessor(WorkflowResponse.OpenDocumentCode(), MFCC01Approvals.RunWorkflowOnCancelStatJournalBatchApprovalRequestCode());
                end;
            WorkflowResponse.CancelAllApprovalRequestsCode():
                begin
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CancelAllApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnCancelVBAApprovalRequestCode());
                    WorkflowResponse.AddResponsePredecessor(
                    WorkflowResponse.CancelAllApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnCancelstatJournalLineApprovalRequestCode());
                    WorkflowResponse.AddResponsePredecessor(
                        WorkflowResponse.CancelAllApprovalRequestsCode(), MFCC01Approvals.RunWorkflowOnCancelstatJournalBatchApprovalRequestCode());
                end;
            MFCC01Approvals.CheckstatJournalBatchBalanceCode():
                WorkflowResponse.AddResponsePredecessor(
                    MFCC01Approvals.CheckstatJournalBatchBalanceCode(),
                    MFCC01Approvals.RunWorkflowOnSendstatJournalBatchForApprovalCode());

        end;
    End;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAfterAllowRecordUsage', '', false, false)]
    local procedure CU_1521OnAfterAllowRecordUsage(Variant: Variant; var RecRef: RecordRef)
    var
        StatJnlBatch: Record "Statistical Acc. Journal Batch";

    begin
        case RecRef.Number of
            DATABASE::"Statistical Acc. Journal Batch":
                begin
                    RecRef.SetTable(StatJnlBatch);
                    AllowGenJournalBatchUsage(StatJnlBatch);
                end;
        End;
    end;

    procedure AllowGenJournalBatchUsage(StatJnlBatch: Record "Statistical Acc. Journal Batch")
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(StatJnlBatch);

        StatJournalLine.SetRange("Journal Template Name", StatJnlBatch."Journal Template Name");
        StatJournalLine.SetRange("Journal Batch Name", StatJnlBatch.Name);
        if StatJournalLine.FindSet() then
            repeat
                RecordRestrictionMgt.AllowRecordUsage(StatJournalLine);
            until StatJournalLine.Next() = 0;
    end;
    #endregion Codeunit1521

    #Region Codeunit2624
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Stat. Acc. Jnl. Line Post", 'OnBeforeInsertStatisticalLedgerEntry', '', false, false)]
    // local procedure CU_2624_OnBeforeInsertStatisticalLedgerEntry(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    // begin
    //     StatisticalLedgerEntry."Agreement No." := StatisticalAccJournalLine."Agreement No.";
    // end;

    #endRegion Codeunit2624

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcelWithFilters', '', false, false)]
    internal procedure OnEditInExcelWithFilters(ServiceName: Text[240]; var EditinExcelFilters: Codeunit "Edit in Excel Filters"; SearchFilter: Text; var Handled: Boolean)
    begin
        //Error(ServiceName);
        if ServiceName = 'General_Ledger_Entries_Excel' then
            Error('You can not use Edit in Excel on the General Ledger Entries page.');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPrepareSales', '', false, false)]
    local procedure OnAfterPrepareSales(var InvoicePostingBuffer: Record "Invoice Posting Buffer" temporary; var SalesLine: Record "Sales Line")
    begin
        InvoicePostingBuffer."Description 2" := SalesLine."Description 2";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterPreparePurchase', '', false, false)]
    local procedure OnAfterPreparePurchase(var PurchaseLine: Record "Purchase Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."Description 2" := PurchaseLine."Description 2";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterBuildPrimaryKey', '', false, false)]
    local procedure OnAfterBuildPrimaryKey(var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        if InvoicePostingBuffer."Description 2" <> '' then
            InvoicePostingBuffer."Group ID" := CopyStr(InvoicePostingBuffer."Group ID" + Format(InvoicePostingBuffer."Description 2"), 1, MaxStrLen(InvoicePostingBuffer."Group ID"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer");
    begin
        GenJnlLine."Description 2" := InvoicePostingBuffer."Description 2";
    end;



    //OldPostingEngine

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPrepareSales', '', false, false)]
    local procedure OnAfterPrepareSalesold(var InvoicePostBuffer: Record "Invoice Post. Buffer" temporary; var SalesLine: Record "Sales Line")
    begin
        InvoicePostBuffer."Description 2" := SalesLine."Description 2";
        InvoicePostBuffer."Additional Grouping Identifier" := CopyStr(InvoicePostBuffer."Description 2", 1, 20);

    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure OnAfterPreparePurchaseold(var PurchaseLine: Record "Purchase Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer" temporary)
    begin
        InvoicePostBuffer."Description 2" := PurchaseLine."Description 2";
        InvoicePostBuffer."Additional Grouping Identifier" := CopyStr(InvoicePostBuffer."Description 2", 1, 20);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnAfterCopyToGenJnlLineold(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer" temporary);
    begin
        GenJnlLine."Description 2" := InvoicePostBuffer."Description 2";

    end;

}