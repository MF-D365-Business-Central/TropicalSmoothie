codeunit 60017 "MFCC01Generate EFT"
{

    trigger OnRun()
    begin
    end;

    var
        BankAccount: Record "Bank Account";
        DummyLastEFTExportWorkset: Record "EFT Export Workset";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        DataCompression: Codeunit "Data Compression";

        ACHFileCreated: Boolean;
        IATFileCreated: Boolean;
        Path: Text;
        NothingToExportErr: Label 'There is nothing to export.';
        ProcessOrderNo: Integer;
        GeneratingFileMsg: Label 'The electronic funds transfer file is now being generated.';
        CustBankAccErr: Label 'Customer No. %1 has no bank account setup for electronic payments.', Comment = '%1 the Customer No.';
        CustMoreThanOneBankAccErr: Label 'Customer No. %1 has more than one bank account setup for electronic payments.', Comment = '%1 the customer No.';
        CustTransitNumNotValidErr: Label 'The specified transit number %1 for customer %2  is not valid.', Comment = '%1 the transit number, %2 The customer  No.';
        ZipFileName: Text;


    procedure ProcessAndGenerateEFTFile(BalAccountNo: Code[20]; SettlementDate: Date; var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        Window: Dialog;
    begin
        InitialChecks(BalAccountNo);

        ACHFileCreated := false;
        IATFileCreated := false;


        Window.Open(GeneratingFileMsg);

        TempEFTExportWorkset.SetRange("Bank Payment Type", 3, 3);
        if TempEFTExportWorkset.FindFirst() then
            StartEFTProcess(SettlementDate, TempEFTExportWorkset, EFTValues);

        EFTValues.SetParentDefCode('');

        TempEFTExportWorkset.Reset();
        TempEFTExportWorkset.SetRange("Bank Payment Type", 4, 4);
        if TempEFTExportWorkset.FindFirst() then
            StartEFTProcess(SettlementDate, TempEFTExportWorkset, EFTValues);
        Window.Close();
    end;

    local procedure InitialChecks(BankAccountNo: Code[20])
    begin
        BankAccount.LockTable();
        BankAccount.Get(BankAccountNo);
        BankAccount.TestField(Blocked, false);
        BankAccount.TestField("Currency Code", '');  // local currency only
        BankAccount.TestField("Export Format");
        BankAccount.TestField("Last Remittance Advice No.");
    end;

    local procedure CheckAndStartExport(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        ExpLauncherEFT: Codeunit "MFCC01Exp. Launcher EFT";
    begin
        if (not ACHFileCreated and
            (TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment")) or
           (not IATFileCreated and
            (TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT"))
        then begin
            if not TempEFTExportWorkset.FindSet() then
                Error(NothingToExportErr);

            ExpLauncherEFT.EFTPaymentProcess(TempEFTExportWorkset, TempNameValueBuffer, DataCompression, ZipFileName, EFTValues);
        end;
    end;

    local procedure SetGenJrnlCheckTransmitted(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LineNo: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.SetRange("Line No.", LineNo);
        if GenJournalLine.FindFirst() then begin
            GenJournalLine."Check Transmitted" := true;
            //GenJournalLine."Check Transmitted" := false;//BR -VEL
            GenJournalLine.Modify();
        end;
    end;

    local procedure IsTestMode() TestMode: Boolean
    begin
        // Check to see if the test mode flag is set (usually via test codeunits by subscribing to OnIsTestMode event)
        OnIsTestMode(TestMode);
    end;

    [Scope('OnPrem')]
    procedure SetSavePath(SavePath: Text)
    begin
        // This allows us to set the path ahead of setting request parameters if we know it or need to set it ahead of time
        // e.g. for unit tests
        Path := SavePath;
    end;


    procedure UpdateEFTExport(var TempEFTExportWorkset: Record "EFT Export Workset" temporary)
    var
        EFTExport: Record "EFT Export";
    begin
        EFTExport.Get(TempEFTExportWorkset."Journal Template Name", TempEFTExportWorkset."Journal Batch Name",
          TempEFTExportWorkset."Line No.", TempEFTExportWorkset."Sequence No.");
        EFTExport."Posting Date" := TempEFTExportWorkset.UserSettleDate;
        EFTExport."Check Printed" := true;
        EFTExport."Check Exported" := true;
        EFTExport."Exported to Payment File" := true;
        EFTExport.Transmitted := true;
        EFTExport.Modify();
        SetGenJrnlCheckTransmitted(TempEFTExportWorkset."Journal Template Name",
          TempEFTExportWorkset."Journal Batch Name", TempEFTExportWorkset."Line No.");
    end;

    local procedure StartEFTProcess(SettlementDate: Date; var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        Dummycust: Record customer;
        CustomerBankAccount: Record "customer Bank Account";
        LocalBankAccount: Record "Bank Account";
        CheckDigitCheck: Boolean;
    begin
        ProcessOrderNo := 1;
        if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT" then begin
            TempEFTExportWorkset.SetCurrentKey("Account Type", "Account No.", "Foreign Exchange Indicator", "Foreign Exchange Ref.Indicator",
              "Foreign Exchange Reference");
            DummyLastEFTExportWorkset."Account Type" := TempEFTExportWorkset."Account Type";
            DummyLastEFTExportWorkset."Account No." := TempEFTExportWorkset."Account No.";
            DummyLastEFTExportWorkset."Foreign Exchange Indicator" := TempEFTExportWorkset."Foreign Exchange Indicator";
            DummyLastEFTExportWorkset."Foreign Exchange Ref.Indicator" := TempEFTExportWorkset."Foreign Exchange Ref.Indicator";
            DummyLastEFTExportWorkset."Foreign Exchange Reference" := TempEFTExportWorkset."Foreign Exchange Reference";
        end;

        repeat
            TempEFTExportWorkset.Pathname := CopyStr(Path, 1, MaxStrLen(TempEFTExportWorkset.Pathname));
            TempEFTExportWorkset.UserSettleDate := SettlementDate;
            if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT" then
                if (DummyLastEFTExportWorkset."Account Type" <> TempEFTExportWorkset."Account Type") or
                   (DummyLastEFTExportWorkset."Account No." <> TempEFTExportWorkset."Account No.") or
                   (DummyLastEFTExportWorkset."Foreign Exchange Indicator" <> TempEFTExportWorkset."Foreign Exchange Indicator") or
                   (DummyLastEFTExportWorkset."Foreign Exchange Ref.Indicator" <> TempEFTExportWorkset."Foreign Exchange Ref.Indicator") or
                   (DummyLastEFTExportWorkset."Foreign Exchange Reference" <> TempEFTExportWorkset."Foreign Exchange Reference")
                then begin
                    ProcessOrderNo := ProcessOrderNo + 1;
                    TempEFTExportWorkset.ProcessOrder := ProcessOrderNo;
                    DummyLastEFTExportWorkset."Account Type" := TempEFTExportWorkset."Account Type";
                    DummyLastEFTExportWorkset."Account No." := TempEFTExportWorkset."Account No.";
                    DummyLastEFTExportWorkset."Foreign Exchange Indicator" := TempEFTExportWorkset."Foreign Exchange Indicator";
                    DummyLastEFTExportWorkset."Foreign Exchange Ref.Indicator" := TempEFTExportWorkset."Foreign Exchange Ref.Indicator";
                    DummyLastEFTExportWorkset."Foreign Exchange Reference" := TempEFTExportWorkset."Foreign Exchange Reference";
                end else
                    TempEFTExportWorkset.ProcessOrder := ProcessOrderNo;
            if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment" then
                TempEFTExportWorkset.ProcessOrder := 1;
            TempEFTExportWorkset.Modify();
        until TempEFTExportWorkset.Next() = 0;
        Commit();
        if TempEFTExportWorkset.FindFirst() then
            repeat
                LocalBankAccount.Get(TempEFTExportWorkset."Bank Account No.");
                CheckDigitCheck := (LocalBankAccount."Export Format" <> LocalBankAccount."Export Format"::CA);
                CheckCustTransitNum(TempEFTExportWorkset."Account No.", Dummycust, CustomerBankAccount, CheckDigitCheck);
                CustomerBankAccount.TestField("Bank Account No.");
            until TempEFTExportWorkset.Next() = 0;


        TempEFTExportWorkset.FindFirst();

        if ProcessOrderNo >= 1 then
            repeat
                TempEFTExportWorkset.SetRange(ProcessOrder, ProcessOrderNo, ProcessOrderNo);
                CheckAndStartExport(TempEFTExportWorkset, EFTValues);
                ProcessOrderNo := ProcessOrderNo - 1;
            until ProcessOrderNo = 0;

    end;

    procedure CheckcustTransitNum(AccountNo: Code[20]; var customer: Record customer; var customerBankAccount: Record "customer Bank Account"; CheckTheCheckDigit: Boolean)
    var
        ExportPaymentsACHCheck: Codeunit "Export Payments (ACH)";
    begin
        customer.Get(AccountNo);
        customer.TestField(Blocked, customer.Blocked::" ");
        customer.TestField("Privacy Blocked", false);

        customerBankAccount.SetRange("customer no.", AccountNo);
        customerBankAccount.SetRange("Use for Electronic Payments", true);
        customerBankAccount.FindFirst();

        if customerBankAccount.Count() < 1 then
            Error(StrSubstNo(CustBankAccErr, customer."No."));
        if customerBankAccount.Count() > 1 then
            Error(StrSubstNo(custMoreThanOneBankAccErr, customer."No."));

        if CheckTheCheckDigit then
            if not ExportPaymentsACHCheck.CheckDigit(customerBankAccount."Transit No.") then
                Error(StrSubstNo(CustTransitNumNotValidErr, customerBankAccount."Transit No.", customer."No."));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsTestMode(var TestMode: Boolean)
    begin
    end;
}

