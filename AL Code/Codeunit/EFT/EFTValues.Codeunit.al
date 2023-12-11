Codeunit 60010 "MFCC01EFT Values"
{

    trigger OnRun()
    begin
    end;

    var
        BatchHashTotal: Decimal;
        TotalBatchDebit: Decimal;
        TotalBatchCredit: Decimal;
        FileHashTotal: Decimal;
        TotalFileDebit: Decimal;
        TotalFileCredit: Decimal;
        FileEntryAddendaCount: Integer;
        SequenceNumber: Integer;
        TraceNumber: Integer;
        BatchNumber: Integer;
        EntryAddendaCount: Integer;
        BatchCount: Integer;
        NoOfRecords: Integer;
        NumberOfCustInfoRec: Integer;
        Transactions: Integer;
        DataExchEntryNo: Integer;
        IsParent: Boolean;
        ParentDefCode: Code[20];
        EFTFileIsCreated: Boolean;
        IATFileIsCreated: Boolean;

    procedure GetSequenceNo() SequenceNo: Integer
    begin
        SequenceNo := SequenceNumber;
    end;

    procedure SetSequenceNo(SequenceNo: Integer)
    begin
        SequenceNumber := SequenceNo;
    end;

    procedure GetTraceNo() TraceNo: Integer
    begin
        TraceNo := TraceNumber;
    end;

    procedure SetTraceNo(TraceNo: Integer)
    begin
        TraceNumber := TraceNo;
    end;

    procedure GetFileHashTotal() FileHashTot: Decimal
    begin
        FileHashTot := FileHashTotal;
    end;

    procedure SetFileHashTotal(FileHashTot: Decimal)
    begin
        FileHashTotal := FileHashTot;
    end;

    procedure GetTotalFileDebit() TotalFileDr: Decimal
    begin
        TotalFileDr := TotalFileDebit;
    end;

    procedure SetTotalFileDebit(TotalFileDr: Decimal)
    begin
        TotalFileDebit := TotalFileDr;
    end;

    procedure GetTotalFileCredit() TotalFileCr: Decimal
    begin
        TotalFileCr := TotalFileCredit;
    end;

    procedure SetTotalFileCredit(TotalFileCr: Decimal)
    begin
        TotalFileCredit := TotalFileCr;
    end;

    procedure GetFileEntryAddendaCount() FileEntryAddendaCt: Integer
    begin
        FileEntryAddendaCt := FileEntryAddendaCount;
    end;

    procedure SetFileEntryAddendaCount(FileEntryAddendaCt: Integer)
    begin
        FileEntryAddendaCount := FileEntryAddendaCt;
    end;

    procedure GetBatchCount() BatchCt: Integer
    begin
        BatchCt := BatchCount;
    end;

    procedure SetBatchCount(BatchCt: Integer)
    begin
        BatchCount := BatchCt;
    end;

    procedure GetBatchNo() BatchNo: Integer
    begin
        BatchNo := BatchNumber;
    end;

    procedure SetBatchNo(BatchNo: Integer)
    begin
        BatchNumber := BatchNo;
    end;

    procedure GetBatchHashTotal() BatchHashTot: Decimal
    begin
        BatchHashTot := BatchHashTotal;
    end;

    procedure SetBatchHashTotal(BatchHashTot: Decimal)
    begin
        BatchHashTotal := BatchHashTot;
    end;

    procedure GetTotalBatchDebit() TotalBatchDr: Decimal
    begin
        TotalBatchDr := TotalBatchDebit;
    end;

    procedure SetTotalBatchDebit(TotalBatchDr: Decimal)
    begin
        TotalBatchDebit := TotalBatchDr;
    end;

    procedure GetTotalBatchCredit() TotalBatchCr: Decimal
    begin
        TotalBatchCr := TotalBatchCredit;
    end;

    procedure SetTotalBatchCredit(TotalBatchCr: Decimal)
    begin
        TotalBatchCredit := TotalBatchCr;
    end;

    procedure GetEntryAddendaCount() EntryAddendaCt: Integer
    begin
        EntryAddendaCt := EntryAddendaCount;
    end;

    procedure SetEntryAddendaCount(EntryAddendaCt: Integer)
    begin
        EntryAddendaCount := EntryAddendaCt;
    end;

    procedure GetNoOfRec() NoOfRec: Integer
    begin
        NoOfRec := NoOfRecords;
    end;

    procedure SetNoOfRec(NoOfRec: Integer)
    begin
        NoOfRecords := NoOfRec;
    end;

    procedure GetNoOfCustInfoRec() NoOfCustInfoRec: Integer
    begin
        NoOfCustInfoRec := NumberOfCustInfoRec;
    end;

    procedure SetNoOfCustInfoRec(NoOfCustInfoRec: Integer)
    begin
        NumberOfCustInfoRec := NoOfCustInfoRec;
    end;

    procedure GetTransactions() Trxs: Integer
    begin
        Trxs := Transactions;
    end;

    procedure SetTransactions(Trxs: Integer)
    begin
        Transactions := Trxs;
    end;

    procedure GetPaymentAmt(TempEFTExportWorkset: Record "EFT Export Workset" temporary): Decimal
    begin
        if TempEFTExportWorkset."Account Type" = TempEFTExportWorkset."account type"::"Bank Account" then
            exit(-TempEFTExportWorkset."Amount (LCY)");

        exit(TempEFTExportWorkset."Amount (LCY)");
    end;

    procedure GetDataExchEntryNo() DataExchEntryNumber: Integer
    begin
        DataExchEntryNumber := DataExchEntryNo;
    end;

    procedure SetDataExchEntryNo(DataExchEntryNumber: Integer)
    begin
        DataExchEntryNo := DataExchEntryNumber;
    end;

    procedure GetParentDefCode() ParentDefinitionCode: Code[20]
    begin
        ParentDefinitionCode := ParentDefCode;
    end;

    procedure SetParentDefCode(ParentDefinitionCode: Code[20])
    begin
        ParentDefCode := ParentDefinitionCode;
    end;

    procedure GetParentBoolean() IsAParent: Boolean
    begin
        IsAParent := IsParent;
    end;

    procedure SetParentBoolean(SetParent: Boolean)
    begin
        IsParent := SetParent;
    end;

    procedure GetIATFileCreated() IATIsCreated: Boolean
    begin
        IATIsCreated := IATFileIsCreated;
    end;

    procedure SetIATFileCreated(SetIATFile: Boolean)
    begin
        IATFileIsCreated := SetIATFile;
    end;

    procedure GetEFTFileCreated() EFTIsCreated: Boolean
    begin
        EFTIsCreated := EFTFileIsCreated;
    end;

    procedure SetEFTFileCreated(SetEFTFile: Boolean)
    begin
        EFTFileIsCreated := SetEFTFile;
    end;
}

