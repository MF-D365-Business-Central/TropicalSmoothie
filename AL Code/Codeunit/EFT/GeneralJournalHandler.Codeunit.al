codeunit 60016 "General Journal Handler"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure OnaftervalidateAccountno(var Rec: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        CustomerBatchaccount: Record "Customer Bank Account";
        Cashreceiptjournal: page "Cash Receipt Journal";
    begin
        if Cashreceiptjournal.checkEFTBankaccount(Rec."Journal Template Name", Rec."Journal Batch Name") then
            if Rec."Account Type" = Rec."Account Type"::Customer then
                if Customer.get(Rec."Account No.") then begin
                    CustomerBatchaccount.SetRange("Customer No.", Customer."No.");
                    CustomerBatchaccount.SetRange("Use for Electronic Payments", true);
                    if CustomerBatchaccount.FindFirst() then begin
                        if CustomerBatchaccount.Count = 1 then
                            Rec."Recipient Bank Account" := CustomerBatchaccount.Code;
                        rec."Bank Payment Type" := rec."Bank Payment Type"::"Electronic Payment";
                    end else begin
                        Rec."Recipient Bank Account" := ' ';
                        rec."Bank Payment Type" := rec."Bank Payment Type"::" ";
                    end;
                end;
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnbeforeDeleteEvent', '', false, false)]
    local procedure Onaftervalidate(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var

        Cashreceiptjournal: page "Cash Receipt Journal";
        CashreceiptjournalLbl: Label 'Cash Receipt EFT printed must be equal to No in %1 jounal Template Name =%2, Journal Batch Name =%3 Line No.=%4. Current Value is Yes', Comment = '%1 = Cash Receipt No.; %2 = Journal Template Name; %3 = Journal Batch name; %4 = Line No.';
    begin
        if RunTrigger = false then
            exit;
        if Cashreceiptjournal.checkEFTBankaccount(Rec."Journal Template Name", Rec."Journal Batch Name") then
            if (Rec."Check Printed" = true) then
                Error(CashreceiptjournalLbl, rec.TableCaption, rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.");
    end;
}