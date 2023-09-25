#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 60004 "MFCC01PurchaseExcelImport"
{
    Caption = 'Purchase Excel Import';
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
        PurchaseImport: Record "MFCC01 Purchase Import";
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
            PurchaseImport.Init();
            PurchaseImport."Entry No." := EntryNo;

            //Header Fields >>
            PurchaseImport."Document Type" := DocTypeEnumConvert(GetCellvalueatPoistion(R, 1));
            PurchaseImport."Document No." := GetCellvalueatPoistion(R, 2);
            PurchaseImport."Vendor No." := GetCellvalueatPoistion(R, 3);
            PurchaseImport."Pay-to Vendor No." := GetCellvalueatPoistion(R, 4);
            Evaluate(PurchaseImport."Posting Date", GetCellvalueatPoistion(R, 5));
            PurchaseImport."External Document No." := GetCellvalueatPoistion(R, 6);
            //Header Fields <<

            //Lines >>
            PurchaseImport.Type := LineTypeEnumConvert(GetCellvalueatPoistion(R, 7));
            PurchaseImport."No." := GetCellvalueatPoistion(R, 8);
            PurchaseImport.Description := GetCellvalueatPoistion(R, 9);
            PurchaseImport."Unit of Measure Code" := GetCellvalueatPoistion(R, 10);
            PurchaseImport."Variant Code" := GetCellvalueatPoistion(R, 11);
            PurchaseImport."Location Code" := GetCellvalueatPoistion(R, 12);
            Evaluate(PurchaseImport.Quantity, GetCellvalueatPoistion(R, 13));
            Evaluate(PurchaseImport."Unit Price", GetCellvalueatPoistion(R, 14));
            //Evaluate(PurchaseImport."Line Amount", GetCellvalueatPoistion(R, 15));
            //Lines <<

            EntryNo += 1;
            PurchaseImport.Insert();
        End;

    end;

    procedure LineTypeEnumConvert(TyepName: Text) PurchaseLineType: Enum "Purchase Line Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := PurchaseLineType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := PurchaseLineType.Ordinals.Get(Index); // Ordinal value = 30
        PurchaseLineType := Enum::"Purchase Line Type".FromInteger(OrdinalValue);
    end;

    procedure DocTypeEnumConvert(TyepName: Text) PurchaseDocType: Enum "Purchase Document Type"
    var
        OrdinalValue: Integer;
        Index: Integer;

    begin
        TyepName := StrSubstNo('%1', TyepName);
        Index := PurchaseDocType.Names.IndexOf(TyepName); // Index = 3
        OrdinalValue := PurchaseDocType.Ordinals.Get(Index); // Ordinal value = 30
        PurchaseDocType := Enum::"Purchase Line Type".FromInteger(OrdinalValue);
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