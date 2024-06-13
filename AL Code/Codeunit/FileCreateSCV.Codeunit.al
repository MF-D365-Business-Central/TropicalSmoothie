codeunit 60020 "CSVBuffer"
{
    trigger OnRun()
    begin

    end;

    procedure GetGLTSC() Response: Text
    var
        CSVBuffer: Record "CSV Buffer" temporary;
        GLEntry: Record "G/L Entry";
        TempBlob: Codeunit "Temp Blob";
        Row: Integer;
        FileIns: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        HttpContent: HttpContent;
        FileName: Text;
        AllFilesDescriptionTxt: Label 'All Files (*.*)|*.*', Comment = '{Split=r''\|''}{Locked=s''1''}';

    begin

        Row := 1;
        CSVBuffer.InsertEntry(Row, 1, GLEntry.FieldCaption("Posting Date"));
        CSVBuffer.InsertEntry(Row, 2, GLEntry.FieldCaption("Entry No."));
        CSVBuffer.InsertEntry(Row, 3, GLEntry.FieldCaption("Document Type"));
        CSVBuffer.InsertEntry(Row, 4, GLEntry.FieldCaption("Document No."));
        CSVBuffer.InsertEntry(Row, 5, GLEntry.FieldCaption("Description 2"));
        CSVBuffer.InsertEntry(Row, 6, GLEntry.FieldCaption("Document Date"));
        CSVBuffer.InsertEntry(Row, 7, GLEntry.FieldCaption("G/L Account No."));
        CSVBuffer.InsertEntry(Row, 8, GLEntry.FieldCaption("G/L Account No."));
        CSVBuffer.InsertEntry(Row, 9, 'DEPT');
        CSVBuffer.InsertEntry(Row, 10, 'MARKET');
        CSVBuffer.InsertEntry(Row, 11, GLEntry.FieldCaption("Source No."));
        CSVBuffer.InsertEntry(Row, 12, GLEntry.FieldCaption("Gen. Posting Type"));
        CSVBuffer.InsertEntry(Row, 13, GLEntry.FieldCaption("Gen. Bus. Posting Group"));
        CSVBuffer.InsertEntry(Row, 14, GLEntry.FieldCaption("Gen. Prod. Posting Group"));
        CSVBuffer.InsertEntry(Row, 15, GLEntry.FieldCaption(Amount));
        CSVBuffer.InsertEntry(Row, 16, GLEntry.FieldCaption("Debit Amount"));
        CSVBuffer.InsertEntry(Row, 17, GLEntry.FieldCaption("Credit Amount"));
        CSVBuffer.InsertEntry(Row, 18, GLEntry.FieldCaption("Bal. Account Type"));
        CSVBuffer.InsertEntry(Row, 19, GLEntry.FieldCaption("Bal. Account No."));
        CSVBuffer.InsertEntry(Row, 20, GLEntry.FieldCaption("Source Name"));
        CSVBuffer.InsertEntry(Row, 21, GLEntry.FieldCaption("External Document No."));
        CSVBuffer.InsertEntry(Row, 22, 'CAFE');
        CSVBuffer.InsertEntry(Row, 23, 'FMM');
        Row += 1;
        GLEntry.SetFilter("Posting Date", '>=%1', GetDate());
        GLEntry.SetLoadFields("Posting Date", "Entry No.", "Document Type", "Document No.", "Description 2", "Document Date",
        "G/L Account No.", "G/L Account No.", "Source No.", "Gen. Posting Type", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group"
        , Amount, "Debit Amount", "Credit Amount", "Bal. Account Type", "Bal. Account No.", "Source Name", "External Document No.",
        "Global Dimension 1 Code", "Global Dimension 2 Code", "Shortcut Dimension 3 Code", "Shortcut Dimension 4 Code");
        IF GLEntry.FindSet(false) then
            repeat
                CSVBuffer.InsertEntry(Row, 1, Format(GLEntry."Posting Date"));
                CSVBuffer.InsertEntry(Row, 2, Format(GLEntry."Entry No."));
                CSVBuffer.InsertEntry(Row, 3, Format(GLEntry."Document Type"));
                CSVBuffer.InsertEntry(Row, 4, Format(GLEntry."Document No."));
                CSVBuffer.InsertEntry(Row, 5, Format(GLEntry."Description 2"));
                CSVBuffer.InsertEntry(Row, 6, Format(GLEntry."Document Date"));
                CSVBuffer.InsertEntry(Row, 7, Format(GLEntry."G/L Account No."));
                CSVBuffer.InsertEntry(Row, 8, Format(GLEntry."G/L Account No."));
                CSVBuffer.InsertEntry(Row, 9, Format(GLEntry."Entry No."));
                CSVBuffer.InsertEntry(Row, 10, Format(GLEntry."Entry No."));
                CSVBuffer.InsertEntry(Row, 11, Format(GLEntry."Source No."));
                CSVBuffer.InsertEntry(Row, 12, Format(GLEntry."Gen. Posting Type"));
                CSVBuffer.InsertEntry(Row, 13, Format(GLEntry."Gen. Bus. Posting Group"));
                CSVBuffer.InsertEntry(Row, 14, Format(GLEntry."Gen. Prod. Posting Group"));
                CSVBuffer.InsertEntry(Row, 15, Format(GLEntry.Amount));
                CSVBuffer.InsertEntry(Row, 16, Format(GLEntry."Debit Amount"));
                CSVBuffer.InsertEntry(Row, 17, Format(GLEntry."Credit Amount"));
                CSVBuffer.InsertEntry(Row, 18, Format(GLEntry."Bal. Account Type"));
                CSVBuffer.InsertEntry(Row, 19, Format(GLEntry."Bal. Account No."));
                CSVBuffer.InsertEntry(Row, 20, Format(GLEntry."Source Name"));
                CSVBuffer.InsertEntry(Row, 21, Format(GLEntry."External Document No."));
                CSVBuffer.InsertEntry(Row, 22, Format(GLEntry."Shortcut Dimension 3 Code"));
                CSVBuffer.InsertEntry(Row, 23, Format(GLEntry."Shortcut Dimension 4 Code"));
                Row += 1;
            Until GLEntry.Next() = 0;
        CSVBuffer.SaveDataToBlob(TempBlob, ',');
        TempBlob.CreateInStream(FileIns);
        HttpContent.WriteFrom(FileIns);
        HttpContent.ReadAs(Response);
        //InStream: InStream, DialogTitle: Text, ToFolder: Text, ToFilter: Text, varToFile: Text
        FileName := 'GLExport.csv';
        IF GuiAllowed then
            DownloadFromStream(FileIns, 'Export', '', 'AllFilesDescriptionTxt', FileName);
    end;

    local procedure GetDate(): Date
    var
        CurrPeriod: Date;
        AccPeriod: Record "Accounting Period";
    begin
        AccPeriod.SetFilter("Starting Date", '<=%1', Today());
        IF AccPeriod.FindLast() then
            CurrPeriod := AccPeriod."Starting Date";

        AccPeriod.SetFilter("Starting Date", '<%1', CurrPeriod);
        IF AccPeriod.FindLast() then;


        exit(AccPeriod."Starting Date");

    end;
}