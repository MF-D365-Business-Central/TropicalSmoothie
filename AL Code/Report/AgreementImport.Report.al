#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 60008 "MFCC01AgreementExcelImport"
{
    Caption = 'Agreement Excel Import';
    Permissions = TableData "Excel Buffer" = rimd;
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

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
        Window.Open(Text006 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
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
        Window.Update(1, 'Importing from Excel..');
        PrepareStaging();
        Window.Close();
    end;

    var
        AgreementLine: Record "MFCC01 Agreement Line";
        ExcelBuf: Record "Excel Buffer" temporary;
        FileName: Text[250];
        SheetName: Text[250];
        Text001: label 'You must enter a file name.';
        Text002: label 'You must enter an Excel worksheet name.', Comment = '{Locked="Excel"}';
        FileMgt: Codeunit "File Management";
        ExcelFileExtensionTok: label '.xlsx', Locked = true;
        TotalRows: Integer;
        TotalColumns: Integer;
        Window: Dialog;
        Text006: label 'Processing Data...\\';
        Text004: label 'The Excel worksheet %1 does not exist.', Comment = '{Locked="Excel"}';
        Text007: label 'Reading Excel worksheet...\\', Comment = '{Locked="Excel"}';
        Text035: label 'The operation was canceled.';

    local procedure PrepareStaging()
    Var
        R: Integer;

    begin

        ExcelBuf.SetRange("Column No.", 1);
        TotalRows := ExcelBuf.Count;
        ExcelBuf.SetRange("Column No.");
        ExcelBuf.SetRange("Row No.", 1);
        TotalColumns := ExcelBuf.Count;

        for R := 2 to TotalRows DO Begin
            AgreementLine.Init();
            AgreementLine."Agreement No." := GetCellvalueatPoistion(R, 1);
            AgreementLine."Line No." := GetNextEntry(AgreementLine."Agreement No.");
            Evaluate(AgreementLine."Starting Date", GetCellvalueatPoistion(R, 2));
            Evaluate(AgreementLine."Ending Date", GetCellvalueatPoistion(R, 3));

            Evaluate(AgreementLine."Royalty Fees %", GetCellvalueatPoistion(R, 4));
            Evaluate(AgreementLine."Local Fees %", GetCellvalueatPoistion(R, 5));
            Evaluate(AgreementLine."National Fees %", GetCellvalueatPoistion(R, 6));
            AgreementLine.Insert();
        End;
    end;

    procedure LineTypeEnumConvert(TyepName: Text) SaleLineType: Enum "Sales Line Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := SaleLineType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := SaleLineType.Ordinals.Get(Index); // Ordinal value = 30
        SaleLineType := Enum::"Sales Line Type".FromInteger(OrdinalValue);
    end;

    procedure DocTypeEnumConvert(TyepName: Text) SaleDocType: Enum "Sales Document Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := SaleDocType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := SaleDocType.Ordinals.Get(Index); // Ordinal value = 30
        SaleDocType := Enum::"Sales Line Type".FromInteger(OrdinalValue);
    end;

    local procedure GetNextEntry(AgreementNo: Code[20]) EntryNo: Integer;
    var
        AgreementLine2: Record "MFCC01 Agreement Line";
    begin
        AgreementLine2.SetRange("Agreement No.", AgreementNo);
        IF AgreementLine2.FindLast() then
            EntryNo := AgreementLine2."Line No." + 10000;
    end;

    local procedure GetCellvalueatPoistion(RowNo: Integer; Columnno: Integer): Text
    begin

        ExcelBuf.Setrange("Row No.", RowNo);
        ExcelBuf.Setrange("Column No.", Columnno);
        IF Not ExcelBuf.FindFirst() then
            Clear(ExcelBuf);

        exit(ExcelBuf."Cell Value as Text");
    end;
}