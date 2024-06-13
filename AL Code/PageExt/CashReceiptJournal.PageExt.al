pageextension 60002 "MFCC01 Cash Receipt Journal" extends "Cash Receipt Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Recipient Bank Account"; Rec."Recipient Bank Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.';
            }

            // field("Agreement No."; Rec."Agreement No.")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the value of the Agreement No. field.';
            // }
        }
        addafter("Bal. Account No.")
        {
            field("Bank Payment Type"; Rec."Bank Payment Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
            }
            field("Check Exported"; Rec."Check Exported")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Check Exported field.';
            }
        }
        addafter(IncomingDocAttachFactBox)
        {
            part("Payment File Errors"; "Payment Journal Errors Part")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment File Errors';
                SubPageLink = "Journal Template Name" = field("Journal Template Name"),
                              "Journal Batch Name" = field("Journal Batch Name"),
                              "Journal Line No." = field("Line No.");
            }
        }
        modify(Control1900383207)
        {
            Visible = True;
        }
        modify(Control1905767507)
        {
            Visible = true;
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Apply Entries")
        {
            action(SuggestCollection)
            {
                ApplicationArea = All;
                Caption = 'Suggest Customer Collections';
                Promoted = true;
                PromotedCategory = Process;
                Image = Suggest;

                trigger OnAction()
                var
                    SuggestCustomerCollections: Report "Suggest Customer Collections";
                begin
                    Clear(SuggestCustomerCollections);
                    SuggestCustomerCollections.SetGenJnlLine(Rec);
                    SuggestCustomerCollections.RunModal();
                end;
            }
            action(SuggestRefund)
            {
                ApplicationArea = All;
                Caption = 'Suggest Customer Refunds';
                Promoted = true;
                PromotedCategory = Process;
                Image = Suggest;

                trigger OnAction()
                var
                    SuggestCustomerRefunds: Report "Suggest Customer Refunds";
                begin
                    Clear(SuggestCustomerRefunds);
                    SuggestCustomerRefunds.SetGenJnlLine(Rec);
                    SuggestCustomerRefunds.RunModal();
                end;
            }
        }
        addafter("F&unctions")
        {
            action(ExportPaymentsToFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'E&xport';
                Ellipsis = true;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Export a file with the payment information on the journal lines.';

                trigger OnAction()
                var
                    BankExportImportSetup: Record "Bank Export/Import Setup";
                    BankAccount: Record "Bank Account";
                    CompanyInformation: Record "Company Information";
                    GenJournalBatch: Record "Gen. Journal Batch";
                    // Bulkvend: Codeunit "Bulk Vendor Remit Reporting";
                    BulkVendorRemitReporting: Codeunit "Bulk Customer Remit Reporting";//"Bulk Vendor Remit Reporting";
                    PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
                    GenJnlLineRecordRef: RecordRef;
                    Window: Dialog;
                    ExportNewLines: Boolean;
                begin
                    Rec.TestField("Document No.");
                    Rec.CheckIfPrivacyBlocked();

                    Window.Open(GeneratingRcptMsgLbl);
                    GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
                    BankAccount.Get(GenJournalBatch."Bal. Account No.");

                    if (BankAccount."Export Format" = 0) or (BankAccount."Export Format" = BankAccount."Export Format"::Other) then begin
                        // Export Format is either empty or 'OTHER'
                        GenJnlLine.CopyFilters(Rec);
                        GenJnlLine.FindFirst();
                        GenJnlLine.ExportPaymentFile();
                    end else begin
                        CompanyInformation.Get();
                        CompanyInformation.TestField("Federal ID No.");
                        GenJnlLine.Reset();
                        GenJnlLine.Copy(Rec);
                        GenJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");

                        if GenJnlLine.FindFirst() then
                            repeat
                                GenJnlLine.DeletePaymentFileErrors();
                                if GenJnlLine."Currency Code" <> BankAccount."Currency Code" then
                                    GenJnlLine.InsertPaymentFileError(NoExportDiffCurrencyErrLbl);
                                if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Bank Account") or
                                    (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Bank Account")) and
                                   ((GenJnlLine."Bank Payment Type" <> GenJnlLine."Bank Payment Type"::"Electronic Payment") and
                                    (GenJnlLine."Bank Payment Type" <> GenJnlLine."Bank Payment Type"::"Electronic Payment-IAT"))
                                then
                                    GenJnlLine.InsertPaymentFileError(StrSubstNo(WrongBankPaymentTypeErrLbl, Rec.FieldCaption("Bank Payment Type"),
                                        Rec."Bank Payment Type"::"Electronic Payment", Rec."Bank Payment Type"::"Electronic Payment-IAT"));

                                if not GenJournalBatch."Allow Cash Receipt" then
                                    PaymentExportGenJnlCheck.AddBatchEmptyError(GenJnlLine, GenJournalBatch.FieldCaption("Allow Cash Receipt"), '');
                                // if GenJnlLine.Amount < 0 then
                                //    GenJnlLine.InsertPaymentFileError(NoExportNegativeErrlBL);
                                if GenJnlLine."Recipient Bank Account" = '' then
                                    GenJnlLine.InsertPaymentFileError(RecipientBankAccountEmptyErrLbl)
                                else
                                    if not UseForElecPaymentChecked(GenJnlLine) then
                                        GenJnlLine.InsertPaymentFileError(UseForElecPaymentCheckedErrLbl);
                            until GenJnlLine.Next() = 0;

                        if BankAccount."Last Remittance Advice No." = '' then
                            Rec.InsertPaymentFileError(LastRemittanceErrLbl);

                        if GenJnlLine.HasPaymentFileErrorsInBatch() then begin
                            Commit();
                            Error(HasErrorsErrLbl);
                        end;

                        if Rec."Bank Payment Type" = Rec."Bank Payment Type"::"Electronic Payment" then
                            BankExportImportSetup.Get(BankAccount."Receivables Export Format")
                        else
                            if Rec."Bank Payment Type" = Rec."Bank Payment Type"::"Electronic Payment-IAT" then
                                BankExportImportSetup.Get(BankAccount."EFT Export Code Format");

                        if GenJnlLine.FindFirst() then
                            repeat
                                ExportNewLines := ProcessLine(GenJnlLine);
                            until (ExportNewLines = true) or (GenJnlLine.Next() = 0);

                        if ExportNewLines then begin
                            GenJnlLineRecordRef.GetTable(GenJnlLine);
                            GenJnlLineRecordRef.SetView(GenJnlLine.GetView());
                            BulkVendorRemitReporting.RunWithRecord(GenJnlLine)
                        end;
                    end;

                    Window.Close();
                end;
            }
            action("Void")
            {
                ApplicationArea = all;
                Image = VoidAllChecks;
                ToolTip = 'Void Checks';
                trigger OnAction()
                var
                    bankaccount: Record "Bank Account";
                    VoidTransmitElecPayments: Report "Void/Transmit Elec. Pay";
                begin
                    IF Rec."Account Type" = Rec."Account Type"::"Bank Account" THEN
                        BankAccount.GET(Rec."Account No.");
                    IF Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" THEN
                        BankAccount.GET(Rec."Bal. Account No.");
                    IF (BankAccount."Export Format" = 0) OR (BankAccount."Export Format" = BankAccount."Export Format"::Other) THEN BEGIN
                        GenJnlLine.COPYFILTERS(Rec);

                        IF NOT EntriesToVoid(GenJnlLine, TRUE) THEN
                            ERROR(NoEntriesToVoidErrLbl);
                        IF GenJnlLine.FINDFIRST() THEN
                            GenJnlLine.VoidPaymentFile();
                    END ELSE BEGIN
                        GenJnlLine.RESET();
                        GenJnlLine := Rec;
                        GenJnlLine.SETRANGE("Journal Template Name", Rec."Journal Template Name");
                        GenJnlLine.SETRANGE("Journal Batch Name", Rec."Journal Batch Name");

                        IF NOT EntriesToVoid(GenJnlLine, FALSE) THEN
                            ERROR(NoEntriesToVoidErrLbl);
                        CLEAR(VoidTransmitElecPayments);
                        VoidTransmitElecPayments.SetUsageType(1);   // Void
                        VoidTransmitElecPayments.SETTABLEVIEW(GenJnlLine);
                        IF Rec."Account Type" = Rec."Account Type"::"Bank Account" THEN
                            VoidTransmitElecPayments.SetBankAccountNo(Rec."Account No.")
                        ELSE
                            IF Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" THEN
                                VoidTransmitElecPayments.SetBankAccountNo(Rec."Bal. Account No.");
                        VoidTransmitElecPayments.RUNMODAL();
                    END;
                end;
            }
            action(TransmitPayments)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Transmit';
                Ellipsis = true;
                Enabled = AMCFormat;
                Image = TransmitElectronicDoc;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Transmit the exported electronic payment file to the bank.';

                trigger OnAction()
                var
                    BankAccount: Record "Bank Account";
                begin
                    if Rec."Account Type" = Rec."Account Type"::"Bank Account" then
                        BankAccount.Get(Rec."Account No.");
                    if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
                        BankAccount.Get(Rec."Bal. Account No.");
                    if (BankAccount."Export Format" = 0) or (BankAccount."Export Format" = BankAccount."Export Format"::Other) then begin
                        GenJnlLine.CopyFilters(Rec);
                        if GenJnlLine.FindFirst() then
                            GenJnlLine.TransmitPaymentFile();
                    end;
                end;
            }
            action(GenerateEFT)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Generate EFT File';
                Enabled = NOT (AMCFormat = TRUE);
                Image = ExportFile;
                ToolTip = 'Generate a file based on the exported payment journal lines. A window showing the file content opens from where you complete the electronic funds transfer.';

                trigger OnAction()
                var
                    GenJournalBatch: Record "Gen. Journal Batch";
                    GenerateEFTFiles: Page "MFC01Generate EFT Files";
                begin
                    GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name");

                    GenerateEFTFiles.SetBalanceAccount(GenJournalBatch."Bal. Account No.", Rec."Journal Batch Name");
                    GenerateEFTFiles.Run();
                end;
            }
        }
    }

    procedure UseForElecPaymentChecked(Var GenJnlLine3: Record "Gen. Journal Line"): Boolean
    var
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        IF GenJnlLine3."Bal. Account Type" <> GenJnlLine3."Bal. Account Type"::"Bank Account" THEN
            CASE GenJnlLine3."Bal. Account Type" OF
                GenJnlLine3."Bal. Account Type"::Vendor:
                    BEGIN
                        VendorBankAccount.SETRANGE("Vendor No.", GenJnlLine3."Bal. Account No.");
                        VendorBankAccount.SETRANGE(Code, GenJnlLine3."Recipient Bank Account");
                        IF VendorBankAccount.FINDFIRST() THEN
                            EXIT(VendorBankAccount."Use for Electronic Payments")
                    END;
                GenJnlLine3."Bal. Account Type"::Customer:
                    BEGIn
                        CustomerBankAccount.SETRANGE("Customer No.", GenJnlLine3."Bal. Account No.");
                        CustomerBankAccount.SETRANGE(Code, GenJnlLine3."Recipient Bank Account");
                        IF CustomerBankAccount.FINDFIRST() THEN
                            EXIT(CustomerBankAccount."Use for Electronic Payments");
                    END ELSE
                            EXIT(TRUE)
            end;

        IF GenJnlLine3."Account Type" <> GenJnlLine3."Account Type"::"Bank Account" THEN
            CASE GenJnlLine3."Account Type" OF
                GenJnlLine3."Account Type"::Vendor:
                    BEGIN
                        VendorBankAccount.SETRANGE("Vendor No.", GenJnlLine3."Account No.");
                        VendorBankAccount.SETRANGE(Code, GenJnlLine3."Recipient Bank Account");
                        IF VendorBankAccount.FINDFIRST() THEN
                            EXIT(VendorBankAccount."Use for Electronic Payments");
                    END;
                GenJnlLine3."Account Type"::Customer:
                    BEGIN
                        CustomerBankAccount.SETRANGE("Customer No.", GenJnlLine3."Account No.");
                        CustomerBankAccount.SETRANGE(Code, GenJnlLine3."Recipient Bank Account");
                        IF CustomerBankAccount.FINDFIRST() THEN
                            EXIT(CustomerBankAccount."Use for Electronic Payments");
                    END ELSE
                            EXIT(TRUE);
            end;
    end;

    PROCEDURE ProcessLine(VAR GenJournalLine: Record "Gen. Journal Line"): Boolean
    BEGIN
        ExportNewLines := FALSE;
        IF GenJournalLine."Amount (LCY)" <> 0 THEN
            IF ((GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment") OR
                (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment-IAT")) and (GenJournalLine."Check Exported" = FALSE)
            THEN
                ExportNewLines := TRUE;

        EXIT(ExportNewLines);
    END;

    LOCAL procedure EntriesToVoid(GenJnlLine3: Record "Gen. Journal Line"; AMC: Boolean): Boolean
    begin
        GenJnlLine3.SETFILTER("Document Type", 'Payment|Refund');
        GenJnlLine3.SETFILTER("Bank Payment Type", 'Electronic Payment|Electronic Payment-IAT');
        IF AMC THEN
            GenJnlLine3.SETRANGE("Exported to Payment File", TRUE)
        ELSE BEGIN
            GenJnlLine3.SETRANGE("Check Printed", TRUE);
            GenJnlLine3.SETRANGE("Check Exported", TRUE);
        END;
        // GenJnlLine3.SETRANGE("Check Transmitted", FALSE);
        EXIT(GenJnlLine3.FINDFIRST());
    end;

    local procedure SetAMCAppearance()
    var
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        AMCFormat := false;
        if GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name") then
            if BankAccount.Get(GenJournalBatch."Bal. Account No.") then
                if GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account" then
                    if (BankAccount."Export Format" = 0) or (BankAccount."Export Format" = BankAccount."Export Format"::Other) then
                        AMCFormat := true;
    end;

    procedure checkEFTBankaccount(Genjourntemp: Code[10]; Genjournbatch: Code[10]): Boolean;
    var
        GenJournalbatch: Record "Gen. Journal Batch";
    begin
        if GenJournalbatch.get(Genjourntemp, Genjournbatch) then
            if GenJournalbatch."Allow Cash Receipt" then
                exit(true)
            else
                exit(false);
    end;

    var
        GenJnlLine: Record "Gen. Journal Line";
        ExportNewLines: Boolean;
        AMCFormat: Boolean;
        NoEntriesToVoidErrLbl: Label 'There are no entries to void.';
        GeneratingRcptMsgLbl: Label 'Generating Receipt file...';
        NoExportDiffCurrencyErrLbl: Label 'You cannot export journal entries if Currency Code is different in Gen. Journal Line and Bank Account.';
        WrongBankPaymentTypeErrLbl: Label '%1 type must be either %2 or %3.', Comment = '%1 = Bank Payment Type Caption; %2 = Bank Payment Type; %3 = Bank Payment Type';
        // NoExportNegativeErrLbl: Label 'You cannot export journal entries with negative amounts.';
        RecipientBankAccountEmptyErrLbl: Label 'Recipient Bank Account must be filled.';
        LastRemittanceErrLbl: Label 'Last Remittance Advice No. must have a value in the bank account.';
        UseForElecPaymentCheckedErrLbl: Label 'The Use for Electronic Payments check box must be selected on the vendor or customer bank account card.';
        HasErrorsErrLbl: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';
}