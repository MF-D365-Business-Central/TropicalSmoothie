xmlport 60000 "General Ledger Export"
{
    Direction = Export;
    Format = VariableText;
    FileName = 'General Ledger Export.csv';
    schema
    {
        textelement(NodeName1)
        {
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