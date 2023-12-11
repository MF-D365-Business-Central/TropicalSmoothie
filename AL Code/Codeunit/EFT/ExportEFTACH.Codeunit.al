codeunit 60012 "MFCC01Export EFT (ACH)"
{

    trigger OnRun()
    begin
    end;

    var
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
        TempEraseFileNameValueBuffer: Record "Name/Value Buffer" temporary;
        EFTValues: Codeunit "MFCC01EFT Values";
        ExportPaymentsACH: Codeunit "Export Payments (ACH)";
        BatchHashTotal: Decimal;
        FileHashTotal: Decimal;
        RecordLength: Integer;
        BlockingFactor: Integer;
        BlockCount: Integer;
        FileDate: Date;
        FileTime: Time;
        ModifierValues: array[26] of Code[1];
        IsNotValidErr: Label 'The specified transit number is not valid.';
        CustomerBankAccErr: Label 'The customer has no bank account setup for electronic payments.';
        CustomerMoreThanOneBankAccErr: Label 'The customer has more than one bank account setup for electronic payments.';
        ReferErr: Label 'Either Account type or balance account type must refer to either a vendor or a customer for an electronic payment.';
        IsBlockedErr: Label 'Account type is blocked for processing.';
        PrivacyBlockedErr: Label 'Account type is blocked for privacy.';
    // PathLengthErr: Label 'The file name is too long and cannot be used.', Comment = '%1: a file name, generated by the system';


    procedure StartExportFile(BankAccountNo: Code[20]; ReferenceCode: Code[10]; DataExchEntryNo: Integer)
    var
        ACHUSHeader: Record "ACH US Header";
        i: Integer;
        BankName: Text[100];
    begin
        BuildIDModifier(ModifierValues);

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
        BankName := BankAccount.Name;

        if BankAccount."Last ACH File ID Modifier" = '' then
            BankAccount."Last ACH File ID Modifier" := '1'
        else begin
            i := 1;
            while (i < ArrayLen(ModifierValues)) and
                  (BankAccount."Last ACH File ID Modifier" <> ModifierValues[i])
            do
                i := i + 1;
            if i = ArrayLen(ModifierValues) then
                i := 1
            else
                i := i + 1;
            BankAccount."Last ACH File ID Modifier" := ModifierValues[i];
        end;
        BankAccount."Last E-Pay File Creation No." := BankAccount."Last E-Pay File Creation No." + 1;
        BankAccount.Modify();


        FileDate := Today();
        FileTime := Time();
        EFTValues.SetNoOfRec(0);
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
        ACHUSHeader."Company Name" := CompanyInformation.Name;
        ACHUSHeader.Reference := ReferenceCode;
        ACHUSHeader."Bank Name" := BankName;
        ACHUSHeader.Modify();
    end;


    procedure StartExportBatch(SourceCode: Code[10]; SettleDate: Date; DataExchEntryNo: Integer)
    var
        ACHUSHeader: Record "ACH US Header";
    begin
        EFTValues.SetBatchNo(EFTValues.GetBatchNo() + 1);
        BatchHashTotal := 0;
        EFTValues.SetBatchHashTotal(BatchHashTotal);
        EFTValues.SetTotalBatchDebit(0);
        EFTValues.SetTotalBatchCredit(0);
        EFTValues.SetEntryAddendaCount(0);
        EFTValues.SetTraceNo(0);

        ACHUSHeader.Get(DataExchEntryNo);
        ACHUSHeader."Batch Record Type" := 5;
        ACHUSHeader."Service Class Code" := '200';
        ACHUSHeader."Company Name" := CompanyInformation.Name;
        ACHUSHeader."Federal ID No." := DelChr(CompanyInformation."Federal ID No.", '=', ' .,-');
        ACHUSHeader."Standard Class Code" := '';
        ACHUSHeader."Company Entry Description" := SourceCode;
        //ACHUSHeader."Payment Date" := Format(WorkDate(), 0, '<Year><Month,2><Day,2>');
        ACHUSHeader."Payment Date" := ' ';
        ACHUSHeader."Company Descriptive Date" := WorkDate();
        ACHUSHeader."Effective Date" := SettleDate;
        ACHUSHeader."Originator Status Code" := 1;
        ACHUSHeader."Transit Routing Number" := BankAccount."Transit No.";
        ACHUSHeader."Batch Number" := EFTValues.GetBatchNo();
        ACHUSHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure ExportOffSettingDebit(DataExchEntryNo: Integer): Code[30]
    var
        ACHUSDetail: Record "ACH US Detail";
    begin
        EFTValues.SetTraceNo(EFTValues.GetTraceNo() + 1);

        ACHUSDetail.Get(DataExchEntryNo);
        ACHUSDetail."Record Type" := 6;
        ACHUSDetail."Transaction Code" := 27;
        ACHUSDetail."Payee Transit Routing Number" := BankAccount."Transit No.";
        ACHUSDetail."Payee Bank Account Number" := DelChr(BankAccount."Bank Account No.", '=', ' ');
        ACHUSDetail."Payment Amount" := EFTValues.GetTotalBatchCredit();
        ACHUSDetail."Federal ID No." := DelChr(CompanyInformation."Federal ID No.", '=', ' .,-');
        ACHUSDetail."Payee Name" := CompanyInformation.Name;
        ACHUSDetail."Addenda Record Indicator" := 0;
        ACHUSDetail."Trace Number" := GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");
        ACHUSDetail.Modify();

        EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        IncrementHashTotal(BatchHashTotal, MakeHash(CopyStr(BankAccount."Transit No.", 1, 8)));
        EFTValues.SetBatchHashTotal(BatchHashTotal);
        EFTValues.SetTotalBatchDebit(EFTValues.GetTotalBatchCredit());

        exit(GenerateFullTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No."));
    end;


    procedure ExportElectronicPayment(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; PaymentAmount: Decimal; DataExchEntryNo: Integer; DataExchLineDefCode: Code[20]): Code[30]
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        ACHUSDetail: Record "ACH US Detail";
        AcctType: Text[1];
        AcctNo: Code[20];
        AcctName: Text[16];
        BankAcctNo: Text[30];
        TransitNo: Text[20];
        DemandCredit: Boolean;
    begin
        // NOTE:  If PaymentAmount is Positive, then we are Receiving money.
        // If PaymentAmount is Negative, then we are Sending money.
        if PaymentAmount = 0 then
            exit('');


        DemandCredit := (PaymentAmount > 0);
        PaymentAmount := Abs(PaymentAmount);

        if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."Account Type"::Vendor then begin
            AcctType := 'V';
            AcctNo := TempEFTExportWorkset."Account No.";
        end else
            if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."Account Type"::Customer then begin
                AcctType := 'C';
                AcctNo := TempEFTExportWorkset."Account No.";
            end else
                if TempEFTExportWorkset."Bal. Account Type" = TempEFTExportWorkset."Bal. Account Type"::Vendor then begin
                    AcctType := 'V';
                    AcctNo := TempEFTExportWorkset."Bal. Account No.";
                end else
                    if TempEFTExportWorkset."Bal. Account Type" = TempEFTExportWorkset."Bal. Account Type"::Customer then begin
                        AcctType := 'C';
                        AcctNo := TempEFTExportWorkset."Bal. Account No.";
                    end else
                        Error(ReferErr);

        if AcctType = 'V' then begin
            //        ExportPaymentsACH.CheckVendorTransitNum(AcctNo, Vendor, VendorBankAccount, true);

            AcctName := CopyStr(Vendor.Name, 1, MaxStrLen(AcctName));
            VendorBankAccount.TestField("Bank Account No.");
            TransitNo := VendorBankAccount."Transit No.";
            BankAcctNo := VendorBankAccount."Bank Account No.";
        end else
            if AcctType = 'C' then begin
                Customer.Get(AcctNo);
                if Customer."Privacy Blocked" then
                    Error(IsBlockedErr);
                if Customer.Blocked in [Customer.Blocked::All] then
                    Error(PrivacyBlockedErr);
                AcctName := CopyStr(Customer.Name, 1, MaxStrLen(AcctName));
                CustomerBankAccount.SetRange("Customer No.", AcctNo);
                CustomerBankAccount.SetRange("Use for Electronic Payments", true);
                CustomerBankAccount.FindFirst();

                if CustomerBankAccount.Count() < 1 then
                    Error(CustomerBankAccErr);
                if CustomerBankAccount.Count() > 1 then
                    Error(CustomerMoreThanOneBankAccErr);

                if not ExportPaymentsACH.CheckDigit(CustomerBankAccount."Transit No.") then
                    Error(IsNotValidErr);

                CustomerBankAccount.TestField("Bank Account No.");
                TransitNo := CustomerBankAccount."Transit No.";
                BankAcctNo := CustomerBankAccount."Bank Account No.";
            end;

        EFTValues.SetTraceNo(EFTValues.GetTraceNo() + 1);

        EFTValues.SetEntryAddendaCount(EFTValues.GetEntryAddendaCount() + 1);
        if DemandCredit then
            EFTValues.SetTotalBatchCredit(EFTValues.GetTotalBatchCredit() + PaymentAmount)
        else
            EFTValues.SetTotalBatchDebit(EFTValues.GetTotalBatchDebit() + PaymentAmount);

        IncrementHashTotal(BatchHashTotal, MakeHash(CopyStr(TransitNo, 1, 8)));
        EFTValues.SetBatchHashTotal(BatchHashTotal);

        ACHUSDetail.Get(DataExchEntryNo, DataExchLineDefCode);
        ACHUSDetail."Record Type" := 6;
        if DemandCredit then
            ACHUSDetail."Transaction Code" := 22
        else
            ACHUSDetail."Transaction Code" := 27;
        ACHUSDetail."Payee Transit Routing Number" := TransitNo;
        ACHUSDetail."Payee Bank Account Number" := DelChr(BankAcctNo, '=', ' ');
        ACHUSDetail."Payment Amount" := PaymentAmount;
        ACHUSDetail."Payee ID/Cross Reference Numbe" := AcctNo;
        ACHUSDetail."Addenda Record Indicator" := 0;
        ACHUSDetail."Payee Name" := AcctName;
        ACHUSDetail."Discretionary Data" := AcctType;
        ACHUSDetail."Trace Number" := GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");
        ACHUSDetail.Modify();

        TempEFTExportWorkset.TraceNumber := GenerateTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No.");

        exit(GenerateFullTraceNoCode(EFTValues.GetTraceNo(), BankAccount."Transit No."));
    end;


    procedure EndExportBatch(DataExchEntryNo: Integer)
    var
        ACHUSFooter: Record "ACH US Footer";
    begin
        EFTValues.SetBatchCount(EFTValues.GetBatchCount() + 1);
        IncrementHashTotal(FileHashTotal, EFTValues.GetBatchHashTotal());
        EFTValues.SetFileHashTotal(FileHashTotal);
        EFTValues.SetTotalFileDebit(EFTValues.GetTotalFileDebit() + EFTValues.GetTotalBatchDebit());
        EFTValues.SetTotalFileCredit(EFTValues.GetTotalFileCredit() + EFTValues.GetTotalBatchCredit());
        EFTValues.SetFileEntryAddendaCount(EFTValues.GetFileEntryAddendaCount() + EFTValues.GetEntryAddendaCount());

        ACHUSFooter.Get(DataExchEntryNo);
        ACHUSFooter."Batch Record Type" := 8;
        ACHUSFooter."Batch Count" := EFTValues.GetBatchCount();
        ACHUSFooter."Service Class Code" := '200';
        ACHUSFooter."Total Batch Credit Amount" := EFTValues.GetTotalBatchCredit();
        ACHUSFooter."Total Batch Debit Amount" := EFTValues.GetTotalBatchDebit();
        ACHUSFooter."Federal ID No." := DelChr(CompanyInformation."Federal ID No.", '=', ' .,-');
        ACHUSFooter."Transit Routing Number" := BankAccount."Transit No.";
        ACHUSFooter."Batch Number" := EFTValues.GetBatchNo();
        ACHUSFooter."Entry Addenda Count" := EFTValues.GetFileEntryAddendaCount();
        ACHUSFooter."Batch Hash Total" := BatchHashTotal;
        ACHUSFooter.Modify();
    end;


    procedure EndExportFile(DataExchEntryNo: Integer; var EFTValues2: Codeunit "MFCC01EFT Values"): Boolean
    var
        ACHUSFooter: Record "ACH US Footer";
    begin
        BlockCount := EFTValues2.GetNoOfRec() div BlockingFactor;
        if EFTValues2.GetNoOfRec() mod BlockingFactor <> 0 then
            BlockCount := BlockCount + 1;

        ACHUSFooter.Get(DataExchEntryNo);
        ACHUSFooter."File Record Type" := 9;
        ACHUSFooter."Batch Count" := EFTValues.GetBatchCount();
        ACHUSFooter."Block Count" := BlockCount;
        ACHUSFooter."Entry Addenda Count" := EFTValues.GetFileEntryAddendaCount();
        ACHUSFooter."File Hash Total" := EFTValues.GetFileHashTotal();
        ACHUSFooter."Total File Debit Amount" := EFTValues.GetTotalFileDebit();
        ACHUSFooter."Total File Credit Amount" := EFTValues.GetTotalFileCredit();
        ACHUSFooter.Modify();

        exit(true);
    end;

    local procedure GenerateFullTraceNoCode(TraceNo: Integer; BankTransitNo: Text[20]): Code[30]
    var
        TraceCode: Text[250];
    begin
        TraceCode := '';
        TraceCode := Format(FileDate, 0, '<Year><Month,2><Day,2>') + BankAccount."Last ACH File ID Modifier" +
          Format(EFTValues.GetBatchNo()) + Format(GenerateTraceNoCode(TraceNo, BankTransitNo));
        exit(TraceCode);
    end;


    procedure GenerateTraceNoCode(TraceNo: Integer; BankTransitNo: Text[20]): Code[15]
    var
        StringConversionManagement: Codeunit StringConversionManagement;
        TraceCode: Text[250];
        TempTraceNo: Text[250];
        Justification: Option Right,Left;
    begin
        TraceCode := '';
        TempTraceNo := StringConversionManagement.GetPaddedString(Format(TraceNo), 7, '0', Justification::Right);
        TraceCode := CopyStr(BankTransitNo, 1, 8) + CopyStr(TempTraceNo, 1, 7);
        exit(TraceCode);
    end;

    local procedure IncrementHashTotal(var HashTotal: Decimal; HashIncrement: Decimal): Decimal
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


    procedure BuildIDModifier(var ModifierVal: array[26] of Code[1])
    begin
        ModifierVal[1] := 'A';
        ModifierVal[2] := 'B';
        ModifierVal[3] := 'C';
        ModifierVal[4] := 'D';
        ModifierVal[5] := 'E';
        ModifierVal[6] := 'F';
        ModifierVal[7] := 'G';
        ModifierVal[8] := 'H';
        ModifierVal[9] := 'I';
        ModifierVal[10] := 'J';
        ModifierVal[11] := 'K';
        ModifierVal[12] := 'L';
        ModifierVal[13] := 'M';
        ModifierVal[14] := 'N';
        ModifierVal[15] := 'O';
        ModifierVal[16] := 'P';
        ModifierVal[17] := 'Q';
        ModifierVal[18] := 'R';
        ModifierVal[19] := 'S';
        ModifierVal[20] := 'T';
        ModifierVal[21] := 'U';
        ModifierVal[22] := 'V';
        ModifierVal[23] := 'W';
        ModifierVal[24] := 'X';
        ModifierVal[25] := 'Y';
        ModifierVal[26] := 'Z';
    end;

    //[Scope('OnPrem')]
    // procedure DownloadWebclientZip(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; ZipFileName: Text; var DataCompression: Codeunit "Data Compression")
    // var
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipTempBlob: Codeunit "Temp Blob";
    //     ServerTempFileInStream: InStream;
    //     ZipInStream: InStream;
    //     ZipOutStream: OutStream;
    //     ToFile: Text;
    // begin
    //     // // Download the .zip file containing the reports if one was generated (usually from being on the web client)
    //     // if (ZipFileName <> '') and TempNameValueBuffer.FindSet then
    //     //     // If there's a single file, download it directly instead of the zip file
    //     //     if TempNameValueBuffer.Count = 1 then
    //     //         FileManagement.DownloadHandler(TempNameValueBuffer.Value, '', '', '', TempNameValueBuffer.Name)
    //     //     else begin
    //     //         repeat
    //     //  //           FileManagement.BLOBImportFromServerFile(TempBlob, TempNameValueBuffer.Value);
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
    // procedure AddFileToClientZip(TempFileName: Text; ClientFileName: Text; var TempNameValueBuffer: Record "Name/Value Buffer" temporary; var ZipFileName: Text; var DataCompression: Codeunit "Data Compression")
    // begin
    //     if StrLen(TempFileName) > 250 then
    //         Error(PathLengthErr);

    //     if StrLen(ClientFileName) > 250 then
    //         Error(PathLengthErr);

    //     // Ensure we have a zip file object
    //     // if ZipFileName = '' then begin
    //     //     ZipFileName := FileManagement.ServerTempFileName('zip');
    //     //     DataCompression.CreateZipArchive;
    //     // end;

    //     TempNameValueBuffer.AddNewEntry(CopyStr(ClientFileName, 1, 250), CopyStr(TempFileName, 1, 250));
    // end;

    local procedure CleanupTempFiles()
    var
        DeleteError: Boolean;
    begin
        // Sometimes file handles are kept by .NET - we try to delete what we can.
        if TempEraseFileNameValueBuffer.FindSet() then
            repeat
                if not TryDeleteFile(TempEraseFileNameValueBuffer.Name) then
                    DeleteError := true;
            until TempEraseFileNameValueBuffer.Next() = 0;

        if DeleteError then
            Error('');
    end;

    [TryFunction]
    local procedure TryDeleteFile(FileName: Text)
    begin
        //   FileManagement.DeleteServerFile(FileName);
    end;

    procedure GetPaymentAmt(TempEFTExportWorkset: Record "EFT Export Workset" temporary): Decimal
    begin
        if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."account type"::"Bank Account" then
            exit(TempEFTExportWorkset."Amount (LCY)");

        exit(-TempEFTExportWorkset."Amount (LCY)");
    end;
}

