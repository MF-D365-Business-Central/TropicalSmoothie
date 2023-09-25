report 60005 "MFCC01FAExcelImport"
{
    Caption = 'FA Excel Import';
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
        Window.Update(1, 'Importing from Excel...');
        PrepareStaging();
        Window.Close();
    end;

    var
        FAImport: Record "MFCC01 FA Import";
        ExcelBuf: Record "Excel Buffer" temporary;
        FileName: Text[250];
        SheetName: Text[250];
        Text001: label 'You must enter a file name.';
        Text002: label 'You must enter an Excel worksheet name.', Comment = '{Locked="Excel"}';
        FileMgt: Codeunit "File Management";
        ExcelFileExtensionTok: label '.xlsx', Locked = true;
        EntryNo: Integer;
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
        GetNextEntry();
        ExcelBuf.SetRange("Column No.", 1);
        TotalRows := ExcelBuf.Count;
        ExcelBuf.SetRange("Column No.");
        ExcelBuf.SetRange("Row No.", 1);
        TotalColumns := ExcelBuf.Count;


        for R := 9 to TotalRows DO Begin
            FAImport.Init();
            FAImport."Entry No." := EntryNo;

            //Header Fields >>
            FAImport.Category := GetCellvalueatPoistion(R, 1);
            FAImport.Description := GetCellvalueatPoistion(R, 2);

            Evaluate(FAImport."Useful Life In Months", GetCellvalueatPoistion(R, 3));
            FAImport."Method/Conv" := GetCellvalueatPoistion(R, 4);
            Evaluate(FAImport."In Service Date", GetCellvalueatPoistion(R, 5));
            Evaluate(FAImport."Disposal Date", GetCellvalueatPoistion(R, 6));
            Evaluate(FAImport."Historical Cost/Other Basis", GetCellvalueatPoistion(R, 7));
            Evaluate(FAImport."FMV Cost/Other Basis", GetCellvalueatPoistion(R, 8));
            Evaluate(FAImport."Accumulated Depreciation", GetCellvalueatPoistion(R, 9));
            Evaluate(FAImport.NBV, GetCellvalueatPoistion(R, 10));

            EntryNo += 1;
            FAImport.Insert();
        End;

    end;

    procedure LineTypeEnumConvert(TyepName: Text) SaleLineType: Enum "Purchase Line Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := SaleLineType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := SaleLineType.Ordinals.Get(Index); // Ordinal value = 30
        SaleLineType := Enum::"Purchase Line Type".FromInteger(OrdinalValue);
    end;

    procedure DocTypeEnumConvert(TyepName: Text) SaleDocType: Enum "Purchase Document Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := SaleDocType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := SaleDocType.Ordinals.Get(Index); // Ordinal value = 30
        SaleDocType := Enum::"Purchase Line Type".FromInteger(OrdinalValue);
    end;

    local procedure GetNextEntry()
    var
        PurchaseImport2: Record "MFCC01 Purchase Import";
    begin
        IF PurchaseImport2.FindLast() then
            EntryNo := PurchaseImport2."Entry No." + 1;
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
