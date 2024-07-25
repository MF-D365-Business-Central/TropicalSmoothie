report 60017 "Vendor Payment Status"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            RequestFilterFields = "Posting Date", "Vendor No.", "Vendor Posting Group";
            DataItemTableView = where("Document Type" = const(Invoice));
            CalcFields = "Original Amount", "Remaining Amount", Amount;
            trigger OnAfterGetRecord()
            Begin
                FindApplnEntriesDtldtLedgEntry();
                if TempAppliedDtldVendLedgEntry.FindSet() then
                    Repeat
                        AddDataRow();
                    Until TempAppliedDtldVendLedgEntry.Next() = 0
                else
                    AddDataRow();


            End;

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
                group(GroupName)
                {

                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        TempAppliedDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;

    trigger OnPreReport()
    Begin
        AddHeaderRow();
    End;

    trigger OnPostReport()
    Begin
        ExcelBuffer.CreateNewBook('Vendor Payment Status');
        ExcelBuffer.WriteSheet('Vendor Payment Status', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('Vendor Payment Status');
        ExcelBuffer.OpenExcel();
    End;

    local procedure AddHeaderRow()
    begin
        ExcelBuffer.NewRow();
        //Value: Variant, IsFormula: Boolean, CommentText: Text, IsBold: Boolean, IsItalics: Boolean, 
        //IsUnderline: Boolean, NumFormat: Text[30], CellType: Option
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Posting Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Vendor No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Vendor Name"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Document Type"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Payment method code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("External Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Document Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Due Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Original Amount"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Remaining Amount"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry".FieldCaption("Amount"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.AddColumn('Payment Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Payment Amount', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

    end;

    local procedure AddDataRow()

    begin

        ExcelBuffer.NewRow();
        //Value: Variant, IsFormula: Boolean, CommentText: Text, IsBold: Boolean, IsItalics: Boolean, 
        //IsUnderline: Boolean, NumFormat: Text[30], CellType: Option
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Posting Date", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Vendor No.", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Vendor Name", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Document No.", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Document Type", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Payment method code", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."External Document No.", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Document Date", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn("Vendor Ledger Entry"."Due Date", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Date);

        ExcelBuffer.AddColumn(-("Vendor Ledger Entry"."Original Amount"), false, '', False, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-("Vendor Ledger Entry"."Remaining Amount"), false, '', False, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-("Vendor Ledger Entry"."Amount"), false, '', False, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.AddColumn(TempAppliedDtldVendLedgEntry."Posting Date", false, '', False, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn((TempAppliedDtldVendLedgEntry.Amount), false, '', False, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);

    end;

    local procedure FindApplnEntriesDtldtLedgEntry()
    var
        DtldVendLedgEntry1: Record "Detailed Vendor Ledg. Entry";
        DtldVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        VendLedger: Record "Vendor Ledger Entry";
    begin
        TempAppliedDtldVendLedgEntry.DeleteAll();
        DtldVendLedgEntry1.SetCurrentKey("Vendor Ledger Entry No.");
        DtldVendLedgEntry1.SetRange("Vendor Ledger Entry No.", "Vendor Ledger Entry"."Entry No.");
        DtldVendLedgEntry1.SetRange(Unapplied, false);
        DtldVendLedgEntry1.SetRange("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
        if DtldVendLedgEntry1.Find('-') then
            repeat
                if DtldVendLedgEntry1."Vendor Ledger Entry No." =
                   DtldVendLedgEntry1."Applied Vend. Ledger Entry No."
                then begin
                    DtldVendLedgEntry2.Init();
                    DtldVendLedgEntry2.SetCurrentKey("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SetRange(
                      "Applied Vend. Ledger Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SetRange("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SetRange(Unapplied, false);
                    if DtldVendLedgEntry2.Find('-') then
                        repeat
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <>
                               DtldVendLedgEntry2."Applied Vend. Ledger Entry No."
                            then begin
                                VendLedger.SetCurrentKey("Entry No.");
                                VendLedger.SetRange("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if VendLedger.Find('-') then Begin
                                    TempAppliedDtldVendLedgEntry.TransferFields(DtldVendLedgEntry2);
                                    TempAppliedDtldVendLedgEntry.Insert();
                                End;
                            end;
                        until DtldVendLedgEntry2.Next() = 0;
                end else begin
                    TempAppliedDtldVendLedgEntry.TransferFields(DtldVendLedgEntry1);
                    TempAppliedDtldVendLedgEntry.Insert();

                end;
            until DtldVendLedgEntry1.Next() = 0;
    end;


}