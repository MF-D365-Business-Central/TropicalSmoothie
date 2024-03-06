codeunit 60013 "MFCC01Export EFT (IAT)"
{
    trigger OnRun()
    begin
    end;

    var
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";

        ExportEFTACH: Codeunit "MFCC01Export EFT (ACH)";
        ExportPaymentsACH: Codeunit "Export Payments (ACH)";
        RecordLength: Integer;
        BlockingFactor: Integer;
        BlockCount: Integer;
        FileHashTotal: Decimal;
        BatchHashTotal: Decimal;

        FileDate: Date;
        FileTime: Time;
        DummyModifierValues: array[26] of Code[1];
        DestinationAcctType: Text[1];
        DestinationAcctNo: Code[20];
        DestinationName: Text[100];
        DestinationFederalIDNo: Text[30];
        DestinationAddress: Text[250];
        DestinationCity: Text[30];
        DestinationCountryCode: Code[10];
        DestinationCounty: Text[30];
        DestinationPostCode: Code[20];
        DestinationBankName: Text[100];
        DestinationBankTransitNo: Text[20];
        DestinationBankAcctNo: Text[30];
        DestinationBankCountryCode: Code[10];
        DestinationBankCurrencyCode: Code[10];
        IsNotValidErr: Label 'The specified transit number is not valid.', Comment = 'Field Value is not valid';
        //AlreadyExistsErr: Label 'The file already exists. Check the "E-Recevbl Exp. File Name VEL" field in the bank account.';
        VendorBankAccErr: Label 'The vendor has no bank account setup for electronic payments.';
        VendorMoreThanOneBankAccErr: Label 'The vendor has more than one bank account setup for electronic payments.';
        CustomerBankAccErr: Label 'The customer has no bank account setup for electronic payments.';
        CustomerMoreThanOneBankAccErr: Label 'The customer has more than one bank account setup for electronic payments.';
        ReferErr: Label 'Either Account type or balance account type must refer to either a vendor or a customer for an electronic payment.';
        IsBlockedErr: Label 'Account type is blocked for processing.';
        PrivacyBlockedErr: Label 'Account type is blocked for privacy.';

    procedure StartExportFile(BankAccountNo: Code[20]; ReferenceCode: Code[10]; DataExchEntryNo: Integer; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        ACHUSHeader: Record "ACH US Header";
        i: Integer;
    begin
        ExportEFTACH.BuildIDModifier(DummyModifierValues);

        CompanyInformation.Get();
        CompanyInformation.TestField("Federal ID No.");

        BankAccount.LockTable();
        BankAccount.Get(BankAccountNo);
        BankAccount.TestField("Export Format", BankAccount."Export Format"::US);
        BankAccount.TestField("Transit No.");
        if not ExportPaymentsACH.CheckDigit(BankAccount."Transit No.") then
            Error(IsNotValidErr);
        BankAccount.TestField("E-Recevbl Exp. File Name");
        BankAccount.TestField(Blocked, false);

        if BankAccount."Last ACH File ID Modifier" = '' then
            BankAccount."Last ACH File ID Modifier" := 'A'
        else begin
            i := 1;
            while (i < ArrayLen(DummyModifierValues)) and
                  (BankAccount."Last ACH File ID Modifier" <> DummyModifierValues[i])
            do
                i := i + 1;
            if i = ArrayLen(DummyModifierValues) then
                i := 1
            else
                i := i + 1;
            BankAccount."Last ACH File ID Modifier" := DummyModifierValues[i];
        end;
        BankAccount.Modify();

        FileDate := Today();
        FileTime := Time();
        EFTValues.SetNoOfRec(0);
        FileHashTotal := 0;
        EFTValues.SetFileHashTotal(FileHashTotal);
        EFTValues.SetTotalFileDebit(0);
        EFTValues.SetTotalFileCredit(0);
        EFTValues.SetFileEntryAddendaCount(0);
        EFTValues.SetBatchCount(0);
        EFTValues.SetBatchNo(0);
        BlockingFactor := 10;
        RecordLength := 94;

        ACHUSHeader.Get(DataExchEntryNo);
        ACHUSHeader."File Record Type" := 1;
        ACHUSHeader."Priority Code" := 1;
        ACHUSHeader."Transit Routing Number" := BankAccount."Transit No.";
        ACHUSHeader."Federal ID No." := DelChr(CompanyInformation."Federal ID No.", '=', ' .,-');
        ACHUSHeader."File Creation Date" := FileDate;
        ACHUSHeader."File Creation Time" := FileTime;
        ACHUSHeader."File ID Modifier" := BankAccount."Last ACH File ID Modifier";
        ACHUSHeader."Record Size" := RecordLength;
        ACHUSHeader."Blocking Factor" := BlockingFactor;
        ACHUSHeader."Format Code" := 1;
        ACHUSHeader."Bank Name" := BankAccount.Name;
        ACHUSHeader."Bank Account Number" := BankAccount."No.";
        ACHUSHeader."Company Name" := CompanyInformation.Name;
        ACHUSHeader.Reference := ReferenceCode;
        ACHUSHeader.Modify();
        EFTValues.SetNoOfRec := EFTValues.GetNoOfRec() + 1;
    end;

    procedure StartExportBatch(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; SettleDate: Date; DataExchEntryNo: Integer; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        GLSetup: Record "General Ledger Setup";
        ACHUSHeader: Record "ACH US Header";
    begin
        GetRecipientData(TempEFTExportWorkset);

        EFTValues.SetBatchNo(EFTValues.GetBatchNo() + 1);
        BatchHashTotal := 0;
        EFTValues.SetBatchHashTotal(BatchHashTotal);
        EFTValues.SetTotalBatchDebit(0);
        EFTValues.SetTotalBatchCredit(0);
        EFTValues.SetEntryAddendaCount(0);
        EFTValues.SetTraceNo(0);

        ACHUSHeader.Get(DataExchEntryNo);
        ACHUSHeader."Batch Record Type" := 5;
        ACHUSHeader."Service Class Code" := '';
        // This is to maintain black value if no selection made on the Payment Journal otherwise the value is used.
        if TempEFTExportWorkset."Foreign Exchange Indicator" = 0 then
            ACHUSHeader."Foreign Exchange Indicator" := ''
        else
            ACHUSHeader."Foreign Exchange Indicator" := Format(TempEFTExportWorkset."Foreign Exchange Indicator");

        if TempEFTExportWorkset."Foreign Exchange Ref.Indicator" = 0 then
            ACHUSHeader."Foreign Exchange Ref Indicator" := ''
        else
            ACHUSHeader."Foreign Exchange Ref Indicator" := Format(TempEFTExportWorkset."Foreign Exchange Ref.Indicator");

        ACHUSHeader."Foreign Exchange Reference" := TempEFTExportWorkset."Foreign Exchange Reference";
        ACHUSHeader."Destination Country Code" := DestinationCountryCode;
        ACHUSHeader."Federal ID No." := CompanyInformation."Federal ID No.";
        ACHUSHeader."Standard Class Code" := 'IAT';
        ACHUSHeader."Company Entry Description" := TempEFTExportWorkset."Source Code";
        if BankAccount."Currency Code" = '' then begin
            GLSetup.Get();
            ACHUSHeader."Currency Type" := GLSetup."LCY Code";
        end else
            ACHUSHeader."Currency Type" := BankAccount."Currency Code";
        if DestinationBankCurrencyCode = '' then begin
            GLSetup.Get();
            ACHUSHeader."Destination Currency Code" := GLSetup."LCY Code";
        end else
            ACHUSHeader."Destination Currency Code" := DestinationBankCurrencyCode;
        ACHUSHeader."Company Descriptive Date" := WorkDate();
        //ACHUSHeader."Payment Date"='';
        ACHUSHeader."Effective Date" := SettleDate;
        ACHUSHeader."Payment Date" := ' ';
        ACHUSHeader."Transit Routing Number" := BankAccount."Transit No.";
        ACHUSHeader."Batch Number" := EFTValues.GetBatchNo();
        ACHUSHeader.Modify();

        EFTValues.SetNoOfRec := EFTValues.GetNoOfRec() + 1;
    end;

    procedure ExportElectronicPayment(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; PaymentAmount: Decimal; DataExchEntryNo: Integer; DataExchLineDefCode: Code[20]; var EFTValues: Codeunit "MFCC01EFT Values"): Code[250]
    var
        ACHUSDetail: Record "ACH US Detail";
        EntryDetailSeqNo: Text[7];
        DemandCredit: Boolean;
        IATEntryTraceNo: Text[50];
    begin
        GetRecipientData(TempEFTExportWorkset);

        if PaymentAmount = 0 then
            exit('');
        DemandCredit := (PaymentAmount < 0);
        PaymentAmount := Abs(PaymentAmount);

        if EFTValues.GetParentBoolean() then
            EFTValues.SetTraceNo(EFTValues.GetTraceNo() + 1);

        EntryDetailSeqNo := '';

        // Detail lines
        ACHUSDetail.Get(DataExchEntryNo, DataExchLineDefCode);
        ACHUSDetail."Record Type" := 6;
        if DemandCredit then
            ACHUSDetail."Transaction Code" := 22
        else
            ACHUSDetail."Transaction Code" := 27;
        ACHUSDetail."Destination Transit Number" := DestinationBankTransitNo;
        if TempEFTExportWorkset."Transaction Type Code" = 0 then
            ACHUSDetail."Transaction Type Code" := ''
        else
            ACHUSDetail."Transaction Type Code" := Format(TempEFTExportWorkset."Transaction Type Code");
        ACHUSDetail."Payment Amount" := PaymentAmount;
        ACHUSDetail."Payee Transit Routing Number" := BankAccount."Transit No.";
        ACHUSDetail."Payee Bank Account Number" := DelChr(DestinationBankAcctNo, '=', ' ');
        // This is to maintain black value if no selection made on the Payment Journal otherwise the value is used.
        if TempEFTExportWorkset."Gateway Operator OFAC Scr.Inc" = 0 then
            ACHUSDetail."Gateway Operator OFAC Scr.Inc" := ''
        else
            ACHUSDetail."Gateway Operator OFAC Scr.Inc" := Format(TempEFTExportWorkset."Gateway Operator OFAC Scr.Inc");
        if TempEFTExportWorkset."Secondary OFAC Scr.Indicator" = 0 then
            ACHUSDetail."Secondary OFAC Scr.Indicator" := ''
        else
            ACHUSDetail."Secondary OFAC Scr.Indicator" := Format(TempEFTExportWorkset."Secondary OFAC Scr.Indicator");
        ACHUSDetail."IAT Entry Trace Number" := ExportEFTACH.GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");

        IATEntryTraceNo := ExportEFTACH.GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
            if DemandCredit then
                EFTValues.SetTotalBatchCredit(EFTValues.GetTotalBatchCredit() + PaymentAmount)
            else
                EFTValues.SetTotalBatchDebit(EFTValues.GetTotalBatchDebit() + PaymentAmount);
            IncrementHashTotal(BatchHashTotal, MakeHash(CopyStr(DestinationBankTransitNo, 1, 8)));
            EFTValues.SetBatchHashTotal(BatchHashTotal);
        end;

        // Addenda Record 1
        ACHUSDetail."Addenda Record Type" := 7;
        ACHUSDetail."Payee Name" := DestinationName;
        ACHUSDetail."Payment Amount" := TempEFTExportWorkset."Amount (LCY)";
        // EntryDetailSeqNo := COPYSTR(IATEntryTraceNo,STRLEN(IATEntryTraceNo) - 6,STRLEN(IATEntryTraceNo));
        EntryDetailSeqNo := CopyStr(IATEntryTraceNo, StrLen(IATEntryTraceNo) - 6, 7);
        ACHUSDetail."Entry Detail Sequence No" := EntryDetailSeqNo;

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        // Addenda Record 2
        ACHUSDetail."Company Name" := CompanyInformation.Name;
        ACHUSDetail."Company Address" :=
          CopyStr(CompanyInformation.Address + ' ' + CompanyInformation."Address 2", 1, MaxStrLen(ACHUSDetail."Company Address"));

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        // Addenda Record 3
        ACHUSDetail."Company City County" := CompanyInformation.City + '*' + CompanyInformation.County + '\';
        ACHUSDetail."Cmpy CntryRegionCode PostCode" := CompanyInformation."Country/Region Code" + '*' +
          CompanyInformation."Post Code" + '\';

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        // Addenda Record 4
        ACHUSDetail."Bank Name" := BankAccount.Name;
        // This is to maintain black value if no selection made on the Payment Journal otherwise the value is used.
        if TempEFTExportWorkset."Origin. DFI ID Qualifier" = 0 then
            ACHUSDetail."Origin. DFI ID Qualifier" := ''
        else
            ACHUSDetail."Origin. DFI ID Qualifier" := Format(TempEFTExportWorkset."Origin. DFI ID Qualifier");
        ACHUSDetail."Bank Transit Routing Number" := PadStr(BankAccount."Transit No.", 8);
        ACHUSDetail."Bank CountryRegion Code" := BankAccount."Country/Region Code";
        ACHUSDetail."Origin Bank Branch" := BankAccount."Country/Region Code";

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        // Addenda Record 5
        ACHUSDetail."Destination Bank" := DestinationBankName;
        // This is to maintain black value if no selection made on the Payment Journal otherwise the value is used.
        if TempEFTExportWorkset."Receiv. DFI ID Qualifier" = 0 then
            ACHUSDetail."Receiv. DFI ID Qualifier" := ''
        else
            ACHUSDetail."Receiv. DFI ID Qualifier" := Format(TempEFTExportWorkset."Receiv. DFI ID Qualifier");
        ACHUSDetail."Destination Transit Number" := DestinationBankTransitNo;
        ACHUSDetail."Destination Bank Country Code" := DestinationBankCountryCode;
        ACHUSDetail."Destination Bank Branch" := DestinationBankCountryCode;

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        // Addenda Record 6
        ACHUSDetail."Destination Federal ID No." := DestinationFederalIDNo;
        ACHUSDetail."Destination Address" := DestinationAddress;

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;
        ACHUSDetail."Payee ID/Cross Reference Numbe" := DestinationAcctNo;
        ACHUSDetail."Discretionary Data" := DestinationAcctType;
        ACHUSDetail."Trace Number" := ExportEFTACH.GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");
        // Addenda Record 7
        ACHUSDetail."Destination City County Code" := DestinationCity + '*' + DestinationCounty + '\';
        ACHUSDetail."Destination CntryCode PostCode" := DestinationCountryCode + '*' + DestinationPostCode + '\';
        ACHUSDetail.Modify();

        if EFTValues.GetParentBoolean() then begin
            EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
            EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        end;

        exit(GenerateFullTraceNoCode(EFTValues.GetTraceNo(), EFTValues));
    end;

    procedure EndExportBatch(DataExchEntryNo: Integer; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        ACHUSFooter: Record "ACH US Footer";
    begin
        ACHUSFooter.Get(DataExchEntryNo);
        ACHUSFooter."Batch Record Type" := 8;
        ACHUSFooter."Service Class Code" := '';
        ACHUSFooter."Entry Addenda Count" := EFTValues.GetEntryAddendaCount();
        ACHUSFooter."Batch Hash Total" := EFTValues.GetBatchHashTotal();
        ACHUSFooter."Total Batch Credit Amount" := EFTValues.GetTotalBatchCredit();
        ACHUSFooter."Total Batch Debit Amount" := EFTValues.GetTotalBatchDebit();
        ACHUSFooter."Federal ID No." := DelChr(CompanyInformation."Federal ID No.", '=', ' .,-');
        ACHUSFooter."Transit Routing Number" := BankAccount."Transit No.";
        ACHUSFooter."Batch Number" := EFTValues.GetBatchNo();
        ACHUSFooter.Modify();

        EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
        EFTValues.SetBatchCount(EFTValues.GetBatchCount() + 1);
        IncrementHashTotal(FileHashTotal, EFTValues.GetBatchHashTotal());
        EFTValues.SetFileHashTotal(FileHashTotal);
        EFTValues.SetTotalFileDebit(EFTValues.GetTotalFileDebit() + EFTValues.GetTotalBatchDebit());
        EFTValues.SetTotalFileCredit(EFTValues.GetTotalFileCredit() + EFTValues.GetTotalBatchCredit());
        EFTValues.SetFileEntryAddendaCount(EFTValues.GetFileEntryAddendaCount() + EFTValues.GetEntryAddendaCount());
    end;

    procedure EndExportFile(DataExchEntryNo: Integer; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        ACHUSFooter: Record "ACH US Footer";
    begin
        BlockCount := (EFTValues.GetNoOfRec() + 1) div BlockingFactor;
        if (EFTValues.GetNoOfRec() + 1) mod BlockingFactor <> 0 then
            BlockCount := BlockCount + 1;

        ACHUSFooter.Get(DataExchEntryNo);
        ACHUSFooter."Batch Count" := EFTValues.GetBatchCount();
        ACHUSFooter."Block Count" := BlockCount;
        ACHUSFooter."Entry Addenda Count" := EFTValues.GetFileEntryAddendaCount();
        ACHUSFooter."File Hash Total" := EFTValues.GetFileHashTotal();
        ACHUSFooter."Total File Debit Amount" := EFTValues.GetTotalFileDebit();
        ACHUSFooter."Total File Credit Amount" := EFTValues.GetTotalFileCredit();
        ACHUSFooter.Modify();

        EFTValues.SetNoOfRec := (EFTValues.GetNoOfRec() + 1);
    end;

    local procedure GenerateFullTraceNoCode(TraceNo: Integer; var EFTValues: Codeunit "MFCC01EFT Values"): Code[250]
    var
        TraceCode: Text[250];
    begin
        TraceCode := '';
        TraceCode := Format(FileDate, 0, '<Year><Month,2><Day,2>') + BankAccount."Last ACH File ID Modifier" +
          Format(EFTValues.GetBatchNo()) + Format(ExportEFTACH.GenerateTraceNoCode(TraceNo, BankAccount."Transit No."));
        exit(TraceCode);
    end;

    local procedure IncrementHashTotal(var HashTotal: Decimal; HashIncrement: Decimal)
    var
        SubTotal: Decimal;
    begin
        SubTotal := HashTotal + HashIncrement;
        if SubTotal < 10000000000.0 then
            HashTotal := SubTotal
        else
            HashTotal := SubTotal - 10000000000.0;
    end;

    local procedure MakeHash(InputString: Text[30]): Decimal
    var
        HashAmt: Decimal;
    begin
        InputString := DelChr(InputString, '=', '.,- ');
        if Evaluate(HashAmt, InputString) then
            exit(HashAmt);

        exit(0);
    end;

    //[Scope('OnPrem')]
    // procedure DownloadWebclientZip(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    // var
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipTempBlob: Codeunit "Temp Blob";
    //     ServerTempFileInStream: InStream;
    //     ZipInStream: InStream;
    //     ZipOutStream: OutStream;
    //     ToFile: Text;
    // begin
    //     // Download the .zip file containing the reports if one was generated (usually from being on the web client)
    //     // if (ZipFileName <> '') and TempNameValueBuffer.FindSet then
    //     //     // If there's a single file, download it directly instead of the zip file
    //     //     if TempNameValueBuffer.Count = 1 then
    //     //         FileManagement.DownloadHandler(TempNameValueBuffer.Value, '', '', '', TempNameValueBuffer.Name)
    //     //     else begin
    //     //         repeat
    //     //             FileManagement.BLOBImportFromServerFile(TempBlob, TempNameValueBuffer.Value);
    //     //             TempBlob.CreateInStream(ServerTempFileInStream);
    //     //             DataCompression.AddEntry(ServerTempFileInStream, TempNameValueBuffer.Name);
    //     //             TempEraseFileNameValueBuffer.AddNewEntry(TempNameValueBuffer.Value, '');
    //     //         until TempNameValueBuffer.Next = 0;
    //     //         ZipTempBlob.CreateOutStream(ZipOutStream);
    //     //         DataCompression.SaveZipArchive(ZipOutStream);
    //     //         DataCompression.CloseZipArchive();
    //     //         ZipTempBlob.CreateInStream(ZipInStream);
    //     //         ToFile := ZipDownloadTxt;
    //     //         DownloadFromStream(ZipInStream, '', '', '', ToFile);
    //     //     end;

    //     CleanupTempFiles;
    // end;

    // [Scope('OnPrem')]
    // procedure AddFileToClientZip(TempFileName: Text; ClientFileName: Text; var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    // begin
    //     if StrLen(TempFileName) > 250 then
    //         Error(PathLengthErr);

    //     if StrLen(ClientFileName) > 250 then
    //         Error(PathLengthErr);

    //     // Ensure we have a zip file object
    //     //   if ZipFileName = '' then begin
    //     //     ZipFileName := FileManagement.ServerTempFileName('zip');
    //     //   DataCompression.CreateZipArchive;
    //     // end;

    //     TempNameValueBuffer.AddNewEntry(CopyStr(ClientFileName, 1, 250), CopyStr(TempFileName, 1, 250));
    // end;

    // local procedure CleanupTempFiles()
    // var
    //     DeleteError: Boolean;
    // begin
    //     // Sometimes file handles are kept by .NET - we try to delete what we can.
    //     if TempEraseFileNameValueBuffer.FindSet then
    //         repeat
    //             if not TryDeleteFile(TempEraseFileNameValueBuffer.Name) then
    //                 DeleteError := true;
    //         until TempEraseFileNameValueBuffer.Next = 0;

    //     if DeleteError then
    //         Error('');
    // end;

    [TryFunction]
    local procedure TryDeleteFile(FileName: Text)
    begin
        //    FileManagement.DeleteServerFile(FileName);
    end;

    procedure GetRecipientData(var TempEFTExportWorkset: Record "EFT Export Workset" temporary)
    begin
        if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."Account Type"::Vendor then begin
            DestinationAcctType := 'V';
            DestinationAcctNo := TempEFTExportWorkset."Account No.";
        end else
            if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."Account Type"::Customer then begin
                DestinationAcctType := 'C';
                DestinationAcctNo := TempEFTExportWorkset."Account No.";
            end else
                if TempEFTExportWorkset."Bal. Account Type" = TempEFTExportWorkset."Bal. Account Type"::Vendor then begin
                    DestinationAcctType := 'V';
                    DestinationAcctNo := TempEFTExportWorkset."Bal. Account No.";
                end else
                    if TempEFTExportWorkset."Bal. Account Type" = TempEFTExportWorkset."Bal. Account Type"::Customer then begin
                        DestinationAcctType := 'C';
                        DestinationAcctNo := TempEFTExportWorkset."Bal. Account No.";
                    end else
                        Error(ReferErr);

        if DestinationAcctType = 'V' then begin
            Vendor.Get(DestinationAcctNo);
            Vendor.TestField(Blocked, Vendor.Blocked::" ");
            Vendor.TestField("Privacy Blocked", false);
            DestinationName := Vendor.Name;
            DestinationFederalIDNo := Vendor."Federal ID No.";
            DestinationAddress := Vendor.Address + ' ' + Vendor."Address 2";
            DestinationCity := Vendor.City;
            DestinationCountryCode := Vendor."Country/Region Code";
            DestinationCounty := Vendor.County;
            DestinationPostCode := Vendor."Post Code";

            VendorBankAccount.SetRange("Vendor No.", DestinationAcctNo);
            VendorBankAccount.SetRange("Use for Electronic Payments", true);
            VendorBankAccount.FindFirst();

            if VendorBankAccount.Count() < 1 then
                Error(VendorBankAccErr);
            if VendorBankAccount.Count() > 1 then
                Error(VendorMoreThanOneBankAccErr);

            if not ExportPaymentsACH.CheckDigit(VendorBankAccount."Transit No.") then
                Error(IsNotValidErr);

            VendorBankAccount.TestField("Bank Account No.");
            DestinationBankName := VendorBankAccount.Name;
            DestinationBankTransitNo := VendorBankAccount."Transit No.";
            DestinationBankAcctNo := VendorBankAccount."Bank Account No.";
            DestinationBankCurrencyCode := VendorBankAccount."Currency Code";
            DestinationBankCountryCode := VendorBankAccount."Country/Region Code";
        end else
            if DestinationAcctType = 'C' then begin
                Customer.Get(DestinationAcctNo);
                if Customer."Privacy Blocked" then
                    Error(PrivacyBlockedErr);
                if Customer.Blocked in [Customer.Blocked::All] then
                    Error(IsBlockedErr);

                DestinationName := Customer.Name;
                DestinationFederalIDNo := ' ';
                DestinationAddress := Customer.Address + ' ' + Customer."Address 2";
                DestinationCity := Customer.City;
                DestinationCountryCode := Customer."Country/Region Code";
                DestinationCounty := Customer.County;
                DestinationPostCode := Customer."Post Code";

                CustomerBankAccount.SetRange("Customer No.", DestinationAcctNo);
                CustomerBankAccount.SetRange("Use for Electronic Payments", true);
                CustomerBankAccount.FindFirst();

                if CustomerBankAccount.Count() < 1 then
                    Error(CustomerBankAccErr);
                if CustomerBankAccount.Count() > 1 then
                    Error(CustomerMoreThanOneBankAccErr);

                if not ExportPaymentsACH.CheckDigit(CustomerBankAccount."Transit No.") then
                    Error(IsNotValidErr);
                CustomerBankAccount.TestField("Bank Account No.");
                DestinationBankName := CustomerBankAccount.Name;
                DestinationBankTransitNo := CustomerBankAccount."Transit No.";
                DestinationBankAcctNo := CustomerBankAccount."Bank Account No.";
                DestinationBankCurrencyCode := CustomerBankAccount."Currency Code";
                DestinationBankCountryCode := CustomerBankAccount."Country/Region Code";
            end;
    end;
}
