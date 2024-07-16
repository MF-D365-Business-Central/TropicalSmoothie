xmlport 60004 "Stat Ledger TSC"
{
    Direction = Export;
    Format = VariableText;
    FileName = 'Stat Ledger TSC.psv';
    TableSeparator = '<NewLine>';
    FieldSeparator = '|';
    FieldDelimiter = '';
    schema
    {
        textelement(NodeName1)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = where(Number = const(1));
                textelement(DocumentNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        DocumentNo := StatEntry.FieldCaption("Document No.");
                    End;
                }
                textelement(PostingDate)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        PostingDate := StatEntry.FieldCaption("Posting Date");
                    End;
                }

                textelement(StatisticalAccountNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        StatisticalAccountNo := StatEntry.FieldCaption("Statistical Account No.");
                    End;
                }
                textelement(Description)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Description := StatEntry.FieldCaption("Description");
                    End;
                }
                textelement(Amount)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Amount := StatEntry.FieldCaption("Amount");
                    End;
                }
                textelement(EntryNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        EntryNo := StatEntry.FieldCaption("Entry No.");
                    End;
                }
                textelement(GlobalDimension1Code)
                {

                    trigger OnBeforePassVariable()
                    Begin
                        GlobalDimension1Code := StatEntry.FieldCaption("Global Dimension 1 Code");
                    End;
                }
                textelement(GlobalDimension2Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GlobalDimension2Code := StatEntry.FieldCaption("Global Dimension 2 Code");
                    End;
                }


                textelement(ShortcutDimension3Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ShortcutDimension3Code := StatEntry.FieldCaption("Shortcut Dimension 3 Code");
                    End;
                }
                textelement(ShortcutDimension4Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ShortcutDimension4Code := StatEntry.FieldCaption("Shortcut Dimension 4 Code");
                    End;
                }
                trigger OnAfterGetRecord()
                Begin
                    IF NewSkipHeader then
                        currXMLport.skip();
                End;
            }
            tableelement(StatEntry; "Statistical Ledger Entry")
            {
                RequestFilterFields = "Posting Date";
                fieldelement(DocumentNo; StatEntry."Document No.")
                {
                }
                fieldelement(PostingDate; StatEntry."Posting Date")
                {
                }

                fieldelement(StatisticalAccountNo; StatEntry."Statistical Account No.")
                {
                }
                fieldelement(Description; StatEntry.Description)
                {
                }
                fieldelement(Amount; StatEntry.Amount)
                {
                }
                fieldelement(EntryNo; StatEntry."Entry No.")
                {
                }
                fieldelement(GlobalDimension1Code; StatEntry."Global Dimension 1 Code")
                {
                }
                fieldelement(GlobalDimension2Code; StatEntry."Global Dimension 2 Code")
                {
                }

                fieldelement(ShortcutDimension3Code; StatEntry."Shortcut Dimension 3 Code")
                {
                }
                fieldelement(ShortcutDimension4Code; StatEntry."Shortcut Dimension 4 Code")
                {
                }

                trigger OnPreXmlItem()
                Begin
                    StatEntry.SetRange("Posting Date", NewFromDate, NewToDate);
                    //currXMLport.TextEncoding(TextEncoding::UTF8);
                End;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {

            }
        }

        actions
        {
            area(processing)
            {

            }
        }
    }

    procedure SetDate(FromDate: Date; ToDate: Date; SkipHeader: Boolean)
    Begin
        NewFromDate := FromDate;
        NewToDate := ToDate;
        NewSkipHeader := SkipHeader;
    End;


    Var
        NewFromDate: Date;
        NewToDate: Date;
        NewSkipHeader: Boolean;
}