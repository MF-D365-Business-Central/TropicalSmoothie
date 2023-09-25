table 60002 "MFCC01 Deferral Line"
{
    Caption = 'Deferral Line';

    fields
    {
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Deferral Header"."Document No.";
            NotBlank = true;
        }

        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            NotBlank = true;
            trigger OnValidate()
            var
                AccountingPeriod: Record "Accounting Period";
                IsHandled: Boolean;
            begin
                Rec.TestStausOpen();
                IsHandled := false;
                OnBeforeValidatePostingDate(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if DeferralUtilities.IsDateNotAllowed("Posting Date") then
                    Error(InvalidPostingDateErr, "Posting Date");

                if AccountingPeriod.IsEmpty() then
                    exit;

                AccountingPeriod.SetFilter("Starting Date", '>=%1', "Posting Date");
                if AccountingPeriod.IsEmpty() then
                    Error(DeferSchedOutOfBoundsErr);
                CopyHeaderFields();
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                Rec.TestStausOpen();
                if Amount = 0 then
                    Error(ZeroAmountToDeferErr);

                if DeferralHeader.Get("Document No.") then begin
                    if DeferralHeader."Amount to Defer" > 0 then
                        if Amount < 0 then
                            Error(AmountToDeferPositiveErr);
                    if DeferralHeader."Amount to Defer" < 0 then
                        if Amount > 0 then
                            Error(AmountToDeferNegativeErr);
                end;
            end;
        }
        field(10; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(12; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Posting Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Posting Date" = 0D then
            Error(InvalidDeferralLineDateErr);
    end;

    var
        DeferralHeader: Record "MFCC01 Deferral Header";
        DeferralUtilities: Codeunit "MFCC01 Deferral Utilities";
        InvalidPostingDateErr: Label '%1 is not within the range of posting dates for deferrals for your company. Check the user setup for the allowed deferrals posting dates.', Comment = '%1=The date passed in for the posting date.';
        DeferSchedOutOfBoundsErr: Label 'The deferral schedule falls outside the accounting periods that have been set up for the company.';
        InvalidDeferralLineDateErr: Label 'The posting date for this deferral schedule line is not valid.';
        ZeroAmountToDeferErr: Label 'The deferral amount cannot be 0.';
        AmountToDeferPositiveErr: Label 'The deferral amount must be positive.';
        AmountToDeferNegativeErr: Label 'The deferral amount must be negative.';


    procedure TestStausOpen()

    begin
        GetDeferralHeader();
        DeferralHeader.TestField(Status, DeferralHeader.Status::Open);
    end;

    local procedure GetDeferralHeader()
    begin
        DeferralHeader.Get( Rec."Document No.");
    end;

    local procedure CopyHeaderFields()
    begin
        Rec."Customer No." := DeferralHeader."Customer No.";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePostingDate(var DeferralLine: Record "MFCC01 Deferral Line"; xDeferralLine: Record "MFCC01 Deferral Line"; CallingFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;
}

