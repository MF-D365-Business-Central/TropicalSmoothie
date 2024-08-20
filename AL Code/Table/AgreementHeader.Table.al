table 60003 "MFCC01 Agreement Header"
{
    Caption = 'Agreement Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "MFCC01 Agreements";
    LookupPageId = "MFCC01 Agreements";
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            trigger OnValidate()
            Begin
                TransferedAgreement();
            End;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            //NotBlank = true;
            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(12; "Term Expiration Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                CheckDates();
                TestStatusForDates(Rec);
                CalcPeriods();
            End;
        }
        field(13; "Franchise Revenue Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                CheckDates();
                TestStatusForDates(Rec);
                CZ.GetRecordonce();
                //CalcExpirationDate();
                CalcPeriods();
            End;
        }
        field(16; "License Type"; Enum "MFCC01 License Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(17; Status; Enum "MFCC01 Agreement Status")
        {
            DataClassification = CustomerContent;
            Editable = false;
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(18; "Franchise Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            Begin
                //TestStatusNew(Rec);
            End;
        }
        field(19; "Royalty Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            Begin
                //TestStatusNew(Rec);
            End;
        }
        field(20; "Agreement Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Agreement Amount';//RGU
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(21; "SalesPerson Commission"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                Rec.TestField("Posted Commission Amount", 0);
            End;
        }
        field(23; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
        }
        field(50; "Posted Agreement Amount"; Decimal)
        {
            Caption = 'Posted Agreement Amount';
            Editable = false;
        }
        field(51; "Posted Commission Amount"; Decimal)
        {
            Caption = 'Posted Commission Amount';
            Editable = false;
        }
        field(52; "FranchiseFeescheduleNo."; Code[20])
        {
            Caption = 'Franchise Fee Schedule No.';
            TableRelation = "MFCC01 Deferral Header"."Document No.";
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(53; "CommissionscheduleNo."; Code[20])
        {
            Caption = 'Commission Schedule No.';
            TableRelation = "MFCC01 Deferral Header"."Document No.";
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(54; PostedRevenueStatisticalAmount; Decimal)
        {
            Caption = 'Posted Revenue Statistical Amount';
            Editable = false;
        }
        field(55; PostedCommissionExpenseAmount; Decimal)
        {
            Caption = 'Posted Commission Expense  Amount';
            Editable = false;
        }
        field(56; "Agreement Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(57; NonGapInitialRevenueRecognized; Decimal)
        {
            Caption = 'Non Gap Initial Revenue Recognized GAAP';
            DataClassification = CustomerContent;
        }
        field(58; "Posted to Under Development"; Boolean)
        {
            Caption = 'Posted to Under Development';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(59; "Termination Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
            End;
        }
        field(60; "No. of Periods"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "RenewalFeescheduleNo."; Code[20])
        {
            Caption = 'Renewal Fee Schedule No.';
            TableRelation = "MFCC01 Deferral Header"."Document No.";
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(62; "Renewal No. of Periods"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(63; "Fanchise Amt Closed"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(65; "Commission Amt Closed"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66; "Cancled Agreement Amount"; Decimal)
        {
            Caption = 'Cancel Agreement Amount';
            Editable = false;
        }
        field(67; "Canceled Commission Amount"; Decimal)
        {
            Caption = 'Cancel Commission Amount';
            Editable = false;
        }

        field(68; CancelRevenueStatisticalAmount; Decimal)
        {
            Caption = 'Cancel Revenue Statistical Amount';
            Editable = false;
        }
        field(69; CancelCommissionExpenseAmount; Decimal)
        {
            Caption = 'Cancel Commission Expense  Amount';
            Editable = false;
        }
        field(70; "New Franchise Fee"; Decimal)
        {
            Caption = 'New Franchise Fee';
        }
        field(71; "New Commission Fee"; Decimal)
        {
            Caption = 'New Commission Fee';

        }
        field(72; "New End Date"; Date)
        {
            Caption = 'New End Date';

            trigger OnValidate()
            Begin
                CheckDatesNewDate();
            End;
        }
        field(73; "Canceled No. of Periods"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var

        CZ: Record "MFCC01 Franchise Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        OpenDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Franchise Revenue Start Date %2';
        OpenDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Franchise Revenue Start Date %2';
        RoyaltyDateStDateErrorLbl: Label 'Term Expiration Date %1 must not be less then Franchise Revenue Start Date %2';
        DuplicateAgreementErr: Label 'There is Agreement %1 is signed/open. you can not Setup Multiple signed/open Agreements.';
        NewOpenDateEDDateErrorLbl: Label 'New Ending Date %1 must be greater then Franchise Revenue Start Date %2';
        NewRoyaltyDateStDateErrorLbl: Label 'New End Date %1 must not be less then Franchise Revenue Start Date %2';

    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            CZ.Get();
            CZ.TestField("Agreement Nos.");
            NoSeriesMgt.InitSeries(CZ."Agreement Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            Rec.NonGapInitialRevenueRecognized := CZ.NonGapInitialRevenueRecognized;
        end;
        TransferedAgreement();
    End;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
        AgreementUsers: Record "MFCC01 Agreement Users";
    begin
        Rec.TestStatusNew(Rec);
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        IF Not AgreementLine.IsEmpty() then
            AgreementLine.DeleteAll();

        AgreementUsers.SetRange("Agreement No.", Rec."No.");
        IF Not AgreementUsers.IsEmpty() then
            AgreementUsers.DeleteAll();
    end;

    trigger OnRename()
    begin
    end;

    procedure CheckDatesNewDate()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
        CZSetup: Record "MFCC01 Franchise Setup";
        FromDate: Date;
        ToDate: Date;
        AllowedPeriodErr: Label 'New Ending Date should be between %1 & %2';
    begin
        CZSetup.Get();
        CZSetup.TestField("End Date Allowed Period");
        FromDate := CalcDate(StrSubstNo('<-%1>', CZSetup."End Date Allowed Period"), Rec."Term Expiration Date");
        ToDate := CalcDate(StrSubstNo('<+%1>', CZSetup."End Date Allowed Period"), Rec."Term Expiration Date");

        IF Not ("New End Date" IN [FromDate .. ToDate]) then
            Error(AllowedPeriodErr, FromDate, ToDate);

        IF (Rec."New End Date" <> 0D) And (
                     Rec."New End Date" < Rec."Franchise Revenue Start Date") then
            Error(RoyaltyDateStDateErrorLbl, Rec."New End Date", Rec."Franchise Revenue Start Date");

        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        IF AgreementLine.FindSet() then
            repeat
                IF (AgreementLine."Ending Date" <> 0D) And (
                     AgreementLine."Starting Date" < Rec."Franchise Revenue Start Date") then
                    Error(OpenDateSTDateErrorLbl, AgreementLine."Starting Date", Rec."Franchise Revenue Start Date");

                IF (AgreementLine."Ending Date" <> 0D) AND (AgreementLine."Ending Date" < Rec."Franchise Revenue Start Date")
                     then
                    Error(NewOpenDateEDDateErrorLbl, AgreementLine."Ending Date", Rec."Franchise Revenue Start Date");
            Until AgreementLine.Next() = 0;
    end;

    procedure CheckDates()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
    begin
        IF (Rec."Term Expiration Date" <> 0D) And (
                     Rec."Term Expiration Date" < Rec."Franchise Revenue Start Date") then
            Error(RoyaltyDateStDateErrorLbl, Rec."Term Expiration Date", Rec."Franchise Revenue Start Date");

        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        IF AgreementLine.FindSet() then
            repeat
                IF (AgreementLine."Ending Date" <> 0D) And (
                     AgreementLine."Starting Date" < Rec."Franchise Revenue Start Date") then
                    Error(OpenDateSTDateErrorLbl, AgreementLine."Starting Date", Rec."Franchise Revenue Start Date");

                IF (AgreementLine."Ending Date" <> 0D) AND (AgreementLine."Ending Date" < Rec."Franchise Revenue Start Date")
                     then
                    Error(OpenDateEDDateErrorLbl, AgreementLine."Ending Date", Rec."Franchise Revenue Start Date");
            Until AgreementLine.Next() = 0;
    end;

    local procedure CheckActiveAgreement()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        AgreementHeader.SetRange("Customer No.", Rec."Customer No.");
        AgreementHeader.SetFilter(Status, '%1|%2', AgreementHeader.Status::Signed, AgreementHeader.Status::Opened);
        IF Not AgreementHeader.FindFirst() then
            Exit;
        Error(DuplicateAgreementErr, AgreementHeader."No.");
    end;

    local procedure TransferedAgreement()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        Customer: Record Customer;
    begin
        IF Not Customer.Get(Rec."Customer No.") then
            Exit;
        Customer.TestField("Customer Posting Group");
        Customer.TestField("Gen. Bus. Posting Group");
        AgreementHeader.SetRange("Customer No.", Rec."Customer No.");
        AgreementHeader.SetFilter(Status, '%1|%2|%3', AgreementHeader.Status::Signed, AgreementHeader.Status::Opened, AgreementHeader.Status::Terminated);
        IF Not AgreementHeader.FindFirst() then
            Exit;
        Rec."License Type" := Rec."License Type"::Transferred;
    end;

    procedure CalcPeriods()
    var
        DeferalUtilities: Codeunit "MFCC01 Deferral Utilities";
    begin
        IF (Rec."Franchise Revenue Start Date" <> 0D) And (Rec."Term Expiration Date" <> 0D) then
            Rec."No. of Periods" := DeferalUtilities.CalcNoOfPeriods(Rec."Franchise Revenue Start Date", Rec."Term Expiration Date");
    end;

    local procedure TestNoSeries()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." <> xRec."No." then
            if not AgreementHeader.Get(Rec."No.") then begin
                CZ.Get();
                NoSeriesMgt.TestManual(CZ."Agreement Nos.");
                "No. Series" := '';
            end;
    end;

    procedure AssistEdit(OldAgreementHeader: Record "MFCC01 Agreement Header"): Boolean
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin

        AgreementHeader := Rec;
        CZ.Get();
        CZ.TestField("Agreement Nos.");
        if NoSeriesMgt.SelectSeries(CZ."Agreement Nos.", OldAgreementHeader."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries(AgreementHeader."No.");
            AgreementHeader.NonGapInitialRevenueRecognized := CZ.NonGapInitialRevenueRecognized;
            Rec := AgreementHeader;
            OnAssistEditOnBeforeExit(AgreementHeader);
            exit(true);
        end;
    end;

    procedure TestStatusForDates(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        IF (AgreementHeader.Status = AgreementHeader.Status::Opened) or
        (AgreementHeader.Status = AgreementHeader.Status::Terminated) then
            Error('Status must not be %1', AgreementHeader.Status);
    end;

    procedure TestStatusNew(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        AgreementHeader.TestField(Status, AgreementHeader.Status::"Not Signed");
    end;

    procedure SetStatusOpen(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        CZSetup: Record "MFCC01 Franchise Setup";
        ConfirmTxt: Label 'Do you want to Open the Cafe.?';
        DimensionMsg: Label 'Please check and Verify Dimension Values for Cafe, Market, and FMM.';
    begin
        CZSetup.GetRecordonce();
        CZSetup.TestField("Corp Department Code");
        AgreementHeader.TestField(Status, Status::Signed);
        AgreementHeader.TestField("Franchise Revenue Start Date");
        AgreementHeader.TestField("Term Expiration Date");

        Message(DimensionMsg);
        IF (AgreementHeader."SalesPerson Commission" = 0) Or (AgreementHeader."Agreement Amount" = 0) then Begin
            IF not Confirm('You are about to open a cafe that has $0 Commissions or $0 Amount. There could be a lot of troubles because of that. Are you sure?!', false, true) then
                exit;
        End else IF not Confirm(ConfirmTxt, false, true) then
                exit;

        CheckLinesExist(AgreementHeader, true);
        AgreementHeader.Status := AgreementHeader.Status::Opened;
        AgreementHeader.Modify();
        OnaferOpenEvent(AgreementHeader);
    end;

    procedure SetStatusSigned(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        CZSetup: Record "MFCC01 Franchise Setup";
        ConfirmTxt: Label 'Do you want to Sign the Cafe.?';
    begin
        IF not Confirm(ConfirmTxt, false, true) then
            exit;
        CheckActiveAgreement();
        CZSetup.GetRecordonce();

        CZSetup.TestField(PrepaidCommisionLT);
        CZSetup.TestField("Accrued Fran Bonus GAAP");
        CZSetup.TestField(DefRevenueCafesinOperationGAAP);
        CZSetup.TestField(DeferredRevenueDevelopmentGAPP);
        CZSetup.TestField(RevenueRecognizedGAAP);
        CZSetup.TestField("Corp Department Code");
        //AgreementHeader.TestField("Agreement Amount");
        AgreementHeader.TestField(Status, AgreementHeader.Status::"Not Signed");
        AgreementHeader.Status := AgreementHeader.Status::Signed;
        AgreementHeader.Modify();
        OnaferSignEvent(AgreementHeader);
    end;

    procedure SetStatusTerminate(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        AgreementMgmt: Codeunit "MFCC01 Agreement Management";
        DefHeader: Record "MFCC01 Deferral Header";
        DefLine: Record "MFCC01 Deferral Line";

        ConfirmTxt: Label 'Do you want to Terminate the Cafe.?';
    begin
        IF not Confirm(ConfirmTxt, false, true) then
            exit;
        //CheckLinesExist(AgreementHeader, true);
        AgreementHeader.TestField("Termination Date");
        IF AgreementHeader.Status IN [AgreementHeader.Status::Signed, AgreementHeader.Status::Opened] then begin


            IF AgreementHeader.Status = AgreementHeader.Status::Opened then
                AgreementMgmt.ProcessTerminateOnOpen(AgreementHeader);
            IF AgreementHeader.Status = AgreementHeader.Status::Signed then
                AgreementMgmt.ProcessTerminateOnSign(AgreementHeader);

            DefHeader.Reset();
            DefHeader.SetRange("Agreement No.", Rec."No.");
            IF DefHeader.FindSet() then
                repeat
                    DefLine.Reset();
                    DefLine.SetRange("Document No.", DefHeader."Document No.");
                    IF DefLine.FindSet() then
                        DefLine.ModifyAll(Posted, true);
                    DefHeader.Status := DefHeader.Status::Terminated;
                    DefHeader.Modify();
                Until DefHeader.Next() = 0;


            AgreementHeader.Status := AgreementHeader.Status::Terminated;
            AgreementHeader.Modify();
            //AgreementMgmt.CreateNewAgreement(AgreementHeader, true)
        end;
    end;

    procedure CorrectCommissionFee(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        AgreementMgmt: Codeunit "MFCC01 Agreement Management";
        CorrectionType: Enum CorrectionType;
        ConfirmTxt: Label 'Do you want to Correct commission Fee.?';
        Confirm2Txt: Label 'New Commission Fee is Zero. Do you want to Correct Commission Fee with Zero.?';
        CompletedTxt: Label 'commission Fee Corrected.';
    begin
        IF AgreementHeader."New Commission Fee" <> 0 then
            IF not Confirm(ConfirmTxt, false, true) then
                exit;
        IF AgreementHeader."New Commission Fee" = 0 then
            IF not Confirm(Confirm2Txt, false, true) then
                exit;

        IF AgreementHeader.Status IN [AgreementHeader.Status::Signed, AgreementHeader.Status::Opened] then begin
            CorrectionType := CorrectionType::Commission;
            AgreementMgmt.ProcessCancel(AgreementHeader, CorrectionType);
            AgreementHeader.Modify();
            Message(CompletedTxt);

        end;
    end;

    procedure CorrectFranchiseFee(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        AgreementMgmt: Codeunit "MFCC01 Agreement Management";
        DefHeader: Record "MFCC01 Deferral Header";
        CorrectionType: Enum CorrectionType;
        ConfirmTxt: Label 'Do you want to Correct Franchise Fee.?';
        Confirm2Txt: Label 'New Fee is Zero. Do you want to Correct Franchise Fee with Zero.?';
        CompletedTxt: Label 'Franchise Fee Corrected.';
    begin
        IF AgreementHeader."New Franchise Fee" <> 0 then
            IF not Confirm(ConfirmTxt, false, true) then
                exit;
        IF AgreementHeader."New Franchise Fee" = 0 then
            IF not Confirm(Confirm2Txt, false, true) then
                exit;
        IF AgreementHeader.Status IN [AgreementHeader.Status::Signed, AgreementHeader.Status::Opened] then begin
            CorrectionType := CorrectionType::Fee;
            AgreementMgmt.ProcessCancel(AgreementHeader, CorrectionType);
            AgreementHeader.Modify();
            Message(CompletedTxt);
        end;
    end;


    procedure CorrectSchedules(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        AgreementMgmt: Codeunit "MFCC01 Agreement Management";
        DefHeader: Record "MFCC01 Deferral Header";
        CorrectionType: Enum CorrectionType;
        ConfirmTxt: Label 'Do you want to Correct Schedules.?';
        Confirm2Txt: Label 'New Fee is Zero. Do you want to Correct Franchise Fee with Zero.?';
        CompletedTxt: Label 'Schedules Corrected.';
    begin
        IF not Confirm(ConfirmTxt, false, true) then
            exit;

        IF AgreementHeader.Status IN [AgreementHeader.Status::Signed, AgreementHeader.Status::Opened] then begin
            CorrectionType := CorrectionType::Schedules;
            AgreementMgmt.ProcessCancel(AgreementHeader, CorrectionType);
            AgreementHeader.Modify();
            Message(CompletedTxt);
        end;
    end;

    local procedure CheckLinesExist(AgreementHeader: Record "MFCC01 Agreement Header"; ShowError: Boolean) Found: Boolean
    var
        AgreementLine: Record "MFCC01 Agreement Line";
        NoLinesError: Label 'Agreement Lines does not exist.';
    begin
        AgreementLine.SetRange("Agreement No.", Rec."No.");
        Found := Not AgreementLine.IsEmpty();
        IF ShowError and (Not Found) then
            Error(NoLinesError);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var AgreementHeader: Record "MFCC01 Agreement Header"; xAgreementHeader: Record "MFCC01 Agreement Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(var AgreementHeader: Record "MFCC01 Agreement Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssistEditOnBeforeExit(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnaferSignEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnaferOpenEvent(var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
    end;
}