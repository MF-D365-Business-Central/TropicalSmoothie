#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 60003 "MFCC01SalesInvocieExcelImport"
{
    Caption = 'Sales Invocie Excel Import';
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
        Window.Update(1, 'Excel Import.');
        PrepareStaging();
        Window.Update(1, 'Invoice Creation.');
        GenerateInvoice();
        Window.Update(1, 'Invoice Posting.');
        PostDocuments();
        Window.Close();
    end;

    var
        SalesStaging: Record "MFCC01 Sales Staging";
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
            SalesStaging.Init();
            SalesStaging."Entry No." := EntryNo;

            //Header Fields >>
            SalesStaging."Document Type" := DocTypeEnumConvert(GetCellvalueatPoistion(R, 1));
            SalesStaging."Document No." := GetCellvalueatPoistion(R, 2);
            SalesStaging."Customer No." := GetCellvalueatPoistion(R, 3);
            SalesStaging."Bill-to Customer No." := GetCellvalueatPoistion(R, 4);
            Evaluate(SalesStaging."Posting Date", GetCellvalueatPoistion(R, 5));
            SalesStaging."External Document No." := GetCellvalueatPoistion(R, 6);
            //Header Fields <<

            //Lines >>
            SalesStaging.Type := LineTypeEnumConvert(GetCellvalueatPoistion(R, 7));
            SalesStaging."No." := GetCellvalueatPoistion(R, 8);
            SalesStaging.Description := GetCellvalueatPoistion(R, 9);
            SalesStaging."Unit of Measure Code" := GetCellvalueatPoistion(R, 10);
            SalesStaging."Variant Code" := GetCellvalueatPoistion(R, 11);
            SalesStaging."Location Code" := GetCellvalueatPoistion(R, 12);
            Evaluate(SalesStaging.Quantity, GetCellvalueatPoistion(R, 13));
            Evaluate(SalesStaging."Unit Price", GetCellvalueatPoistion(R, 14));
            //Evaluate(SalesStaging."Line Amount", GetCellvalueatPoistion(R, 15));
            //Lines <<

            EntryNo += 1;
            SalesStaging.Insert();
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

    local procedure GenerateInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
        PrevDocumentNo: Code[20];
    begin
        LineNo := 10000;
        SalesStaging.Reset();
        SalesStaging.SetCurrentKey("Document No.");
        SalesStaging.SetRange(Status, SalesStaging.Status::New);
        IF SalesStaging.FindSet(true) then
            repeat
                IF PrevDocumentNo <> SalesStaging."Document No." then Begin
                    SalesHeader := SalesStaging.CreateSalesHeader();
                    PrevDocumentNo := SalesStaging."Document No.";
                End;

                SalesStaging.CreateSalesLine(LineNo);
                SalesStaging.Status := SalesStaging.Status::Created;
                SalesStaging.Modify();
            Until SalesStaging.Next() = 0;
    end;


    local procedure PostDocuments()
    var
        SalesHeader: Record "Sales Header";
        Posted: Boolean;
        PrevDocumentNo: Code[20];
    begin
        Posted := false;
        SalesStaging.Reset();
        SalesStaging.SetCurrentKey("Document No.");
        SalesStaging.SetRange(Status, SalesStaging.Status::Created);
        IF SalesStaging.FindSet(true) then
            repeat
                IF PrevDocumentNo <> SalesStaging."Document No." then Begin
                    Posted := false;
                    Commit();
                    SalesHeader.SetRange("Document Type", SalesStaging."Document Type");
                    SalesHeader.SetRange("No.", SalesStaging."Document No.");
                    IF SalesHeader.FindFirst() then;
                    PostOneDocument(SalesHeader, Posted);
                End;

                IF Posted then Begin
                    SalesStaging.Status := SalesStaging.Status::Posted;
                    SalesStaging.Modify();
                End;
            Until SalesStaging.Next() = 0;
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure PostOneDocument(SalesHeader: Record "Sales Header"; Var Posted: Boolean)

    begin
        IF Codeunit.Run(Codeunit::"Sales-Post", SalesHeader) then
            Posted := True;
    end;

    local procedure GetNextEntry()
    var
        SalesStaging2: Record "MFCC01 Sales Staging";
    begin
        IF SalesStaging2.FindLast() then
            EntryNo := SalesStaging2."Entry No." + 1;
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