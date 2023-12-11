report 60002 "Suggest Customer Collections"
{
    Caption = 'Suggest Customer Collections';
    ProcessingOnly = true;
    Permissions = tabledata "Cust. Ledger Entry" = RM;
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING(Blocked) WHERE(Blocked = FILTER(= " "));
            RequestFilterFields = "No.", "Payment Method Code", "Customer Posting Group";


            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = field("No.");
                DataItemTableView = where(Open = const(True), "Document Type" = const(Invoice), "Applies-to ID" = const(''));
                CalcFields = "Remaining Amount";
                trigger OnPreDataItem()
                begin
                    LineCreated := false;
                    // IF "Cust. Ledger Entry".GetFilter("Document Type") = '' then Begin
                    //     "Cust. Ledger Entry".SetFilter("Document Type", '%1|%2', "Cust. Ledger Entry"."Document Type"::Invoice,
                    //     "Cust. Ledger Entry"."Document Type"::"Credit Memo");
                    // End
                end;

                trigger OnAfterGetRecord()
                Begin


                    Case SummarizePerCust OF

                        True:
                            begin

                                IF not LineCreated then Begin
                                    CreateJournalLine(false);
                                    LineCreated := true;
                                End;
                                "Cust. Ledger Entry"."Amount to Apply" := "Cust. Ledger Entry"."Remaining Amount";
                                "Cust. Ledger Entry"."Applies-to ID" := GenJnlLine."Document No.";
                                "Cust. Ledger Entry".Modify();
                                GenJnlLine."Applies-to ID" := GenJnlLine."Document No.";
                                GenJnlLine.Validate(Amount, GenJnlLine.Amount - "Cust. Ledger Entry"."Amount to Apply");
                                GenJnlLine.Modify();
                            end;
                        false:
                            CreateJournalLine(true);
                    End;
                End;
            }

            trigger OnAfterGetRecord()
            Begin

                Clear(CustomerBalance);
                CalcFields("Balance (LCY)");
                CustomerBalance := "Balance (LCY)";

                //Window.Update(1, "No.");
                // if Not IncludeCustomer(Customer, CustomerBalance) then
                //     CurrReport.Skip();

            End;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(SummarizePerCustomer; SummarizePerCust)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Summarize per Customer';
                        ToolTip = 'Specifies if you want the batch job to make one line per Customer for each currency in which the vendor has ledger entries. If, for example, a vendor uses two currencies, the batch job will create two lines in the payment journal for this vendor. If you are using Remit Addresses the batch job will create a line for each remit address. The batch job then uses the Applies-to ID field when the journal lines are posted to apply the lines to vendor ledger entries. If you do not select this check box, then the batch job will make one line per invoice.';

                        // trigger OnValidate()
                        // begin
                        //     if SummarizePerVend and UseDueDateAsPostingDate then
                        //         Error(PmtDiscUnavailableErr);
                        // end;
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        Importance = Promoted;
                        ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate();
                        end;
                    }
                    field(StartingDocumentNo; NextDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Document No.';
                        ToolTip = 'Specifies the next available number in the number series for the journal batch that is linked to the payment journal. When you run the batch job, this is the document number that appears on the first payment journal line. You can also fill in this field manually.';

                        trigger OnValidate()
                        begin
                            if NextDocNo <> '' then
                                if IncStr(NextDocNo) = '' then
                                    Error(StartingDocumentNoErr);
                        end;
                    }
                    field(NewDocNoPerLine; DocNoPerLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Doc. No. per Line';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the batch job to fill in the payment journal lines with consecutive document numbers, starting with the document number specified in the Starting Document No. field.';

                        // trigger OnValidate()
                        // begin
                        //     if not UsePriority and (AmountAvailable <> 0) then
                        //         Error(Text013);
                        // end;
                    }
                    field(BalAccountType; GenJnlLine2."Bal. Account Type")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bal. Account Type';
                        Importance = Additional;
                        ToolTip = 'Specifies the balancing account type that payments on the payment journal are posted to.';

                        trigger OnValidate()
                        begin
                            if not (GenJnlLine2."Bal. Account Type" in
                                [GenJnlLine2."Bal. Account Type"::"Bank Account", GenJnlLine2."Bal. Account Type"::"G/L Account"])
                            then
                                error(
                                    BalAccountTypeErr,
                                    GenJnlLine2."Bal. Account Type"::"Bank Account", GenJnlLine2."Bal. Account Type"::"G/L Account");
                            GenJnlLine2."Bal. Account No." := '';
                        end;
                    }
                    field(BalAccountNo; GenJnlLine2."Bal. Account No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bal. Account No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the balancing account number that payments on the payment journal are posted to.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            case GenJnlLine2."Bal. Account Type" of
                                GenJnlLine2."Bal. Account Type"::"G/L Account":
                                    if PAGE.RunModal(0, GLAcc) = ACTION::LookupOK then
                                        GenJnlLine2."Bal. Account No." := GLAcc."No.";
                                GenJnlLine2."Bal. Account Type"::Customer, GenJnlLine2."Bal. Account Type"::Vendor:
                                    Error(Text009, GenJnlLine2.FieldCaption("Bal. Account Type"));
                                GenJnlLine2."Bal. Account Type"::"Bank Account":
                                    if PAGE.RunModal(0, BankAcc) = ACTION::LookupOK then
                                        GenJnlLine2."Bal. Account No." := BankAcc."No.";
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if GenJnlLine2."Bal. Account No." <> '' then
                                case GenJnlLine2."Bal. Account Type" of
                                    GenJnlLine2."Bal. Account Type"::"G/L Account":
                                        GLAcc.Get(GenJnlLine2."Bal. Account No.");
                                    GenJnlLine2."Bal. Account Type"::Customer, GenJnlLine2."Bal. Account Type"::Vendor:
                                        Error(Text009, GenJnlLine2.FieldCaption("Bal. Account Type"));
                                    GenJnlLine2."Bal. Account Type"::"Bank Account":
                                        BankAcc.Get(GenJnlLine2."Bal. Account No.");
                                end;
                        end;
                    }
                    field(ClearingAccount; ClearingAccount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Clearing Account';
                        TableRelation = "G/L Account" where(Blocked = const(false), "Direct Posting" = const(true));
                    }
                    field(BankPaymentType; GenJnlLine2."Bank Payment Type")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Payment Type';
                        Importance = Additional;
                        ToolTip = 'Specifies the check type to be used, if you use Bank Account as the balancing account type.';
                        //Enabled = false;
                        trigger OnValidate()
                        begin
                            if (GenJnlLine2."Bal. Account Type" <> GenJnlLine2."Bal. Account Type"::"Bank Account") and
                               (GenJnlLine2."Bank Payment Type".AsInteger() > 0)
                            then
                                Error(
                                  Text010,
                                  GenJnlLine2.FieldCaption("Bank Payment Type"),
                                  GenJnlLine2.FieldCaption("Bal. Account Type"));
                        end;
                    }
                }
            }
        }

        actions
        {
        }


    }

    labels
    {
    }

    trigger OnPostReport()
    Begin
        CreateBalJournalLine();
    End;

    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GLAcc: Record "G/L Account";
        BankAcc: Record "Bank Account";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NextDocNo: Code[20];
        PostingDate: Date;
        SummarizePerCust: Boolean;
        DocNoPerLine: Boolean;
        CustomerBalance: Decimal;
        LineCreated: Boolean;
        NextLine: Integer;
        Window: Dialog;
        BalancingAmt: Decimal;
        ClearingAccount: Code[20];
        StartingDocumentNoErr: Label 'The value in the Starting Document No. field must have a number so that we can assign the next number in the series.';
        Text009: Label '%1 must be G/L Account or Bank Account.';
        Text010: Label '%1 must be filled only when %2 is Bank Account.';
        BalAccountTypeErr: label 'Balancing account must be %1 or %2.';

    procedure SetGenJnlLine(NewGenJnlLine: Record "Gen. Journal Line")
    begin

        GenJnlLine := NewGenJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
        if GenJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;

    end;

    trigger OnPreReport()
    Begin
        GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
        GenJnlLine.Init();
        GenJnlLine.setrange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.setrange("Journal Batch Name", GenJnlBatch.Name);
        IF GenJnlLine.FindLast() then;
        NextLine := GenJnlLine."Line No." + 10000;
    End;

    procedure InitializeRequest(LastPmtDate: Date; FindPmtDisc: Boolean; NewAvailableAmount: Decimal; NewSkipExportedPayments: Boolean; NewPostingDate: Date; NewStartDocNo: Code[20]; NewSummarizePerCust: Boolean; BalAccType: Enum "Gen. Journal Account Type"; BalAccNo: Code[20]; BankPmtType: Enum "Bank Payment Type")
    begin
        // LastDueDateToPayReq := LastPmtDate;
        // UsePaymentDisc := FindPmtDisc;
        // AmountAvailable := NewAvailableAmount;
        // SkipExportedPayments := NewSkipExportedPayments;
        PostingDate := NewPostingDate;
        NextDocNo := NewStartDocNo;
        SummarizePerCust := NewSummarizePerCust;
        GenJnlLine2."Bal. Account Type" := BalAccType;
        GenJnlLine2."Bal. Account No." := BalAccNo;
        GenJnlLine2."Bank Payment Type" := BankPmtType;
    end;

    local procedure IncludeCustomer(Customer: Record Customer; CustomerBalance: Decimal) Result: Boolean
    begin
        Result := CustomerBalance > 0;

        OnAfterIncludeCustomer(Customer, CustomerBalance, Result);
    end;

    local procedure CreateJournalLine(OnLine: Boolean)
    begin
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;

        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document No." := NextDocNo;
        GenJnlLine."Line No." := NextLine;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", Customer."No.");
        GenJnlLine.Description := "Cust. Ledger Entry".Description;
        GenJnlLine."Bal. Account Type" := GenJnlLine2."Bal. Account Type";
        GenJnlLine.Validate("Bal. Account No.", GenJnlLine2."Bal. Account No.");

        GenJnlLine.Validate("Bank Payment Type", GenJnlLine2."Bank Payment Type");

        IF OnLine then begin
            GenJnlLine.Validate("Applies-to Doc. Type", "Cust. Ledger Entry"."Document Type");
            GenJnlLine.Validate("Applies-to Doc. No.", "Cust. Ledger Entry"."Document No.");
            GenJnlLine.Validate(Amount, -"Cust. Ledger Entry"."Remaining Amount");
        end;
        IF DocNoPerLine then
            NextDocNo := IncStr(NextDocNo);

        NextLine += 10000;
        GenJnlLine."Recipient Bank Account" := "Cust. Ledger Entry"."Recipient Bank Account";
        GenJnlLine.Insert(true);
        BalancingAmt += GenJnlLine.Amount;
    end;

    local procedure CreateBalJournalLine()
    begin
        IF BalancingAmt = 0 then
            Exit;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document No." := NextDocNo;
        GenJnlLine."Line No." := NextLine;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
        GenJnlLine.Validate("Account No.", GenJnlLine2."Bal. Account No.");
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate(Amount, Abs(BalancingAmt));
        GenJnlLine.Validate("Bal. Account No.", ClearingAccount);
        GenJnlLine.Validate("Bank Payment Type", GenJnlLine2."Bank Payment Type");
        NextLine += 10000;
        GenJnlLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIncludeCustomer(Customer: Record Customer; CustomerBalance: Decimal; var Result: Boolean)
    begin
    end;
}