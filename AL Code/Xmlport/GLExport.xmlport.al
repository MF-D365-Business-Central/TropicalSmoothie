xmlport 60000 "General Ledger Export"
{
    Direction = Export;
    Format = VariableText;
    FileName = 'General Ledger Export.csv';
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
                textelement(AgreementNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        AgreementNo := GLEntry.FieldCaption("Agreement No.");
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
                textelement(ShortcutDimension3Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ShortcutDimension3Code := GLEntry.FieldCaption("Shortcut Dimension 3 Code");
                    End;
                }
                textelement(ShortcutDimension4Code)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ShortcutDimension4Code := GLEntry.FieldCaption("Shortcut Dimension 4 Code");
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
                textelement(EntryNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        EntryNo := GLEntry.FieldCaption("Entry No.");
                    End;
                }
                textelement(ExternalDocumentNo)
                {
                    trigger OnBeforePassVariable()
                    Begin
                        ExternalDocumentNo := GLEntry.FieldCaption("External Document No.");
                    End;
                }
            }
            tableelement(GLEntry; "G/L Entry")
            {
                RequestFilterFields = "Posting Date";

                fieldelement(PostingDate; GLEntry."Posting Date")
                {
                }
                fieldelement(DocumentType; GLEntry."Document Type")
                {
                }
                fieldelement(DocumentNo; GLEntry."Document No.")
                {
                }
                fieldelement(AgreementNo; GLEntry."Agreement No.")
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
                fieldelement(ShortcutDimension3Code; GLEntry."Shortcut Dimension 3 Code")
                {
                }
                fieldelement(ShortcutDimension4Code; GLEntry."Shortcut Dimension 4 Code")
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
                fieldelement(EntryNo; GLEntry."Entry No.")
                {
                }
                fieldelement(ExternalDocumentNo; GLEntry."External Document No.")
                {
                }
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


}