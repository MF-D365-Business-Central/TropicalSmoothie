table 60001 "MFCC01 Deferral Header"
{
    Caption = 'Deferral Header';
    DataCaptionFields = "Schedule Description";
    DrillDownPageId = "MFCC01 Deferrals";
    LookupPageId = "MFCC01 Deferrals";
    fields
    {
        field(1; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "MFCC01 Agreement Header"."No.";
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';

            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(8; "Amount to Defer"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount to Defer';

            trigger OnValidate()
            begin
                Rec.TestStausOpen(Rec);
                if "Amount to Defer" = 0 then
                    Error(ZeroAmountToDeferErr);
            end;
        }
        field(11; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            var
                AccountingPeriod: Record "Accounting Period";
                GenJnlBatch: Record "Gen. Journal Batch";
                ThrowScheduleOutOfBoundError: Boolean;

            begin
                Rec.TestStausOpen(Rec);
                if GenJnlCheckLine.DeferralPostingDateNotAllowed("Start Date") then
                    Error(InvalidPostingDateErr, "Start Date");

                if AccountingPeriod.IsEmpty() then
                    exit;

                AccountingPeriod.SetFilter("Starting Date", '>=%1', "Start Date");
                ThrowScheduleOutOfBoundError := AccountingPeriod.IsEmpty();
                OnValidateStartDateOnAfterCalcThrowScheduleOutOfBoundError(Rec, ThrowScheduleOutOfBoundError);
                if ThrowScheduleOutOfBoundError then
                    Error(DeferSchedOutOfBoundsErr);
                CalcPeriods();
            end;
        }
        field(12; "No. of Periods"; Integer)
        {
            BlankZero = true;
            Caption = 'No. of Periods';
            NotBlank = true;
            Editable = false;
            trigger OnValidate()
            begin
                Rec.TestStausOpen(Rec);
                if "No. of Periods" < 1 then
                    Error(NumberofPeriodsErr);
            end;
        }
        field(13; "Schedule Description"; Text[100])
        {
            Caption = 'Schedule Description';
            trigger OnValidate()
            Begin
                Rec.TestStausOpen(Rec);
            End;
        }
        // field(14; "Initial Amount to Defer"; Decimal)
        // {
        //     Caption = 'Initial Amount to Defer';
        // }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
            trigger OnValidate()
            Begin
                Rec.TestStausOpen(Rec);
            End;
        }
        field(14; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            var
                AccountingPeriod: Record "Accounting Period";
                GenJnlBatch: Record "Gen. Journal Batch";
                ThrowScheduleOutOfBoundError: Boolean;

            begin
                Rec.TestStausOpen(Rec);
                if GenJnlCheckLine.DeferralPostingDateNotAllowed("End Date") then
                    Error(InvalidPostingDateErr, "End Date");

                if AccountingPeriod.IsEmpty() then
                    exit;

                AccountingPeriod.SetFilter("Starting Date", '>=%1', "End Date");
                ThrowScheduleOutOfBoundError := AccountingPeriod.IsEmpty();
                OnValidateStartDateOnAfterCalcThrowScheduleOutOfBoundError(Rec, ThrowScheduleOutOfBoundError);
                if ThrowScheduleOutOfBoundError then
                    Error(DeferSchedOutOfBoundsErr);

                CalcPeriods();
            end;
        }
        field(20; "Schedule Line Total"; Decimal)
        {
            CalcFormula = Sum("MFCC01 Deferral Line".Amount WHERE(
                                                            "Document No." = FIELD("Document No.")));
            Caption = 'Schedule Line Total';
            FieldClass = FlowField;
        }
        field(22; Status; enum "MFCC01 Deferral Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(23; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
        }
        field(24; Commision; Boolean)
        {
            Caption = 'Commision';
            Editable = false;
        }
        field(25; Type; Enum "MFCC01 Deferral Type")
        {
            Editable = false;
        }
        field(26; "Net Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("MFCC01 Deferral Line".Amount where("Document No." = field("Document No."), Posted = const(false), "Posting Date" = field(UPPERLIMIT("Date Filter"))));
        }
        field(27; "Net Amortized"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("MFCC01 Deferral Line".Amount where("Document No." = field("Document No."), Posted = const(true), "Posting Date" = field("Date Filter")));
        }
        field(28; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(29; Balance; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("MFCC01 Deferral Line".Amount where("Document No." = field("Document No."), Posted = const(false)));
        }
        field(30; Amortized; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("MFCC01 Deferral Line".Amount where("Document No." = field("Document No."), Posted = const(true)));
        }
        field(33; "Remaining Periods"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("MFCC01 Deferral Line" where("Document No." = field("Document No."), Posted = const(false)));
        }
        field(34; "Amortized Periods"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("MFCC01 Deferral Line" where("Document No." = field("Document No."), Posted = const(true)));
        }

        field(35; "Termination Date"; Date)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("MFCC01 Agreement Header"."Termination Date" where("No." = field("Agreement No.")));
        }
    }

    keys
    {
        key(Key1; "Document No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DeferralLine: Record "MFCC01 Deferral Line";
        DeferralUtilities: Codeunit "MFCC01 Deferral Utilities";
    begin
        // If the user deletes the header, all associated lines should also be deleted
        DeferralUtilities.FilterDeferralLines(DeferralLine,
          "Customer No.", "Document No.");
        OnDeleteOnBeforeDeleteAll(Rec, DeferralLine);
        DeferralLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Document No." = '' then begin
            CustSetup.Get();
            CustSetup.TestField("Deferral Nos.");
            NoSeriesMgt.InitSeries(CustSetup."Deferral Nos.", xRec."No. Series", 0D, "Document No.", "No. Series");
        end;
    End;

    var

        CustSetup: Record "MFCC01 Franchise Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        DeferralUtilities: Codeunit "MFCC01 Deferral Utilities";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AmountToDeferErr: Label 'The deferred amount cannot be greater than the document line amount.';
        InvalidPostingDateErr: Label '%1 is not within the range of posting dates for your company.', Comment = '%1=The date passed in for the posting date.';
        DeferSchedOutOfBoundsErr: Label 'The deferral schedule falls outside the accounting periods that have been set up for the company.';
        SelectionMsg: Label 'You must specify a deferral code for this line before you can view the deferral schedule.';
        NumberofPeriodsErr: Label 'You must specify one or more periods.';
        ZeroAmountToDeferErr: Label 'The Amount to Defer cannot be 0.';

    local procedure TestNoSeries()
    var
        Deferral: Record "MFCC01 Deferral Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "Document No." <> xRec."Document No." then
            if not Deferral.Get(Rec."Customer No.", Rec."Document No.") then begin
                CustSetup.Get();
                NoSeriesMgt.TestManual(CustSetup."Deferral Nos.");
                "No. Series" := '';
            end;
    end;

    procedure AssistEdit(OldDeferral: Record "MFCC01 Deferral Header"): Boolean
    var
        Deferral: Record "MFCC01 Deferral Header";
    begin

        Deferral := Rec;
        CustSetup.Get();
        CustSetup.TestField("Deferral Nos.");
        if NoSeriesMgt.SelectSeries(CustSetup."Deferral Nos.", OldDeferral."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries(Deferral."Document No.");
            Rec := Deferral;
            OnAssistEditOnBeforeExit(Deferral);
            exit(true);
        end;
    end;

    procedure CalculateSchedule(): Boolean
    var
        DeferralDescription: Text[100];
    begin
        OnBeforeCalculateSchedule(Rec);

        Rec.TestField("Amount to Defer");
        DeferralDescription := "Schedule Description";
        DeferralUtilities.CreateDeferralSchedule(
           Rec."Customer No.", "Document No.", "Amount to Defer",
             "Start Date", "No. of Periods", false, DeferralDescription, "Currency Code");
        Rec.SetDocumentSheduleCreated(Rec);
        exit(true);
    end;

    procedure TestStausOpen(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::" ");
    end;

    procedure ReopenDocument(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::"Schedule Created");

        DeferralHeader.Status := DeferralHeader.Status::" ";
        DeferralHeader.Modify();
    end;

    procedure SetDocumentSheduleCreated(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::" ");

        DeferralHeader.Status := DeferralHeader.Status::"Schedule Created";
        DeferralHeader.Modify();
    end;

    procedure SetDocumentCertified(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::"Schedule Created");

        DeferralHeader.Status := DeferralHeader.Status::Open;
        DeferralHeader.Modify();
    end;

    procedure SetDocumentCompleted(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::Open);

        DeferralHeader.Status := DeferralHeader.Status::Completed;
        DeferralHeader.Modify();
    end;

    procedure SetDocumentShortClosed(Var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
        DeferralHeader.TestField(Status, DeferralHeader.Status::Open);

        DeferralHeader.Status := DeferralHeader.Status::"Short Closed";
        DeferralHeader.Modify();
    end;

    procedure CloseDeferralDocument()
    var
        DeferralLine: Record "MFCC01 Deferral Line";
    begin
        DeferralLine.SetRange("Customer No.", Rec."Customer No.");
        DeferralLine.SetRange("Document No.", Rec."Document No.");
        IF DeferralLine.IsEmpty() then
            Exit;
        DeferralLine.SetRange(Posted, false);
        IF not DeferralLine.IsEmpty() then
            Exit;

        SetDocumentCompleted(Rec);
    end;

    local procedure CalcPeriods()
    var
        DeferalUtilities: Codeunit "MFCC01 Deferral Utilities";
    begin
        IF (Rec."Start Date" <> 0D) And (Rec."End Date" <> 0D) then
            Rec."No. of Periods" := DeferalUtilities.CalcNoOfPeriods(Rec."Start Date", Rec."End Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateSchedule(var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnBeforeDeleteAll(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStartDateOnAfterCalcThrowScheduleOutOfBoundError(DeferralHeader: Record "MFCC01 Deferral Header"; var ThrowScheduleOutOfBoundError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var Deferral: Record "MFCC01 Deferral Header"; xDeferral: Record "MFCC01 Deferral Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var Deferral: Record "MFCC01 Deferral Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssistEditOnBeforeExit(var Deferral: Record "MFCC01 Deferral Header")
    begin
    end;
}
