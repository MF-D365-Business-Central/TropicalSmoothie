#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 60003 "MFCC01SalesExcelImport"
{
    Caption = 'Sales Excel Import';
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
        Window.Update(1, 'Importing from Excel..');
        PrepareStaging();
        Window.Close();
    end;

    var
        SalesImport: Record "MFCC01 Sales Import";
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


        for R := 2 to TotalRows DO Begin
            SalesImport.Init();
            SalesImport."Entry No." := EntryNo;

            //Header Fields >>
            SalesImport."Document Type" := DocTypeEnumConvert(GetCellvalueatPoistion(R, 1));
            SalesImport."Document No." := GetCellvalueatPoistion(R, 2);
            SalesImport."Customer No." := GetCellvalueatPoistion(R, 3);
            SalesImport."Bill-to Customer No." := GetCellvalueatPoistion(R, 4);
            Evaluate(SalesImport."Posting Date", GetCellvalueatPoistion(R, 5));
            SalesImport."External Document No." := GetCellvalueatPoistion(R, 6);
            //Header Fields <<

            //Lines >>
            SalesImport.Type := LineTypeEnumConvert(GetCellvalueatPoistion(R, 7));
            SalesImport."No." := GetCellvalueatPoistion(R, 8);
            SalesImport.Description := GetCellvalueatPoistion(R, 9);
            SalesImport."Unit of Measure Code" := GetCellvalueatPoistion(R, 10);
            SalesImport."Variant Code" := GetCellvalueatPoistion(R, 11);
            SalesImport."Location Code" := GetCellvalueatPoistion(R, 12);
            Evaluate(SalesImport.Quantity, GetCellvalueatPoistion(R, 13));
            Evaluate(SalesImport."Unit Price", GetCellvalueatPoistion(R, 14));
            //Evaluate(SalesImport."Line Amount", GetCellvalueatPoistion(R, 15));
            //Lines <<

            EntryNo += 1;
            SalesImport.Insert();
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








    local procedure GetNextEntry()
    var
        SalesImport2: Record "MFCC01 Sales Import";
    begin
        IF SalesImport2.FindLast() then
            EntryNo := SalesImport2."Entry No." + 1;
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