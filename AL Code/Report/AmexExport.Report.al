report 60014 "Amex Export"
{
    UsageCategory = ReportsAndAnalysis;
    //ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem("Gen. Journal Line"; "Gen. Journal Line")
        {
            DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
            RequestFilterFields = "Journal Template Name", "Journal Batch Name";
            trigger OnAfterGetRecord()
            begin
                IF Not Vend.Get(GetAccountNo()) then
                    CurrReport.Skip();

                FindAppliedEntries();
            end;
        }
    }
    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {

            }
        }

        actions
        {

        }
    }



    var
        TempCSVBUffer: Record "CSV Buffer" temporary;
        RowNo: Integer;
        Vend: Record Vendor;

    trigger OnPreReport()
    Begin
        IF "Gen. Journal Line".GetFilter("Journal Template Name") = '' then
            Error('Journal Template Name Must be selected.');

        IF "Gen. Journal Line".GetFilter("Journal Batch Name") = '' then
            Error('Journal Batch Name Must be selected.');
    End;

    trigger OnPostReport()
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        CSvIns: InStream;
        FIleMg: Codeunit "File Management";
        CsvFileType: Label 'Excel Files (*.csv)|*.csv', Comment = '{Split=r''\|''}{Locked=s''1''}';
    Begin
        IF RowNo <> 0 then begin

            TempCSVBUffer.SaveDataToBlob(TempBlob, ',');
            TempBlob.CreateInStream(CSvIns);
            //InStream: InStream, DialogTitle: Text, ToFolder: Text, ToFilter: Text, var ToFile: Text
            FileName := 'Amex File Export ' + Format(CurrentDateTime) + '.csv';
            DownloadFromStream(CSvIns, 'Amex file Export', '', CsvFileType, FileName);
        end;
    End;

    local procedure FindAppliedEntries()
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        IF "Gen. Journal Line"."Applies-to Doc. No." <> '' then Begin
            VendLedgEntry.Reset();
            VendLedgEntry.SetRange("Vendor No.", Vend."No.");
            VendLedgEntry.SetRange("Document Type", "Gen. Journal Line"."Applies-to Doc. Type");
            VendLedgEntry.SetRange("Document No.", "Gen. Journal Line"."Applies-to Doc. No.");
            VendLedgEntry.SetRange(Open, true);
            VendLedgEntry.FindFirst();
            AddEntry(VendLedgEntry);
        End Else Begin
            VendLedgEntry.Reset();
            VendLedgEntry.SetCurrentKey("Vendor No.", Open, Positive);
            VendLedgEntry.SetRange("Vendor No.", Vend."No.");
            VendLedgEntry.SetRange(Open, true);
            VendLedgEntry.SetRange("Applies-to ID", "Gen. Journal Line"."Applies-to ID");
            if VendLedgEntry.Find('-') then
                repeat
                    AddEntry(VendLedgEntry);
                Until VendLedgEntry.Next() = 0;
        End;
    end;



    local procedure AddEntry(VendLedger: Record "Vendor Ledger Entry")
    var
        Amount: Decimal;
    begin
        Amount := -Round(VendLedger."Amount to Apply", 0.01, '=');
        RowNo += 1;
        TempCSVBUffer.InsertEntry(RowNo, 1, '"' + Vend."No." + '"');
        TempCSVBUffer.InsertEntry(RowNo, 2, '"' + Vend.Name + '"');
        TempCSVBUffer.InsertEntry(RowNo, 3, '"' + Vend."E-Mail" + '"');
        TempCSVBUffer.InsertEntry(RowNo, 4, '" "');
        TempCSVBUffer.InsertEntry(RowNo, 5, '"' + Format(Amount) + '"');
        TempCSVBUffer.InsertEntry(RowNo, 6, '0');
        TempCSVBUffer.InsertEntry(RowNo, 7, '"' + Format(Amount) + '"');
        TempCSVBUffer.InsertEntry(RowNo, 8, '"' + "Gen. Journal Line"."Document No." + '"');
        TempCSVBUffer.InsertEntry(RowNo, 9, '"' + VendLedger."Document No." + '"');
        TempCSVBUffer.InsertEntry(RowNo, 10, '"' + Format(VendLedger."Posting Date") + '"');
        TempCSVBUffer.InsertEntry(RowNo, 11, '"' + Format("Gen. Journal Line"."Posting Date") + '"');
        TempCSVBUffer.InsertEntry(RowNo, 12, '"  "');
        TempCSVBUffer.InsertEntry(RowNo, 13, '11111111');
        TempCSVBUffer.InsertEntry(RowNo, 14, '"  "');
        TempCSVBUffer.InsertEntry(RowNo, 15, '"' + Vend.Address + '"');
        TempCSVBUffer.InsertEntry(RowNo, 16, '"' + Vend."Address 2" + '"');
        TempCSVBUffer.InsertEntry(RowNo, 17, '"' + Vend.City + '"');
        TempCSVBUffer.InsertEntry(RowNo, 18, '"' + Vend.County + '"');
        TempCSVBUffer.InsertEntry(RowNo, 19, '"' + Vend."Post Code" + '"');
        TempCSVBUffer.InsertEntry(RowNo, 20, '"  "');


    end;


    local procedure GetAccountNo(): Code[20]

    begin
        IF "Gen. Journal Line"."Account Type" = "Gen. Journal Line"."Account Type"::Vendor then
            Exit("Gen. Journal Line"."Account No.");
        IF "Gen. Journal Line"."Bal. Account Type" = "Gen. Journal Line"."Bal. Account Type"::Vendor then
            Exit("Gen. Journal Line"."Bal. Account No.");

        Exit('');
    end;


    local procedure MyProcedure()
    var
        myInt: Integer;
    begin

    end;
}