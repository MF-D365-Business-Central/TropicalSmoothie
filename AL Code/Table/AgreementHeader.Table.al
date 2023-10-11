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
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                CheckDates();
                TestStatusNew(Rec);
            End;
        }
        field(13; "Franchise Revenue Start Date"; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            Begin
                CheckDates();
                TestStatusNew(Rec);
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
                TestStatusNew(Rec);
            End;
        }
        field(19; "Royalty Bank Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
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
                TestStatusNew(Rec);
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
        field(51; "Posted Comission Amount"; Decimal)
        {
            Caption = 'Posted Comission Amount';
            Editable = false;
        }
        field(52; "RoyaltyscheduleNo."; Code[20])
        {
            Caption = 'Royalty Schedule No.';
            TableRelation = "MFCC01 Deferral Header"."Document No.";
            trigger OnValidate()
            Begin
                TestStatusNew(Rec);
            End;
        }
        field(53; "ComissionscheduleNo."; Code[20])
        {
            Caption = 'Comission Schedule No.';
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
        field(57; NonGapInitialRevenueRecognised; Decimal)
        {
            Caption = 'Non Gap Initial Revenue Recognised';
            DataClassification = CustomerContent;
        }
        field(58; "Posted to Under Development"; Boolean)
        {
            Caption = 'Posted to Under Development';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }



    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            CustSetup.Get();
            CustSetup.TestField("Agreement Nos.");
            NoSeriesMgt.InitSeries(CustSetup."Agreement Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            Rec.NonGapInitialRevenueRecognised := CustSetup.NonGapInitialRevenueRecognised;
        end;
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
        AgreementLine.SetRange("Customer No.", Rec."Customer No.");
        IF Not AgreementLine.IsEmpty() then
            AgreementLine.DeleteAll();

        AgreementUsers.SetRange("Customer No.", Rec."Customer No.");
        IF Not AgreementUsers.IsEmpty() then
            AgreementUsers.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

    local procedure CheckDates()
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


    var

        CustSetup: Record "MFCC01 Customization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        OpenDateEDDateErrorLbl: Label 'Ending Date %1 must be greater then Franchise Revenue Start Date %2';
        OpenDateStDateErrorLbl: Label 'Starting Date %1 must not be less then Franchise Revenue Start Date %2';
        RoyaltyDateStDateErrorLbl: Label 'Term Expiration Date %1 must not be less then Franchise Revenue Start Date %2';
        DuplicateAgreementErr: Label 'There is Agreement %1 is signed/open. you can not Setup Multiple signed/open Agreements.';

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
                CustSetup.Get();
                NoSeriesMgt.TestManual(CustSetup."Agreement Nos.");
                "No. Series" := '';

            end;
    end;

    procedure AssistEdit(OldAgreementHeader: Record "MFCC01 Agreement Header"): Boolean
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin

        AgreementHeader := Rec;
        CustSetup.Get();
        CustSetup.TestField("Agreement Nos.");
        if NoSeriesMgt.SelectSeries(CustSetup."Agreement Nos.", OldAgreementHeader."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries(AgreementHeader."No.");
            AgreementHeader.NonGapInitialRevenueRecognised := CustSetup.NonGapInitialRevenueRecognised;
            Rec := AgreementHeader;
            OnAssistEditOnBeforeExit(AgreementHeader);
            exit(true);
        end;

    end;

    procedure TestStatusNew(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        AgreementHeader.TestField(Status, AgreementHeader.Status::" ");
    end;

    procedure SetStatusOpen(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        AgreementHeader.TestField(Status, Status::Signed);
        AgreementHeader.Status := AgreementHeader.Status::Opened;
        AgreementHeader.Modify();
        OnaferOpenEvent(AgreementHeader);
    end;

    procedure SetStatusSigned(Var AgreementHeader: Record "MFCC01 Agreement Header")
    var
        CZSetup: Record "MFCC01 Customization Setup";
    begin
        CheckActiveAgreement();
        CZSetup.GetRecordonce();
        CZSetup.TestField("Commission Payble Account");
        CZSetup.TestField("Prepaid Commision");
        CZSetup.TestField("Def Revenue Cafes in Operation");
        CZSetup.TestField("Deferred Revenue Development");
        CZSetup.TestField("Revenue Recognised Development");
        CheckLinesExist(AgreementHeader, true);
        AgreementHeader.TestField(Status, AgreementHeader.Status::" ");
        AgreementHeader.Status := AgreementHeader.Status::Signed;
        AgreementHeader.Modify();
        OnaferSignEvent(AgreementHeader);
    end;

    procedure SetStatusTerminate(Var AgreementHeader: Record "MFCC01 Agreement Header")
    begin
        CheckLinesExist(AgreementHeader, true);
        IF AgreementHeader.Status IN [AgreementHeader.Status::Signed, AgreementHeader.Status::Opened] then begin
            AgreementHeader.Status := AgreementHeader.Status::Terminated;
            AgreementHeader.Modify();
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