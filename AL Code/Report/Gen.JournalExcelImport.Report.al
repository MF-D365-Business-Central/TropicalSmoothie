#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 60001 "Gen. Journal Excel Import"
{
    Permissions = TableData "Excel Buffer" = rimd;
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        X: Integer;
        IStream: InStream;
        FromFile: Text[100];
        NoFileFoundMsg: Label 'No Excel file found!';
        UploadExcelMsg: Label 'Please Choose the Excel file.';
    begin
        ExcelBuf.Reset;
        ExcelBuf.DeleteAll;

        UploadIntoStream(UploadExcelMsg, '', '', FromFile, IStream);

        if FromFile <> '' then begin
            FileName := FileMgt.GetFileName(FromFile);
            SheetName := ExcelBuf.SelectSheetsNameStream(IStream);
        end else
            Error(NoFileFoundMsg);

        ExcelBuf.Reset();
        ExcelBuf.DeleteAll();
        ExcelBuf.OpenBookStream(IStream, SheetName);
        ExcelBuf.ReadSheet();

        GenerateJnlLines(TemplateName, BatchNo);
    end;

    var
        ExcelBuf: Record "Excel Buffer" temporary;
        FileName: Text[250];
        SheetName: Text[250];
        Text001: label 'The field with name %1 does not exist';
        Text002: label 'Enum %2 is not matching with %1 out of %3', Comment = '{Locked="Excel"}';
        NewBatchNo: Code[20];
        FileMgt: Codeunit "File Management";
        ExcelFileExtensionTok: label '.xlsx', Locked = true;
        TotalRows: Integer;
        TotalColumn: Integer;
        TemplateName: Code[10];
        BatchNo: Code[10];
        Text004: label 'The Excel worksheet %1 does not exist.', Comment = '{Locked="Excel"}';
        Text007: label 'Reading Excel worksheet...\\', Comment = '{Locked="Excel"}';
        Text035: label 'The operation was canceled.';
        LineNo: Integer;
        SourceCode: Code[20];
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLSetup: Record "General Ledger Setup";
        GenRecRef: RecordRef;
        GenFieldRef: FieldRef;
        FieldsRec: Record "Field";
        DocumentNo: Code[20];

    procedure SetValues(NewTemplateCode: Code[20]; NewBatchNo: Code[20])
    begin
        TemplateName := NewTemplateCode;
        BatchNo := NewBatchNo;
    end;

    procedure GenerateJnlLines(Template: Code[10]; Batch: Code[20])
    var
        Dimension: Record Dimension;
        FindDimension: Record Dimension;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimgMgt: Codeunit DimensionManagement;
        Window: Dialog;
        DateVar: Date;
        DateTimeVar: DateTime;
        DateFormulaVar: DateFormula;
        FieldType: Text[30];
        TotalRecNo: Integer;
        RecNo: Integer;
        j: Integer;
        NoOption: Integer;
        OptionNo: Integer;
        RowNo: Integer;
        IsDim: Boolean;
        MoveToNext: Boolean;
        DocNoHeaderFound: Boolean;
        Headers: array[100] of Text[250];
        Text006: label 'Analyzing Data...\\';
        GenJournalLine: Record "Gen. Journal Line";
        NoFields: Integer;
        CurField: Integer;
        TempDec: Decimal;
        Test: Text;
        Test2: Text;
        lastRow: Integer;
    begin
        // Analyze Data
        GLSetup.Get;
        GenJournalTemplate.Get(Template);
        GenJournalBatch.Get(Template, Batch);
        DocNoHeaderFound := false;

        GetJnlLineNo(Template, Batch);

        Window.Open(Text006 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');

        ExcelBuf.Reset;
        ExcelBuf.SetFilter("Row No.", '1'); // read the Header with the field descriptions
        if ExcelBuf.FindSet then
            repeat
                Headers[ExcelBuf."Column No."] := ExcelBuf."Cell Value as Text";
                if Headers[ExcelBuf."Column No."] = GenJournalLine.FieldName(GenJournalLine."Document No.") then
                    DocNoHeaderFound := true;
            until ExcelBuf.Next = 0;

        NoFields := ExcelBuf.Count;

        ExcelBuf.Reset;
        ExcelBuf.SetCurrentkey("Row No.", "Column No.");
        ExcelBuf.SetFilter("Row No.", '2..'); // Eliminate the Header as the first line
        TotalRecNo := ExcelBuf.Count;

        if ExcelBuf.FindSet then
            repeat
                RecNo += 1;
                If lastRow <> ExcelBuf."Row No." then Begin
                    lastRow := ExcelBuf."Row No.";
                    TempDimSetEntry.Reset();
                    TempDimSetEntry.DeleteAll();
                End;
                Window.Update(1, ROUND(RecNo / TotalRecNo * 10000, 1));

                GenRecRef.Open(Database::"Gen. Journal Line");
                GenRecRef.Init;

                GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Journal Template Name"));
                GenFieldRef.Validate(Template);
                GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Journal Batch Name"));
                GenFieldRef.Validate(Batch);
                GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Line No."));
                GenFieldRef.Validate(LineNo);
                GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Source Code"));
                GenFieldRef.Validate(SourceCode);
                GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Posting Date"));
                GenFieldRef.Validate(WorkDate);
                GenRecRef.Insert(true);

                FieldsRec.Reset;
                FieldsRec.SetRange(TableNo, Database::"Gen. Journal Line");
                for CurField := 1 to NoFields do begin
                    // See what field it goes to
                    IsDim := false;
                    FieldsRec.SetRange(FieldName);
                    FieldsRec.SetRange("Field Caption");
                    FieldsRec.SetRange("Field Caption", Headers[ExcelBuf."Column No."]);
                    if not FieldsRec.FindFirst then begin
                        FieldsRec.SetRange("Field Caption");
                        FieldsRec.SetRange(FieldName, Headers[ExcelBuf."Column No."]);
                    end;
                    if not FieldsRec.FindFirst then begin
                        // Check to see if it's a dimension
                        FindDimension.FindFirst;
                        repeat
                            if (UpperCase(Headers[ExcelBuf."Column No."]) = UpperCase(FindDimension.Code)) or
                              (UpperCase(Headers[ExcelBuf."Column No."]) = UpperCase(FindDimension."Code Caption"))
                            then begin
                                IsDim := true;
                                Dimension := FindDimension;
                            end;
                        until IsDim or (FindDimension.Next = 0);

                        if Not IsDim then
                            Error(Text001, Headers[ExcelBuf."Column No."]);
                    end;

                    if IsDim then begin
                        if (DelChr(ExcelBuf."Cell Value as Text", '<>') <> '') then begin
                            // Don't have to create any field entry, just put it in the Dimension Table
                            TempDimSetEntry.Init();
                            TempDimSetEntry."Dimension Code" := Dimension.Code;
                            TempDimSetEntry.validate("Dimension Value Code", ExcelBuf."Cell Value as Text");
                            TempDimSetEntry.Insert;

                            GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo(GenJournalLine."Dimension Set ID"));
                            GenFieldRef.Validate(DimgMgt.GetDimensionSetID(TempDimSetEntry));
                        end;
                    end else begin
                        GenFieldRef := GenRecRef.Field(FieldsRec."No.");
                        FieldType := Format(GenFieldRef.Type);
                        case FieldType of
                            'Date':
                                begin
                                    if ExcelBuf."Cell Value as Text" = '' then
                                        GenFieldRef.Validate(0D)
                                    else begin
                                        // Excel Date Values Shows up with Time
                                        Evaluate(DateTimeVar, ExcelBuf."Cell Value as Text");
                                        ExcelBuf."Cell Value as Text" := Format(DateTimeVar, 6, '<Month,2><Day,2><year,2>');
                                        Evaluate(DateVar, ExcelBuf."Cell Value as Text");
                                        GenFieldRef.Validate(DateVar);
                                    end;
                                end;
                            'Option':
                                begin
                                    // Find out how many options are in the string
                                    if ExcelBuf."Cell Value as Text" = '' then
                                        ExcelBuf."Cell Value as Text" := ' ';

                                    NoOption := 0;
                                    for j := 1 to StrLen(GenFieldRef.OptionCaption) do
                                        if CopyStr(GenFieldRef.OptionCaption, j, 1) = ',' then
                                            NoOption += 1;

                                    // Find out which option number is the value
                                    OptionNo := -1;
                                    for j := 1 to (NoOption) do begin
                                        Test := SelectStr(j, GenFieldRef.OptionCaption);
                                        Test := Test.Replace(' ', '');
                                        Test2 := ExcelBuf."Cell Value as Text";
                                        Test2 := DelChr(Test2, '=', DelChr(Test2, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/\'));
                                        if Test = Test2 then
                                            OptionNo := j - 1;
                                    end;

                                    // Find out which option number is the value (Caption)
                                    if OptionNo = -1 then
                                        for j := 1 to (NoOption) do
                                            if ExcelBuf."Cell Value as Text" = SelectStr(j, GenFieldRef.OptionCaption) then
                                                OptionNo := j - 1;

                                    // Give error if doesn't find it
                                    if OptionNo = -1 then
                                        Error(
                                          Text002, Headers[ExcelBuf."Column No."], ExcelBuf."Cell Value as Text",
                                          GenFieldRef.OptionMembers);

                                    GenFieldRef.Validate(OptionNo);
                                end;
                            'Integer':
                                begin
                                    if ExcelBuf."Cell Value as Text" <> '0' then begin
                                        Evaluate(GenFieldRef, ExcelBuf."Cell Value as Text");
                                        GenFieldRef.Validate;
                                    end;
                                end;
                            'Decimal':
                                begin
                                    if (ExcelBuf."Cell Value as Text" <> '0') and (ExcelBuf."Cell Value as Text" <> '') then begin
                                        if Evaluate(TempDec, ExcelBuf."Cell Value as Text") then
                                            GenFieldRef.Validate(TempDec);
                                    end;
                                end;
                            'Boolean':
                                begin
                                    if (UpperCase(ExcelBuf."Cell Value as Text") = 'YES') or
                                      (UpperCase(ExcelBuf."Cell Value as Text") = 'TRUE')
                                    then
                                        GenFieldRef.Validate(true)
                                    else
                                        if (UpperCase(ExcelBuf."Cell Value as Text") = 'NO') or
                                     (UpperCase(ExcelBuf."Cell Value as Text") = 'FALSE')
                                   then
                                            GenFieldRef.Validate(false);
                                end;
                            'DateFormula':
                                begin
                                    if Evaluate(DateFormulaVar, ExcelBuf."Cell Value as Text") then
                                        GenFieldRef.Validate(DateFormulaVar);
                                end

                            else begin
                                if (FieldsRec."Field Caption" = GenJournalLine.FieldCaption("Account No.")) or
                                  (FieldsRec."Field Caption" = GenJournalLine.FieldCaption("Bal. Account No.")) or
                                  (FieldsRec."Field Caption" = GenJournalLine.FieldCaption("External Document No.")) or
                                  (FieldsRec."Field Caption" = GenJournalLine.FieldCaption("Shortcut Dimension 1 Code")) or
                                  (FieldsRec."Field Caption" = GenJournalLine.FieldCaption("Shortcut Dimension 2 Code"))

                                then begin
                                    ExcelBuf."Cell Value as Text" :=
                                      DelChr(ExcelBuf."Cell Value as Text", '=', ',');
                                    ExcelBuf."Cell Value as Text" :=
                                      DelChr(ExcelBuf."Cell Value as Text", '=', '.');
                                end;
                                GenFieldRef.Validate(ExcelBuf."Cell Value as Text");
                            end;
                        end;
                    end;
                    RowNo := ExcelBuf."Row No.";
                    IF ExcelBuf.Next = 0 then
                        CurField := NoFields;
                    if ExcelBuf."Column No." = 1 then // this is a new row, need to create a new Gen. Journal Line
                        CurField := NoFields;

                    TotalRecNo -= 1;
                end;
                if not DocNoHeaderFound then
                    AutoPopulateDocNo(GenJournalLine);

                GenRecRef.Modify(true);
                GenRecRef.Close;

                LineNo += 10000;
            until (TotalRecNo <= 0);

        Window.Close;
    end;

    procedure GetJnlLineNo(Template: Code[10]; Batch: Code[20]): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin

        GenJournalLine.SetFilter("Journal Template Name", Template);
        GenJournalLine.SetFilter("Journal Batch Name", Batch);
        if GenJournalLine.FindLast then
            LineNo := GenJournalLine."Line No." + 10000
        else begin
            GenJournalLine."Journal Template Name" := Template;
            GenJournalLine."Journal Batch Name" := Batch;
            LineNo := 10000;
        end;

        if GenJournalTemplate.Get(Template) then
            SourceCode := GenJournalTemplate."Source Code";

        GLSetup.Get;
    end;

    procedure AutoPopulateDocNo(GenJournalLine: Record "Gen. Journal Line")
    var
        Balance: Decimal;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AmountValue: Decimal;
    begin
        // Auto Populate Document No. based on Jounal Template No Series if not in sheet exclude Header
        if ExcelBuf."Row No." = 1 then
            exit;

        GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Document No."));
        if Format(GenFieldRef.Value) <> '' then
            exit;

        if GenJournalTemplate."No. Series" = '' then
            exit;

        if DocumentNo = '' then begin
            GenJournalLine.SetUpNewLine(GenJournalLine, Balance, true);
            DocumentNo := GenJournalLine."Document No.";
        end;

        GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo("Document No."));
        GenFieldRef.Validate(DocumentNo);

        GenFieldRef := GenRecRef.Field(GenJournalLine.FieldNo(Amount));
        AmountValue := GenFieldRef.Value;
        if AmountValue < 0 then
            DocumentNo := IncStr(DocumentNo);
    end;
}
