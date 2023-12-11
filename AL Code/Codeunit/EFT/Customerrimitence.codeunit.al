codeunit 60008 "Bulk Customer Remit Reporting"
{

    trigger OnRun()
    begin
    end;

    var
        BankAccount: Record "Bank Account";
        TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary;
        RequestPageParametersHelper: codeunit "Request Page Parameters Helper";
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        TempBlobList: Codeunit "Temp Blob List";
        PreviewModeNoExportMsg: Label 'Preview mode is enabled for one or more reports. File export is not possible for any data.';
        VendRemittanceReportSelectionErr: Label 'You must add at least one Vendor Remittance report to the report selection.';
        BankPaymentType: Integer;
        LastUsedTxLbl: Label 'Last used options and filters';


    procedure RunWithRecord(var GenJournalLine: Record "Gen. Journal Line")
    var
        // ReportSelections: Record "Report Selections";
        Vendor: Record Vendor;
        Customer: Record Customer;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLineRecRef: RecordRef;
        GenJournalLineFieldName: Text;
        JoinDatabaseNumber: Integer;
        JoinDatabaseFieldName: Text;
    begin
        GenJournalLine.SetFilter("Check Exported", '=FALSE');



        GenJournalLine.Find('-');
        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        //GenJournalBatch.OnCheckGenJournalLineExportRestrictions;

        // Based on the types of the accounts, set up the report layout joins appropriate.
        case GenJournalLine."Bal. Account Type" of
            GenJournalLine."Bal. Account Type"::Vendor:
                begin
                    GenJournalLineFieldName := GenJournalLine.FieldName("Bal. Account No.");
                    JoinDatabaseNumber := DATABASE::Vendor;
                    JoinDatabaseFieldName := Vendor.FieldName("No.");
                end;
            GenJournalLine."Bal. Account Type"::Customer:
                begin
                    GenJournalLineFieldName := GenJournalLine.FieldName("Bal. Account No.");
                    JoinDatabaseNumber := DATABASE::Customer;
                    JoinDatabaseFieldName := Customer.FieldName("No.");
                end;
            GenJournalLine."Bal. Account Type"::"Bank Account":
                case GenJournalLine."Account Type" of
                    GenJournalLine."Account Type"::Customer:
                        begin
                            GenJournalLineFieldName := GenJournalLine.FieldName("Account No.");
                            JoinDatabaseNumber := DATABASE::Customer;
                            JoinDatabaseFieldName := Customer.FieldName("No.");
                        end;
                    GenJournalLine."Account Type"::Vendor:
                        begin
                            GenJournalLineFieldName := GenJournalLine.FieldName("Account No.");
                            JoinDatabaseNumber := DATABASE::Vendor;
                            JoinDatabaseFieldName := Vendor.FieldName("No.");
                        end;
                end;
            else
                GenJournalLine.FieldError("Bal. Account No.");
        end;

        BankPaymentType := GenJournalLine."Bank Payment Type";

        CheckReportSelectionsExists();
        GenJournalLineRecRef.GetTable(GenJournalLine);
        //GenJournalLineRecRef.SetView(GenJournalLine.GetView);
        // Set up data, request pages, etc.
        /*CustomLayoutReporting.InitializeData( BAN01
          ReportSelections.Usage::"V.Remittance", GenJournalLineRecRef,
          GenJournalLineFieldName, JoinDatabaseNumber, JoinDatabaseFieldName, false); */

        if not PreviewModeSelected() then
            UpdateDocNo(GenJournalLineRecRef)
        else
            ClearDocNoPreview(GenJournalLineRecRef);

        // Run reports
        /*   CustomLayoutReporting.SetOutputFileBaseName('Remittance Advice'); BAN01
          CustomLayoutReporting.ProcessReport; */
        //  SaveReportEft(GenJournalLineRecRef, GenJournalLine);
        //SaveDocumentAsPDFToStream(GenJournalLine);
        commit();
        Report.Runmodal(11383, true, false, GenJournalLine);

        // Export to file if we don't have anything in preview mode
        if not PreviewModeSelected() then
            SetExportReportOptionsAndExport(GenJournalLineRecRef);
    end;

    local procedure SaveReportEft(Var ReportDataRecordRef: RecordRef; GenJnlLine: Record "Gen. Journal Line")
    var
        // TempBlob: Record TempBlob temporary;
        myrepo: Report "ExportElecPayments - Word";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        instr: InStream;
        Base64EncodedString: Text;
        MyPath: Text;
        TempReqParams: Text;
        RequestPageParamsView: Text;
        FilterGroup: Integer;
        ReportProcFirstErrorText: Text;
    begin
        TempReqParams := REPORT.RUNREQUESTPAGE(11383, GetReportRequestPageParameters(11383));
        StoreRequestParameters(TempReqParams);
        SaveReportRequestPageParameters(11383, TempReqParams);

        TempBlob.CreateOutStream(OutStr);

        FilterGroup := ReportDataRecordRef.FILTERGROUP;
        ReportDataRecordRef.FILTERGROUP(FindNextEmptyFilterGroup(ReportDataRecordRef));
        RequestPageParamsView := GetViewFromParameters(11383, ReportDataRecordRef.NUMBER);
        ReportDataRecordRef.SETVIEW(RequestPageParamsView);
        ReportDataRecordRef.FILTERGROUP(FilterGroup);


        Report.SaveAs(Report::"ExportElecPayments - Word", GetRequestParametersText(11383), ReportFormat::Pdf, OutStr, ReportDataRecordRef);
        TempBlob.CREATEINSTREAM(instr);
        MyPath := 'My.pdf';
        DOWNLOADFROMSTREAM(instr, '', '', '', MyPath);

    end;

    procedure FindNextEmptyFilterGroup(VAR RecordRef: RecordRef): Integer
    var
        FilterGroup: Integer;
        StartingGroup: Integer;
    begin
        StartingGroup := RecordRef.FILTERGROUP;
        FilterGroup := StartingGroup;

        IF FilterGroup < 10 THEN
            FilterGroup := 10;

        // Find the next empty group
        RecordRef.FILTERGROUP(FilterGroup);
        IF RecordRef.HASFILTER THEN
            REPEAT
                FilterGroup += 1;
                RecordRef.FILTERGROUP(FilterGroup);
            UNTIL NOT RecordRef.HASFILTER;

        // Reset the group back to the original value
        RecordRef.FILTERGROUP(StartingGroup);

        EXIT(FilterGroup);
    end;
    // Finds the next empty filter group, with a minimum of group 10 to ensure we're in a non-system group.


    procedure StoreRequestParameters(Parameters: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        Index: Integer;
    begin
        // EVALUATE(11383, RequestPageParametersHelper.GetReportID();
        // Insert or Modify - based on if it exists already or not
        /* IF TempBlobReqParamStore.GET(11383) THEN BEGIN
            TempBlobReqParamStore.Blob.CREATEOUTSTREAM(OutStr);
            OutStr.WRITETEXT(Parameters);
            TempBlobReqParamStore.MODIFY;
        END ELSE BEGIN
            TempBlobReqParamStore.INIT;
            TempBlobReqParamStore.Blob.CREATEOUTSTREAM(OutStr);
            OutStr.WRITETEXT(Parameters);
            TempBlobReqParamStore."Primary Key" := 11383;
            TempBlobReqParamStore.INSERT;
        END;
        COMMIT; */

        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(Parameters);
        if TempBlobIndicesNameValueBuffer.Get(11383) then begin
            Evaluate(Index, TempBlobIndicesNameValueBuffer.Value);
            TempBlobList.Set(Index, TempBlob);
        end else begin
            TempBlobList.Add(TempBlob);
            TempBlobIndicesNameValueBuffer.ID := 11383;
            TempBlobIndicesNameValueBuffer.Value := Format(TempBlobList.Count());
            TempBlobIndicesNameValueBuffer.Insert();
        end;
        COMMIT();
    end;

    procedure SaveReportRequestPageParameters(ReportID: Integer; XMLText: Text)
    var
        ObjectOptions: Record "Object Options";
        Outstr: OutStream;
    begin


        IF XMLText = '' THEN
            EXIT;

        IF ObjectOptions.GET(LastUsedTxlbl, ReportID, ObjectOptions."Object Type"::Report, USERID, COMPANYNAME) THEN
            ObjectOptions.DELETE();
        ObjectOptions.INIT();
        ObjectOptions."Parameter Name" := LastUsedTxlbl;
        ObjectOptions."Object Type" := ObjectOptions."Object Type"::Report;
        ObjectOptions."Object ID" := ReportID;
        ObjectOptions."User Name" := USERID;
        ObjectOptions."Company Name" := COMPANYNAME;
        ObjectOptions."Created By" := USERID;
        ObjectOptions."Option Data".CREATEOUTSTREAM(OutStr);
        OutStr.WRITETEXT(XMLText);
        ObjectOptions.INSERT();
    end;





    procedure GetRequestParametersText(ReportID: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ReqPageXML: Text;
        Index: Integer;
    begin
        /* TempBlobReqParamStore.GET(ReportID);
        TempBlobReqParamStore.CALCFIELDS(Blob);
        TempBlobReqParamStore.Blob.CREATEINSTREAM(InStr);
        InStr.READTEXT(ReqPageXML);
        EXIT(ReqPageXML); */

        TempBlobIndicesNameValueBuffer.Get(ReportID);
        Evaluate(Index, TempBlobIndicesNameValueBuffer.Value);
        TempBlobList.Get(Index, TempBlob);
        TempBlob.CreateInStream(InStr);
        InStr.ReadText(ReqPageXML);
        exit(ReqPageXML);
    end;

    procedure GetReportRequestPageParameters(ReportID: Integer) XMLTxt: Text
    VAR
        ObjectOptions: Record "Object Options";
        InStr: InStream;
    BEGIN
        IF NOT ObjectOptions.GET(LastUsedTxLbl, ReportID, ObjectOptions."Object Type"::Report, USERID, COMPANYNAME) THEN
            EXIT('');
        ObjectOptions.CALCFIELDS("Option Data");
        ObjectOptions."Option Data".CREATEINSTREAM(InStr);
        InStr.READTEXT(XMLTxt);
        EXIT(XMLTxt);
    END;

    procedure GetViewFromParameters(ReportID: Integer; TableNumber: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        Index: Integer;
    begin
        /* TempBlobReqParamStore.GET(ReportID);
        TempBlobReqParamStore.SETRECFILTER;
        TempBlobReqParamStore.CALCFIELDS(Blob);
        // Use the request page helper to parse the parameters and set the view to the RecordRef and the Record
        RecordRef.OPEN(TableNumber);
        //  RequestPageParametersHelper.ConvertParametersToFilters(RecordRef, TempBlobReqParamStore);

        EXIT(RecordRef.GETVIEW); */

        TempBlobIndicesNameValueBuffer.Get(ReportID);
        Evaluate(Index, TempBlobIndicesNameValueBuffer.Value);
        TempBlobList.Get(Index, TempBlob);
        // Use the request page helper to parse the parameters and set the view to the RecordRef and the Record
        RecordRef.Open(TableNumber);
        RequestPageParametersHelper.ConvertParametersToFilters(RecordRef, TempBlob);

        exit(RecordRef.GetView());
    end;




    local procedure PreviewModeSelected(): Boolean
    var
        ReportSelections: Record "Report Selections";
        ReportOutputType: Integer;
        PreviewMode: Boolean;
        FirstLoop: Boolean;
    begin
        // Check to see if any of the associated reports are in 'preview' mode:
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"V.Remittance");

        FirstLoop := true;
        if ReportSelections.Find('-') then
            repeat
                //  ReportOutputType := CustomLayoutReporting.GetOutputOption(ReportSelections."Report ID");
                // We don't need to test for mixed preview and non-preview in the first loop

                if FirstLoop then begin
                    FirstLoop := false;
                    PreviewMode := (ReportOutputType = CustomLayoutReporting.GetPreviewOption())
                end else
                    // If we have mixed preview and non-preview, then display a message that we're not going to export to file
                    if (PreviewMode and (ReportOutputType <> CustomLayoutReporting.GetPreviewOption())) or
                       (not PreviewMode and (ReportOutputType = CustomLayoutReporting.GetPreviewOption()))
                    then begin
                        Message(PreviewModeNoExportMsg);
                        PreviewMode := true;
                    end;
            until ReportSelections.Next() = 0;
        PreviewMode := false;
        exit(PreviewMode);
    end;

    local procedure SetExportReportOptionsAndExport(var GenJournalLineRecRef: RecordRef)
    var
        ReportSelections: Record "Report Selections";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountNo: Code[20];
        GenJournalLineBankAccount: Code[20];
        OptionText: Text;
        OptionCode: Code[20];
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"V.Remittance");
        if ReportSelections.Find('-') then
            repeat
                // Ensure that the report has valid request parameters before trying to access them and run the export
                //  if CustomLayoutReporting.HasRequestParameterData(ReportSelections."Report ID") then begin
                // Get the same options from the user-selected options for this export report run
                // Items in the request page XML use the 'Source' as their name
                OptionText := format(GenJournalLineRecRef.Field(GenJournalLine.FieldNo("Bal. Account No.")));
                //  OptionText :=
                //  CustomLayoutReporting.GetOptionValueFromRequestPageForReport(ReportSelections."Report ID", 'BankAccount."No."');
                OptionCode := CopyStr(OptionText, 1, 20);
                Evaluate(BankAccountNo, OptionCode);
                if GenJournalLineRecRef.FindFirst() then
                    repeat
                        GenJournalLineRecRef.SetTable(GenJournalLine);
                        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                            GenJournalLineBankAccount := GenJournalLine."Account No."
                        else
                            GenJournalLineBankAccount := GenJournalLine."Bal. Account No.";

                        if ProcessLine(GenJournalLine) and (BankAccountNo = GenJournalLineBankAccount) then begin
                            UpdateCheckInfoForGenLedgLine(GenJournalLine);

                            CreateEFTRecord(GenJournalLine, BankAccountNo);

                            CreateCreditTransferRegister(BankAccountNo, GenJournalLine."Bal. Account No.", BankPaymentType);
                        end;
                    until GenJournalLineRecRef.Next() = 0;

            // end;
            until ReportSelections.Next() = 0;
    end;

    local procedure CheckReportSelectionsExists()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"V.Remittance");
        ReportSelections.SetFilter("Report ID", '<>0');
        if not ReportSelections.FindFirst() then
            Error(VendRemittanceReportSelectionErr);
    end;

    local procedure CreateEFTRecord(GenJournalLine: Record "Gen. Journal Line"; BankAccountNo: Code[20])
    var
        EFTExport: Record "EFT Export";
    begin
        EFTExport.Init();
        EFTExport."Journal Template Name" := GenJournalLine."Journal Template Name";
        EFTExport."Journal Batch Name" := GenJournalLine."Journal Batch Name";
        EFTExport."Line No." := GenJournalLine."Line No.";
        EFTExport."Sequence No." := GetNextSequenceNo();

        EFTExport."Bank Account No." := BankAccountNo;
        EFTExport."Bank Payment Type" := GenJournalLine."Bank Payment Type";
        EFTExport."Transaction Code" := GenJournalLine."Transaction Code";
        EFTExport."Document Type" := GenJournalLine."Document Type";
        EFTExport."Posting Date" := GenJournalLine."Posting Date";
        EFTExport."Account Type" := GenJournalLine."Account Type";
        EFTExport."Account No." := GenJournalLine."Account No.";
        EFTExport."Applies-to ID" := GenJournalLine."Applies-to ID";
        EFTExport."Document No." := GenJournalLine."Document No.";
        EFTExport.Description := GenJournalLine.Description;
        EFTExport."Currency Code" := GenJournalLine."Currency Code";
        EFTExport."Bal. Account No." := GenJournalLine."Bal. Account No.";
        EFTExport."Bal. Account Type" := GenJournalLine."Bal. Account Type";
        EFTExport."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type";
        EFTExport."Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No.";
        EFTExport."Check Exported" := GenJournalLine."Check Exported";
        EFTExport."Check Printed" := GenJournalLine."Check Printed";
        EFTExport."Exported to Payment File" := GenJournalLine."Exported to Payment File";
        EFTExport."Amount (LCY)" := GenJournalLine."Amount (LCY)";
        EFTExport."Foreign Exchange Reference" := GenJournalLine."Foreign Exchange Reference";
        EFTExport."Foreign Exchange Indicator" := GenJournalLine."Foreign Exchange Indicator";
        EFTExport."Foreign Exchange Ref.Indicator" := GenJournalLine."Foreign Exchange Ref.Indicator";
        EFTExport."Country/Region Code" := GenJournalLine."Country/Region Code";
        EFTExport."Source Code" := GenJournalLine."Source Code";
        EFTExport."Company Entry Description" := GenJournalLine."Company Entry Description";
        EFTExport."Transaction Type Code" := GenJournalLine."Transaction Type Code";
        EFTExport."Payment Related Information 1" := GenJournalLine."Payment Related Information 1";
        EFTExport."Payment Related Information 2" := GenJournalLine."Payment Related Information 2";
        EFTExport."Gateway Operator OFAC Scr.Inc" := GenJournalLine."Gateway Operator OFAC Scr.Inc";
        EFTExport."Secondary OFAC Scr.Indicator" := GenJournalLine."Secondary OFAC Scr.Indicator";
        EFTExport."Origin. DFI ID Qualifier" := GenJournalLine."Origin. DFI ID Qualifier";
        EFTExport."Receiv. DFI ID Qualifier" := GenJournalLine."Receiv. DFI ID Qualifier";
        EFTExport."Document Date" := GenJournalLine."Document Date";
        EFTExport."Document No." := GenJournalLine."Document No.";

        EFTExport.Insert();
    end;

    local procedure UpdateCheckInfoForGenLedgLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Check Printed" := true;
        GenJournalLine."Check Exported" := true;
        GenJournalLine."Exported to Payment File" := true;

        GenJournalLine.Modify();
    end;

    local procedure UpdateDocNo(var GenJournalLineRecRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        ReportSelections: Record "Report Selections";
        BankAccountNo: Code[20];
        GenJournalLineBankAccount: Code[20];
        OptionText: Text;
        OptionCode: Code[20];
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"V.Remittance");
        if ReportSelections.Find('-') then
            repeat
                if CustomLayoutReporting.HasRequestParameterData(ReportSelections."Report ID") then begin
                    // Get the same options from the user-selected options for this export report run
                    // Items in the request page XML use the 'Source' as their name
                    OptionText := format(GenJournalLineRecRef.Field(GenJournalLine.FieldNo("Bal. Account No.")));
                    //   OptionText :=
                    // CustomLayoutReporting.GetOptionValueFromRequestPageForReport(ReportSelections."Report ID", 'BankAccount."No."');
                    OptionCode := CopyStr(OptionText, 1, 20);
                    Evaluate(BankAccountNo, OptionCode);

                    if GenJournalLineRecRef.FindFirst() then
                        repeat
                            GenJournalLineRecRef.SetTable(GenJournalLine);
                            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                                GenJournalLineBankAccount := GenJournalLine."Account No."
                            else
                                GenJournalLineBankAccount := GenJournalLine."Bal. Account No.";

                            if ProcessLine(GenJournalLine) and (BankAccountNo = GenJournalLineBankAccount) then
                                UpdateDocNoForGenLedgLine(GenJournalLine, BankAccountNo);
                        until GenJournalLineRecRef.Next() = 0;

                end;
            until ReportSelections.Next() = 0;

    end;

    local procedure UpdateDocNoForGenLedgLine(var GenJournalLine: Record "Gen. Journal Line"; BankAccountNo: Code[20])
    begin
        BankAccount.Get(BankAccountNo);
        BankAccount."Last Remittance Advice No." := IncStr(BankAccount."Last Remittance Advice No.");
        BankAccount.Modify();

        GenJournalLine."Document No." := BankAccount."Last Remittance Advice No.";

        GenJournalLine.Modify();

        InsertIntoCheckLedger(GenJournalLine, BankAccountNo);
    end;

    local procedure InsertIntoCheckLedger(GenJournalLine: Record "Gen. Journal Line"; BankAccountNo: Code[20])
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        BankAccount: Record "Bank Account";
        CheckManagement: Codeunit CheckManagement;
        BankAccountIs: Option Acnt,BalAcnt;
    begin
        BankAccount.Get(BankAccountNo);

        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            BankAccountIs := BankAccountIs::Acnt
        else
            BankAccountIs := BankAccountIs::BalAcnt;

        CheckLedgerEntry.Init();
        CheckLedgerEntry."Bank Account No." := BankAccount."No.";
        CheckLedgerEntry."Posting Date" := GenJournalLine."Document Date";
        CheckLedgerEntry."Document Type" := GenJournalLine."Document Type";
        CheckLedgerEntry."Document No." := GenJournalLine."Document No.";
        CheckLedgerEntry.Description := GenJournalLine.Description;
        CheckLedgerEntry."Bank Payment Type" := CheckLedgerEntry."Bank Payment Type"::"Electronic Payment";
        CheckLedgerEntry."Entry Status" := CheckLedgerEntry."Entry Status"::Exported;
        CheckLedgerEntry."Check Date" := GenJournalLine."Document Date";
        CheckLedgerEntry."Check No." := GenJournalLine."Document No.";

        if BankAccountIs = BankAccountIs::Acnt then begin
            CheckLedgerEntry."Bal. Account Type" := GenJournalLine."Bal. Account Type";
            CheckLedgerEntry."Bal. Account No." := GenJournalLine."Bal. Account No.";
            CheckLedgerEntry.Amount := -GenJournalLine."Amount (LCY)";
        end else begin
            CheckLedgerEntry."Bal. Account Type" := GenJournalLine."Account Type";
            CheckLedgerEntry."Bal. Account No." := GenJournalLine."Account No.";
            CheckLedgerEntry.Amount := GenJournalLine."Amount (LCY)";
        end;
        CheckManagement.InsertCheck(CheckLedgerEntry, GenJournalLine.RecordId);
    end;

    local procedure CreateCreditTransferRegister(BankAccountNo: Code[20]; BalAccountNo: Code[20]; BankPaymentType: Integer)
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        CreditTransferRegister: Record "Credit Transfer Register";
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        NewIdentifier: Code[20];
        PaymentExportDirection: Integer;
    begin
        BankAccount.Get(BankAccountNo);

        if BankPaymentType = 3 then // Electronic Payment
            BankExportImportSetup.Get(BankAccount."Receivables Export Format")
        else
            if BankPaymentType = 4 then // Electronic Payment IAT
                BankExportImportSetup.Get(BankAccount."EFT Export Code Format");

        PaymentExportDirection := BankExportImportSetup.Direction;
        if PaymentExportDirection <> 3 then // Export-EFT
            if BankAccount."Payment Export Format" <> '' then begin
                DataExchDef.Get(BankAccount."Receivables Export Format");
                NewIdentifier := DataExchDef.Code;
            end else
                NewIdentifier := '';

        CreditTransferRegister.CreateNew(NewIdentifier, BalAccountNo);
        Commit();
    end;

    local procedure GetNextSequenceNo(): Integer
    var
        EFTExport: Record "EFT Export";
    begin
        EFTExport.SetCurrentKey("Sequence No.");
        EFTExport.SetRange("Sequence No.");
        if EFTExport.FindLast() then
            exit(EFTExport."Sequence No." + 1);

        exit(1);
    end;


    procedure ProcessLine(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        ExportNewLines: Boolean;
    begin
        ExportNewLines := false;
        if GenJournalLine."Amount (LCY)" <> 0 then
            if ((GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment") or
                (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment-IAT")) and
               (GenJournalLine."Check Exported" = false)
            then
                ExportNewLines := true;

        exit(ExportNewLines);
    end;

    local procedure ClearDocNoPreview(var GenJournalLineRecRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalLineRecRef.FindFirst() then
            repeat
                GenJournalLineRecRef.SetTable(GenJournalLine);

                if ProcessLine(GenJournalLine) then begin
                    GenJournalLine."Document No." := '';
                    GenJournalLine.Modify();
                end;
            until GenJournalLineRecRef.Next() = 0;

    end;
}
