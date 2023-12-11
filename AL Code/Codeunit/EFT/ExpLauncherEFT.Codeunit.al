codeunit 60011 "MFCC01Exp. Launcher EFT"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "EFT Export Workset";

    trigger OnRun()
    begin
        // EFTPaymentProcess(Rec);
    end;

    var
        ExportEFTACH: Codeunit "MFCC01Export EFT (ACH)";
        ExportEFTIAT: Codeunit "MFCC01Export EFT (IAT)";
        tempBlob: Codeunit "Temp Blob";
        InvalidExportFormatErr: Label '%1 is not a valid %2 in %3 %4.', Comment = '%1=Bank account export format,%2=Bank account export format field caption,%3=Bank account table caption,%4=Bank account number';

        IsTestMode: Boolean;

        IStream: InStream;
        Ostream: OutStream;

        outputFileName: Text;


    procedure EFTPaymentProcess(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var TempNameValueBuffer: Record "Name/Value Buffer" temporary; var DataCompression: Codeunit "Data Compression"; var ZipFileName: Text; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        ExpWritingEFT: Codeunit "MFCC01Exp. Writing EFT";
        DataExchEntryCodeDetail: Integer;
        DataExchEntryCodeFooter: Integer;
        DataExchDefCode: Code[20];
        Filename: Text;
        HeaderArray: array[100] of Integer;
        DetailArray: array[100] of Integer;
        FooterArray: array[100] of Integer;
        Filepath: Text;
        ACHFileName: Text;
    begin
        TempEFTExportWorkset.FindFirst();

        BankAccount.Get(TempEFTExportWorkset."Bank Account No.");

        case BankAccount."Export Format" of
            BankAccount."Export Format"::US:
                ExpWritingEFT.PreCleanUpUSWorkTables();

        end;

        if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT" then
            BankExportImportSetup.SetRange(Code, BankAccount."EFT Export Code Format")
        else
            BankExportImportSetup.SetRange(Code, BankAccount."Receivables Export Format");

        if BankExportImportSetup.FindFirst() then begin
            DataExchDefCode := BankExportImportSetup."Data Exch. Def. Code";
            ACHFileName := BankAccount."E-Recevbl Exp. File Name";
            UpdateLastEPayExportFileName(BankAccount);
            Filepath := TempEFTExportWorkset.Pathname;


            TempBlob.CreateOutStream(Ostream);

            ProcessHeaders(TempEFTExportWorkset, BankAccount, DataExchDefCode, HeaderArray, Filename, EFTValues);

            InsertDataExchForDetails(DataExchDefCode);
            repeat
                ProcessDetails(TempEFTExportWorkset, BankAccount, DataExchDefCode, DataExchEntryCodeDetail, DetailArray, Filename, EFTValues);
            until TempEFTExportWorkset.Next() = 0;
            TempEFTExportWorkset.FindFirst();
            ProcessFooters(TempEFTExportWorkset, BankAccount, DataExchDefCode, FooterArray, Filename, DataExchEntryCodeFooter, EFTValues);

            TempBlob.CreateInStream(IStream);
            outputFileName := BankAccount."E-Recevbl Exp. File Name";
            DownloadFromStream(IStream, '', '', '', outputFileName);

            if not IsTestMode then
                ExpWritingEFT.ExportEFT(DataExchEntryCodeDetail, DataExchEntryCodeFooter, Filepath, Filename, ACHFileName,
                  FooterArray, TempNameValueBuffer, ZipFileName, DataCompression);

            // This should only be called from a test codeunit, calling CreateExportFile MUST pass in a FALSE parameter
            DataExchDef.Get(DataExchDefCode);
            if DataExchDef."Ext. Data Handling Codeunit" > 0 then
                DataExch.Get(DataExchEntryCodeDetail);

            if DataExchDef."User Feedback Codeunit" > 0 then begin
                DataExch.Get(DataExchEntryCodeDetail);
                CODEUNIT.Run(DataExchDef."User Feedback Codeunit", DataExch);
            end;

        end;

        // Clean up the work tables.
        ExpWritingEFT.CleanUpEFTWorkTables(HeaderArray, DetailArray, FooterArray);
    end;

    local procedure ProcessHeaders(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var BankAccount: Record "Bank Account"; DataExchDefCode: Code[20]; var HeaderArray: array[100] of Integer; Filename: Text; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        EFTExportMgt: Codeunit "MFCC01EFT Export Mgt";
        HdrCount: Integer;
    begin
        HdrCount := 0;
        DataExchLineDef.Init();
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Header);
        if DataExchLineDef.FindSet() then
            repeat
                // Insert the Data Exchange Header records
                DataExch."Entry No." := 0;
                DataExch."Data Exch. Def Code" := DataExchDefCode;
                DataExch."Data Exch. Line Def Code" := DataExchLineDef.Code;
                DataExch.Insert();
                Commit();

                HdrCount := HdrCount + 1;
                HeaderArray[HdrCount] := DataExch."Entry No.";

                // It is only here where we know the True DataExch."Entry No"..
                DataExchMapping.SetRange("Data Exch. Def Code", DataExchDefCode);
                DataExchMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                DataExchMapping.FindFirst();

                // Populate the Header work tables
                EFTExportMgt.PrepareEFTHeader(DataExch, BankAccount."Bank Account No.", BankAccount."No.");

                if DataExchMapping."Pre-Mapping Codeunit" > 0 then
                    CODEUNIT.Run(DataExchMapping."Pre-Mapping Codeunit", DataExch);

                case BankAccount."Export Format" of
                    BankAccount."Export Format"::US:
                        if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment"
                        then begin
                            EFTValues.SetNoOfRec(EFTValues.GetNoOfRec() + 1);
                            if HdrCount = 1 then
                                ExportEFTACH.StartExportFile(BankAccount."No.", '', DataExch."Entry No.")
                            else
                                ExportEFTACH.StartExportBatch(TempEFTExportWorkset."Source Code",
                                  TempEFTExportWorkset.UserSettleDate, DataExch."Entry No.");
                            EFTValues.SetEFTFileCreated(true);
                        end else
                            if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT"
                            then begin
                                if HdrCount = 1 then
                                    ExportEFTIAT.StartExportFile(BankAccount."No.", '', DataExch."Entry No.", EFTValues)
                                else
                                    ExportEFTIAT.StartExportBatch(TempEFTExportWorkset, TempEFTExportWorkset.UserSettleDate,
                                      DataExch."Entry No.", EFTValues);
                                EFTValues.SetIATFileCreated(true);
                            end;
                    // BankAccount."Export Format"::CA:
                    //     begin
                    //         ExportEFTRB.StartExportFile(TempEFTExportWorkset, BankAccount."No.", DataExch."Entry No.", EFTValues);
                    //         EFTValues.SetEFTFileCreated(true);
                    //     end;
                    // BankAccount."Export Format"::MX:
                    //     begin
                    //         if HdrCount = 1 then
                    //             ExportEFTCecoban.StartExportFile(BankAccount."No.")
                    //         else
                    //             ExportEFTCecoban.StartExportBatch(TempEFTExportWorkset.UserSettleDate, DataExch."Entry No.");
                    //         EFTValues.SetIATFileCreated(false);
                    //         EFTValues.SetEFTFileCreated(true);
                    //     end;
                    else
                        Error(InvalidExportFormatErr,
                          BankAccount."Export Format",
                          BankAccount.FieldCaption("Export Format"),
                          BankAccount.TableCaption(),
                          BankAccount."No.");
                end;

                // Create the Entries and values in the Data Exch. Field table
                if DataExchMapping."Mapping Codeunit" > 0 then
                    CODEUNIT.Run(DataExchMapping."Mapping Codeunit", DataExch);

                DataExchDef.Get(DataExchDefCode);
                if DataExchDef."Reading/Writing Codeunit" = CODEUNIT::"Exp. Writing EFT" then
                    ExportDataExchToFlatFile(DataExch."Entry No.", Filename, DataExchLineDef."Line Type", HdrCount);
            until DataExchLineDef.Next() = 0;


    end;

    procedure ExportDataExchToFlatFile(DataExchNo: Integer; Filename: Text; LineFileType: Integer; HeaderCount: Integer)
    var

        DataExchField: Record "Data Exch. Field";
        DataExch: Record "Data Exch.";

        ExportGenericFixedWidth: XMLport "Export Generic Fixed Width";

        RecordRef: RecordRef;
        CRLF: Text;
        Filename2: Text[250];
        LineType: Option Detail,Header,Footer;

    begin
        DataExchField.SetRange("Data Exch. No.", DataExchNo);
        if DataExchField.Count() > 0 then begin

            if ((LineFileType <> LineType::Header) or ((LineFileType = LineType::Header) and (HeaderCount > 1)))
            then begin
                // Only the first line needs to not write a CRLF.
                CRLF[1] := 13;
                CRLF[2] := 10;
                OStream.Write(CRLF[1]);
                OStream.Write(CRLF[2]);
            end;

            if LineFileType = LineType::Footer then begin
                Filename2 := CopyStr(Filename, 1, 250);

                DataExch.Get(DataExchNo);
                DataExch."File Name" := Filename2;

                RecordRef.GetTable(DataExch);
                TempBlob.ToRecordRef(RecordRef, DataExch.FieldNo("File Content"));
                RecordRef.SetTable(DataExch);

                DataExch.Modify();
            end;

            // Now copy current file contents to table, also.
            ExportGenericFixedWidth.SetDestination(OStream);
            ExportGenericFixedWidth.SetTableView(DataExchField);
            ExportGenericFixedWidth.Export();
            //ExportFile.Close;

            DataExchField.DeleteAll(true);
        end;
    end;

    local procedure ProcessDetails(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var BankAccount: Record "Bank Account"; DataExchDefCode: Code[20]; var DataExchEntryCodeDetail: Integer; var DetailArray: array[100] of Integer; Filename: Text; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        //  EFTExportMgt: Codeunit "MFCC01EFT Export Mgt";
        ExpPreMappingDetEFTUS: Codeunit "MFCC01Exp. Pre-Map Det EFT US";
    //  ExpPreMappingDetEFTCA: Codeunit "Exp. Pre-Mapping Det EFT CA";
    //  ExpPreMappingDetEFTMX: Codeunit "Exp. Pre-Mapping Det EFT MX";
    begin
        DataExchLineDef.Init();
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Detail);
        if DataExchLineDef.FindSet() then
            repeat
                // Insert the Data Exchange Detail records
                DataExch.SetRange("Data Exch. Def Code", DataExchDefCode);
                DataExch.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                DataExch.FindFirst();

                // It is only here where we know the True DataExch."Entry No"..
                DataExchMapping.SetRange("Data Exch. Def Code", DataExchDefCode);
                DataExchMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                DataExchMapping.FindFirst();

                if (EFTValues.GetParentDefCode() = '') or (EFTValues.GetParentDefCode() = DataExchLineDef.Code) then begin
                    EFTValues.SetParentDefCode(DataExchLineDef.Code);
                    EFTValues.SetParentBoolean := true;
                end else
                    EFTValues.SetParentBoolean := false;

                if DataExchEntryCodeDetail = 0 then
                    DataExchEntryCodeDetail := DataExch."Entry No.";

                // Fill the detail work tables
                case BankAccount."Export Format" of
                    BankAccount."Export Format"::US:
                        ExpPreMappingDetEFTUS.PrepareEFTDetails(TempEFTExportWorkset, DataExch."Entry No.", 0, DetailArray,
                          ExportEFTACH, ExportEFTIAT, DataExchLineDef.Code, EFTValues);
                // BankAccount."Export Format"::CA:
                //     ExpPreMappingDetEFTCA.PrepareEFTDetails(TempEFTExportWorkset, DataExch."Entry No.", 0, DetailArray,
                //       ExportEFTRB, DataExchLineDef.Code, EFTValues);
                // BankAccount."Export Format"::MX:
                //     ExpPreMappingDetEFTMX.PrepareEFTDetails(TempEFTExportWorkset, DataExch."Entry No.", 0, DetailArray,
                //       ExportEFTCecoban, DataExchLineDef.Code);
                end;

                // Create the Entries and values in the Data Exch. Field table
                if DataExchMapping."Mapping Codeunit" > 0 then
                    CODEUNIT.Run(DataExchMapping."Mapping Codeunit", DataExch);

                DataExchDef.Get(DataExchDefCode);
                if DataExchDef."Reading/Writing Codeunit" > 0 then
                    if DataExchDef."Reading/Writing Codeunit" = CODEUNIT::"Exp. Writing EFT" then
                        ExportDataExchToFlatFile(DataExch."Entry No.", Filename, DataExchLineDef."Line Type", 0)
                    else
                        CODEUNIT.Run(DataExchDef."Reading/Writing Codeunit", DataExch);

            until DataExchLineDef.Next() = 0;

    end;

    local procedure ProcessFooters(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; var BankAccount: Record "Bank Account"; DataExchDefCode: Code[20]; var FooterArray: array[100] of Integer; Filename: Text; var DataExchEntryCodeFooter: Integer; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        EFTExportMgt: Codeunit "MFCC01EFT Export Mgt";
        FooterCount: Integer;
    begin
        FooterCount := 0;
        DataExchLineDef.Init();
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Footer);
        if DataExchLineDef.FindSet() then
            repeat
                // Insert the Data Exchange Footer records
                DataExch."Entry No." := 0;
                DataExch."Data Exch. Def Code" := DataExchDefCode;
                DataExch."Data Exch. Line Def Code" := DataExchLineDef.Code;
                DataExch.Insert();
                Commit();

                FooterCount := FooterCount + 1;
                FooterArray[FooterCount] := DataExch."Entry No.";

                // It is only here where we know the True DataExch."Entry No"..
                DataExchMapping.SetRange("Data Exch. Def Code", DataExchDefCode);
                DataExchMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                DataExchMapping.FindFirst();

                // Create the Entries and values in the Data Exch. Field table
                if DataExchMapping."Pre-Mapping Codeunit" > 0 then
                    CODEUNIT.Run(DataExchMapping."Pre-Mapping Codeunit", DataExch);

                // Populate the Footer work table
                EFTExportMgt.PrepareEFTFooter(DataExch, BankAccount."No.");

                case BankAccount."Export Format" of
                    BankAccount."Export Format"::US:
                        if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment"
                        then begin
                            EFTValues.SetNoOfRec(EFTValues.GetNoOfRec() + 1);
                            if FooterCount = 1 then
                                ExportEFTACH.EndExportBatch(DataExch."Entry No.")
                            else
                                ExportEFTACH.EndExportFile(DataExch."Entry No.", EFTValues);
                        end else
                            if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT"
                            then
                                if FooterCount = 1 then
                                    ExportEFTIAT.EndExportBatch(DataExch."Entry No.", EFTValues)
                                else
                                    ExportEFTIAT.EndExportFile(DataExch."Entry No.", EFTValues);

                    // BankAccount."Export Format"::CA:
                    //     ExportEFTRB.EndExportFile(DataExch."Entry No.", EFTValues);
                    // BankAccount."Export Format"::MX:
                    //     ExportEFTCecoban.EndExportBatch(DataExch."Entry No.");
                    else
                        Error(InvalidExportFormatErr,
                          BankAccount."Export Format",
                          BankAccount.FieldCaption("Export Format"),
                          BankAccount.TableCaption(),
                          BankAccount."No.");
                end;

                if DataExchMapping."Mapping Codeunit" > 0 then
                    CODEUNIT.Run(DataExchMapping."Mapping Codeunit", DataExch);

                DataExchDef.Get(DataExchDefCode);
                if DataExchDef."Reading/Writing Codeunit" = CODEUNIT::"Exp. Writing EFT" then
                    ExportDataExchToFlatFile(DataExch."Entry No.", Filename, DataExchLineDef."Line Type", 0);
                DataExchEntryCodeFooter := DataExch."Entry No.";
            until DataExchLineDef.Next() = 0;
        //if BankAccount."Export Format" = BankAccount."Export Format"::US then
        //  AddPadBlocks(Filename, EFTValues);

    end;

    procedure AddPadBlocks(Filename: Text; var EFTValues: Codeunit "MFCC01EFT Values")
    var

        NoOfRec: Integer;
    begin

        NoOfRec := EFTValues.GetNoOfRec();

        while NoOfRec mod 10 <> 0 do begin // BlockingFactor
            Ostream.WriteText(PadStr('', 94, '9'));
            Ostream.WriteText(); // Carriage Return and Line Feed
            NoOfRec := NoOfRec + 1;
            EFTValues.SetNoOfRec(NoOfRec);
        end;


    end;

    local procedure UpdateLastEPayExportFileName(BankAccount: Record "Bank Account")
    begin
        BankAccount."E-Recevbl Exp. File Name" := IncStr(BankAccount."E-Recevbl Exp. File Name");
        BankAccount.Modify();
        Commit();
    end;

    [Scope('OnPrem')]
    procedure SetTestMode()
    begin
        IsTestMode := true;
    end;

    local procedure InsertDataExchForDetails(DataExchDefCode: Code[20])
    var
        DataExch: Record "Data Exch.";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        DataExchLineDef.Init();
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Detail);
        if DataExchLineDef.FindSet() then
            repeat
                // Insert the Data Exchange Detail records
                DataExch."Entry No." := 0;
                DataExch."Data Exch. Def Code" := DataExchDefCode;
                DataExch."Data Exch. Line Def Code" := DataExchLineDef.Code;
                DataExch.Insert();
            until DataExchLineDef.Next() = 0;
        Commit();
    end;
}

