report 60006 "MFCC01 Vendor import"
{

    Caption = 'Vendor Excel Import';
    Permissions = TableData "Excel Buffer" = rimd;
    ProcessingOnly = true;
    ApplicationArea = all;
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
        Vendor: Record Vendor;
        ExcelBuf: Record "Excel Buffer" temporary;
        VendorTempl: Record "Vendor Templ.";
        VedorTempMgmt: Codeunit "Vendor Templ. Mgt.";
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
            Vendor.Init();


            // Vendor ID	1
            Vendor."No." := GetCellvalueatPoistion(R, 1);
            Vendor.Insert(true);
            // Remittance Name	2
            Vendor.Name := GetCellvalueatPoistion(R, 2);
            // Taxpayer Identification Number	3
            Vendor."VAT Registration No." := GetCellvalueatPoistion(R, 3);
            // Remittance Address 1	4
            Vendor.Address := GetCellvalueatPoistion(R, 4);
            // Remittance Address 2	5
            Vendor."Address 2" := CopyStr(GetCellvalueatPoistion(R, 5),1,50);
            // Remittance Attention	6
            // Remittance City	7
            Vendor.City := CopyStr(GetCellvalueatPoistion(R, 7),1,30);
            // Remittance State	8
            Vendor.County := CopyStr(GetCellvalueatPoistion(R, 8),1,30);
            // Remittance Zip Code	9
            Vendor."Post Code" := CopyStr(GetCellvalueatPoistion(R, 9),1,20);
            // Remittance Phone Number	10
            Vendor."Phone No." := CopyStr(GetCellvalueatPoistion(R, 10),1,30);
            // Remittance Fax Number	11
            Vendor."Fax No." := CopyStr(GetCellvalueatPoistion(R, 11),1,30);
            // 1099 Vendor	12
            Vendor."IRS 1099 Code" := GetCellvalueatPoistion(R, 12);
            // Default 1099 Box	13
            // Status Description	14
            IF uppercase(GetCellvalueatPoistion(R, 14)) <> 'ACTIVE' then
                Vendor.Blocked := Vendor.Blocked::All;

            Vendor.Modify(true);
            // Template 15
            IF VendorTempl.Get(GetCellvalueatPoistion(R, 15)) then
                VedorTempMgmt.ApplyVendorTemplate(Vendor, VendorTempl, false);

        End;

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