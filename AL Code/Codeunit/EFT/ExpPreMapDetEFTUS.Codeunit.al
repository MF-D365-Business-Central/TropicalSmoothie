codeunit 60014 "MFCC01Exp. Pre-Map Det EFT US"
{
    Permissions = TableData "EFT Export" = rimd;
    TableNo = "EFT Export Workset";

    trigger OnRun()
    begin
    end;


    procedure PrepareEFTDetails(var TempEFTExportWorkset: Record "EFT Export Workset" temporary; DataExchangeEntryNo: Integer; LineNo: Integer; var DetailArray: array[100] of Integer; var ExportEFTACH: Codeunit "MFCC01Export EFT (ACH)"; var ExportEFTIAT: Codeunit "MFCC01Export EFT (IAT)"; DataExchLineDefCode: Code[20]; var EFTValues: Codeunit "MFCC01EFT Values")
    var
        BankAccount: Record "Bank Account";
        GenerateEFT: Codeunit "MFCC01Generate EFT";
        DetailCount: Integer;
    begin
        DetailCount := 0;
        DetailCount := DetailCount + 1;
        DetailArray[DetailCount] := DataExchangeEntryNo;
        LineNo += 1;
        PrepareEFTDetail(DataExchangeEntryNo, TempEFTExportWorkset."Bank Account No.", DataExchLineDefCode);
        BankAccount.Get(TempEFTExportWorkset."Bank Account No.");
        if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment"
        then begin
            EFTValues.SetNoOfRec(EFTValues.GetNoOfRec() + 1);
            ExportEFTACH.ExportElectronicPayment(
              TempEFTExportWorkset, EFTValues.GetPaymentAmt(TempEFTExportWorkset),
              DataExchangeEntryNo, DataExchLineDefCode)
        end else
            if TempEFTExportWorkset."Bank Payment Type" = TempEFTExportWorkset."Bank Payment Type"::"Electronic Payment-IAT" then
                ExportEFTIAT.ExportElectronicPayment(
                  TempEFTExportWorkset, EFTValues.GetPaymentAmt(TempEFTExportWorkset),
                  DataExchangeEntryNo, DataExchLineDefCode, EFTValues);
        GenerateEFT.UpdateEFTExport(TempEFTExportWorkset);
        DataExchangeEntryNo := DataExchangeEntryNo + 1;
    end;

    local procedure PrepareEFTDetail(DataExchangeEntryNo: Integer; BankAccountFromExport: Code[20]; DataExchLineDefCode: Code[20])
    var
        BankAccount: Record "Bank Account";
        ACHUSDetail: Record "ACH US Detail";
    begin
        BankAccount.Get(BankAccountFromExport);

        ACHUSDetail.Init();
        ACHUSDetail."Data Exch. Entry No." := DataExchangeEntryNo;
        ACHUSDetail."Payee Bank Account Number" := BankAccount."Bank Account No.";
        ACHUSDetail."Data Exch. Line Def Code" := DataExchLineDefCode;
        ACHUSDetail.Insert(true);
    end;
}

