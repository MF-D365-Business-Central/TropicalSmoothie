report 60012 "MFCC01 Depreciation"
{
    Caption = 'Depreciation Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "FA Class Code", "FA Subclass Code", "FA Posting Group";
            DataItemTableView = where("Main Asset/Component" = filter(<> Component));
            trigger OnAfterGetRecord()
            begin
                FADepBook.SetRange("FA No.", "Fixed Asset"."No.");
                IF FADepBook.FindFirst() then
                    PrepareBody();
            end;

            trigger OnPreDataItem()
            Begin
                Prepareheader();
            End;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Fromdate; Fromdate)
                    {
                        Caption = 'From Date';
                        ApplicationArea = All;
                    }
                    field(ToDate; ToDate)
                    {
                        Caption = 'To Date';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnPreReport()
    begin
        IF (Fromdate = 0D) or (ToDate = 0D) then
            Error(PeriodErr);
    end;

    trigger OnPostReport()
    Begin
        CreateBookAndOpenExcel();
    End;

    local procedure Prepareheader()

    begin
        ExcelBuffer.AddColumn('Fixed Asset:', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('FA Posting Date Filter:', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Format(Fromdate) + '..' + Format(ToDate), false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();

        //Value: Variant, IsFormula: Boolean, CommentText: Text, IsBold: Boolean, IsItalics: Boolean, IsUnderline: Boolean, NumFormat: Text[30], CellType: Option
        ExcelBuffer.AddColumn('No.', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Category', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Useful Life In Months', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Method/Conv', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('In Service Date', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Disposal Date', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Beginning Acquisition Cost (gross)', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('In-Period Additions', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Acquisition Cost Disposals', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ending Book Value (gross)', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Beginning Accum. Depr', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Accum. Depr Disposals', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('In-Period  Depreciation', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ending Accum. Depreciation', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ending Net Book Value', false, '', True, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    local procedure PrepareBody()
    var
        H: Decimal;
        I: Decimal;
        J: Decimal;
        L: Decimal;
        M: Decimal;
        N: Decimal;
    begin
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn("Fixed Asset"."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Fixed Asset"."FA Subclass Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Fixed Asset".Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(FADepBook."No. of Depreciation Months", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(FADepBook."Depreciation Method", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(FADepBook."Depreciation Starting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn(FADepBook."Disposal Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        H := BeginingBookValueGross();
        ExcelBuffer.AddColumn(H, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        I := InPeriodAdditions();
        ExcelBuffer.AddColumn(I, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        J := InPeriodDisposals();
        ExcelBuffer.AddColumn(J, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(H + I + J, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        L := BeginningAccumDepr();
        ExcelBuffer.AddColumn(L, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        M := AccumDeprDisposals();
        ExcelBuffer.AddColumn(M, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        N := InPeriodDepreciation;
        ExcelBuffer.AddColumn(N, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(L + M + N, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(H + I + J + L + M + N, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
    end;

    local procedure BeginingBookValueGross(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetFilter("Posting Date", '<%1', Fromdate);
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
        FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
        FAledger.CalcSums("Amount (LCY)");
        //exit(FAledger."Amount (LCY)");

        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetFilter("Posting Date", '<%1', Fromdate);
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
                FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure InPeriodAdditions(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
        FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
        FAledger.SetRange("Posting Date", Fromdate, ToDate);
        FAledger.CalcSums("Amount (LCY)");

        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
                FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
                FAledger.SetRange("Posting Date", Fromdate, ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure InPeriodDisposals(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.Reset();
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
        FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
        FAledger.SetRange("Posting Date", Fromdate, ToDate);
        FAledger.CalcSums("Amount (LCY)");
        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.Reset();
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Acquisition Cost");
                FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
                FAledger.SetRange("Posting Date", Fromdate, ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        FAledger.Reset();
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Write-Down");
        //FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
        FAledger.SetRange("Posting Date", Fromdate, ToDate);
        FAledger.CalcSums("Amount (LCY)");
        Amt += FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.Reset();
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::"Write-Down");
                //FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
                FAledger.SetRange("Posting Date", Fromdate, ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;
        exit(Amt);
    end;

    local procedure BeginningAccumDepr(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
        FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
        FAledger.SetFilter("Posting Date", '<%1', Fromdate);
        FAledger.CalcSums("Amount (LCY)");
        //exit(FAledger."Amount (LCY)");

        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
                FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
                FAledger.SetFilter("Posting Date", '<%1', Fromdate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure AccumDeprDisposals(): Decimal
    var
        DepBook: Record "FA Depreciation Book";
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        IF FADepBook."Disposal Date" <> 0D then Begin

            FAledger.SetRange("FA No.", "Fixed Asset"."No.");
            FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
            FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
            FAledger.SetRange("Posting Date", Fromdate, ToDate);
            FAledger.CalcSums("Amount (LCY)");
            //exit(FAledger."Amount (LCY)");
            Amt := FAledger."Amount (LCY)";
        End;
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                DepBook.SetRange("FA No.", Component."No.");
                DepBook.FindFirst();
                IF DepBook."Disposal Date" <> 0D then Begin
                    FAledger.SetRange("FA No.", Component."No.");
                    FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
                    FAledger.SetRange("FA Posting Category", FAledger."FA Posting Category"::Disposal);
                    FAledger.SetRange("Posting Date", Fromdate, ToDate);
                    FAledger.CalcSums("Amount (LCY)");
                    Amt += FAledger."Amount (LCY)";
                End;
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure InPeriodDepreciation(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
        FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
        FAledger.SetRange("Posting Date", Fromdate, ToDate);
        FAledger.CalcSums("Amount (LCY)");
        //exit(FAledger."Amount (LCY)");
        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
                FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
                FAledger.SetRange("Posting Date", Fromdate, ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure EndigDepreciation(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
        FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
        FAledger.SetFilter("Posting Date", '..%1', ToDate);
        FAledger.CalcSums("Amount (LCY)");
        //exit(FAledger."Amount (LCY)");
        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetRange("FA Posting Type", FAledger."FA Posting Type"::Depreciation);
                FAledger.SetRange(FAledger."FA Posting Category", FAledger."FA Posting Category"::" ");
                FAledger.SetFilter("Posting Date", '..%1', ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure EndingNetBookValue(): Decimal
    var
        FAledger: Record "FA Ledger Entry";
        Component: Record "Fixed Asset";
        Amt: Decimal;
    begin
        FAledger.SetRange("FA No.", "Fixed Asset"."No.");
        FAledger.SetFilter("Posting Date", '..%1', ToDate);
        FAledger.CalcSums("Amount (LCY)");
        //exit(FAledger."Amount (LCY)");
        Amt := FAledger."Amount (LCY)";
        Component.Reset();
        Component.SetRange("Main Asset/Component", Component."Main Asset/Component"::Component);
        Component.SetRange("Component of Main Asset", "Fixed Asset"."No.");
        IF Component.FindFirst() then
            repeat
                FAledger.SetRange("FA No.", Component."No.");
                FAledger.SetFilter("Posting Date", '..%1', ToDate);
                FAledger.CalcSums("Amount (LCY)");
                Amt += FAledger."Amount (LCY)";
            Until Component.Next() = 0;

        exit(Amt);
    end;

    local procedure CreateBookAndOpenExcel()
    begin
        ExcelBuffer.CreateNewBook('Sheet1');
        ExcelBuffer.WriteSheet('Depriciation Report', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        FADepBook: Record "FA Depreciation Book";
        Fromdate: Date;
        ToDate: Date;
        PeriodErr: Label 'From Date , To Date must be filled.';
}