report 60011 "Void/Transmit Elec. Pay"
{
    Caption = 'Void/Transmit Electronic Payments';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Gen. Journal Line"; "Gen. Journal Line")
        {
            DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.") WHERE("Document Type" = FILTER(Payment | Refund), "Bank Payment Type" = FILTER("Electronic Payment" | "Electronic Payment-IAT"), "Check Printed" = CONST(true), "Check Exported" = CONST(true));

            trigger OnAfterGetRecord()
            begin
                if "Account Type" = "Account Type"::"Bank Account" then begin
                    if "Account No." <> BankAccount."No." then
                        CurrReport.Skip();
                end else
                    if "Bal. Account Type" = "Bal. Account Type"::"Bank Account" then begin
                        if "Bal. Account No." <> BankAccount."No." then
                            CurrReport.Skip();
                    end else
                        CurrReport.Skip();

                if FirstTime then begin
                    case UsageType of
                        UsageType::Void:
                            begin
                                if "Check Transmitted" then;
                                //Error(Text001);
                            end;
                        UsageType::Transmit:
                            begin
                                if not RTCConfirmTransmit() then
                                    exit;
                                if "Check Transmitted" then
                                    Error(ExpTransmitLbl);
                            end;
                    end;
                    FirstTime := false;
                end;
                CheckManagement.ProcessElectronicPayment("Gen. Journal Line", UsageType);

                if UsageType = UsageType::Void then begin
                    "Check Exported" := false;
                    "Check Printed" := false;
                    "Document No." := '';
                    CleanEFTExportTable("Gen. Journal Line");
                end else
                    "Check Transmitted" := true;

                Modify();
            end;

            trigger OnPreDataItem()
            begin
                FirstTime := true;
            end;
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
                    field("BankAccount.""No."""; BankAccount."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Account No.';
                        TableRelation = "Bank Account";
                        ToolTip = 'Specifies the bank account that the payment is transmitted to.';
                    }
                    field(DisplayUsageType; DisplayUsageType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'E-Pay Operation';
                        Editable = false;
                        OptionCaption = ',Void,Transmit';
                        ToolTip = 'Specifies if you want to transmit or void the electronic payment file. The Transmit option produces an electronic payment file to be transmitted to your bank for processing. The Void option voids the exported file. Confirm that the correct selection has been made before you process the electronic payment file.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            DisplayUsageType := UsageType;
            if DisplayUsageType = 0 then
                Error(PaymentJnlProcessLbl);
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField(Blocked, false);
        BankAccount.TestField("Currency Code", '');  // local currency only
        BankAccount.TestField("Export Format");

        if UsageType <> UsageType::Transmit then
            if not Confirm(ElectronicPaymentsQst,
                 false,
                 UsageType,
                 BankAccount.TableCaption,
                 BankAccount."No.")
            then
                CurrReport.Quit();
    end;

    var
        BankAccount: Record "Bank Account";
        CheckManagement: Codeunit CheckManagement;
        FirstTime: Boolean;
        UsageType: Option ,Void,Transmit;
        DisplayUsageType: Option ,Void,Transmit;
        ElectronicPaymentsQst: Label 'Are you SURE you want to %1 all of the Electronic Payments written against %2 %3?', Comment = '%1 = Usage Type; %2 = Bank Account; %3 = Bank Account No.';
        // Text001: Label 'The export file has already been transmitted. You can no longer void these entries.';
        ExpTransmitLbl: Label 'The export file has already been transmitted.';
        PaymentJnlProcessLbl: Label 'This process can only be run from the Payment Journal';
        ExportTransmittedQst: Label 'Has export file been successfully transmitted?';

    procedure SetUsageType(NewUsageType: Option ,Void,Transmit)
    begin
        UsageType := NewUsageType;
    end;

    procedure RTCConfirmTransmit(): Boolean
    begin
        if not Confirm(ExportTransmittedQst, false) then
            exit(false);

        exit(true);
    end;

    procedure SetBankAccountNo(AccountNumber: Code[20])
    begin
        BankAccount.Get(AccountNumber);
    end;

    local procedure CleanEFTExportTable(var GenJournalLine: Record "Gen. Journal Line")
    var
        EFTExport: Record "EFT Export";
    begin
        EFTExport.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        EFTExport.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        EFTExport.SetRange("Line No.", GenJournalLine."Line No.");
        if EFTExport.FindLast() then
            EFTExport.Delete();
    end;
}
