tableextension 60003 "MFCC01 Vendor Bank Account" extends "Vendor Bank Account"
{
    fields
    {
        // Add changes to table fields here
        field(60000; "Status"; Enum MFCC01VendorBankStatus)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(60001; "First Time Approval"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
    trigger OnBeforeinsert()
    var
        VBA: Record "Vendor Bank Account";
    Begin
        VBA.SetRange("Vendor No.", Rec."Vendor No.");
        VBA.Setfilter(Code, '<>%1', Rec.Code);
        IF VBA.IsEmpty() then
            Rec."First Time Approval" := True;
    End;

    trigger OnModify()
    Begin
        Rec.TestField(Status, Status::Open);
    End;

    procedure PerformManualReopen()
    begin
        Rec.TestField(Status, Rec.Status::Released);
        Rec.Status := Rec.Status::Open;
        Rec.Modify();
    end;

    procedure PerformManualRelease()
    var
        Approvals: Codeunit MFCC01Approvals;
        Text002: Label 'This document can only be released when the approval process is complete.';

    begin
        Rec.TestField(Status, Rec.Status::Open);
        IF Approvals.IsVBAApprovalsWorkflowEnabled(Rec) then
            Error(Text002);
        Rec.Status := Rec.Status::Released;
        Rec.Modify();
    end;
}