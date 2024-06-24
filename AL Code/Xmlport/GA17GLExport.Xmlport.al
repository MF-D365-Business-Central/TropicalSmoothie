xmlport 60003 "General Ledger GA17"
{
    Direction = Export;
    Format = VariableText;
    FileName = 'General Ledger GA17.csv';
    TableSeparator = '<NewLine>';
    schema
    {
        textelement(NodeName1)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = where(Number = const(1));
                textelement(PostingDate)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        PostingDate := GLEntry.FieldCaption("Posting Date");
                    End;
                }
                textelement(EntryNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        EntryNo := GLEntry.FieldCaption("Entry No.");
                    End;
                }
                textelement(DocumentType)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        DocumentType := GLEntry.FieldCaption("Document Type");
                    End;
                }
                textelement(DocumentNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        DocumentNo := GLEntry.FieldCaption("Document No.");
                    End;
                }
                textelement(Description2)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Description2 := GLEntry.FieldCaption("Description 2");
                    End;
                }
                textelement(Docdate)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Docdate := GLEntry.FieldCaption("Document Date");
                    End;
                }
                textelement(GLAccountNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GLAccountNo := GLEntry.FieldCaption("G/L Account No.");
                    End;
                }
                textelement(Description)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Description := GLEntry.FieldCaption("Description");
                    End;
                }
                textelement(GlobalDimension1Code)
                {

                    trigger OnBeforePassVariable()
                    Begin
                        GlobalDimension1Code := GLEntry.FieldCaption("Global Dimension 1 Code");
                    End;
                }
                textelement(GlobalDimension2Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GlobalDimension2Code := GLEntry.FieldCaption("Global Dimension 2 Code");
                    End;
                }
                textelement(SourceNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        SourceNo := GLEntry.FieldCaption("Source No.");
                    End;

                }
                textelement(GenPostingType)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GenPostingType := GLEntry.FieldCaption("Gen. Posting Type");
                    End;

                }
                textelement(GenBusPostingGroup)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GenBusPostingGroup := GLEntry.FieldCaption("Gen. Bus. Posting Group");
                    End;
                }
                textelement(GenProdPostingGroup)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        GenProdPostingGroup := GLEntry.FieldCaption("Gen. Prod. Posting Group");
                    End;
                }
                textelement(Amount)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        Amount := GLEntry.FieldCaption("Amount");
                    End;
                }
                textelement(DebitAmount)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        DebitAmount := GLEntry.FieldCaption("Debit Amount");
                    End;
                }
                textelement(CreditAmount)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        CreditAmount := GLEntry.FieldCaption("Credit Amount");
                    End;
                }
                textelement(BalAccountType)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        BalAccountType := GLEntry.FieldCaption("Bal. Account Type");
                    End;
                }
                textelement(BalAccountNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        BalAccountNo := GLEntry.FieldCaption("Bal. Account No.");
                    End;
                }
                textelement(SourceName)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        SourceName := GLEntry.FieldCaption("Source Name");
                    End;
                }

                textelement(ExternalDocumentNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ExternalDocumentNo := GLEntry.FieldCaption("External Document No.");
                    End;
                }


                trigger OnAfterGetRecord()
                Begin
                    IF NewSkipHeader then
                        currXMLport.skip();
                End;
            }
            tableelement(GLEntry; "G/L Entry")
            {
                RequestFilterFields = "Posting Date";

                fieldelement(PostingDate; GLEntry."Posting Date")
                {
                }
                fieldelement(EntryNo; GLEntry."Entry No.")
                {
                }
                fieldelement(DocumentType; GLEntry."Document Type")
                {
                }
                fieldelement(DocumentNo; GLEntry."Document No.")
                {
                }
                fieldelement(Description2; GLEntry."Description 2")
                {
                }
                fieldelement(GLAccountNo; GLEntry."G/L Account No.")
                {
                }
                fieldelement(Description; GLEntry.Description)
                {
                }
                fieldelement(GlobalDimension1Code; GLEntry."Global Dimension 1 Code")
                {
                }
                fieldelement(GlobalDimension2Code; GLEntry."Global Dimension 2 Code")
                {
                }
                fieldelement(SourceNo; GLEntry."Source No.")
                {
                }

                fieldelement(GenPostingType; GLEntry."Gen. Posting Type")
                {
                }
                fieldelement(GenBusPostingGroup; GLEntry."Gen. Bus. Posting Group")
                {
                }
                fieldelement(GenProdPostingGroup; GLEntry."Gen. Prod. Posting Group")
                {
                }
                fieldelement(Amount; GLEntry.Amount)
                {
                }
                fieldelement(DebitAmount; GLEntry."Debit Amount")
                {
                }
                fieldelement(CreditAmount; GLEntry."Credit Amount")
                {
                }
                fieldelement(BalAccountType; GLEntry."Bal. Account Type")
                {
                }
                fieldelement(BalAccountNo; GLEntry."Bal. Account No.")
                {
                }
                fieldelement(SourceName; GLEntry."Source Name")
                {
                }

                fieldelement(ExternalDocumentNo; GLEntry."External Document No.")
                {
                }


                trigger OnPreXmlItem()
                Begin
                    GLEntry.SetRange("Posting Date", NewFromDate, NewToDate);
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