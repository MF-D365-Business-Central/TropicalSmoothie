codeunit 60001 "MFCC01 Franchise Jnl. Post"

{
    TableNo = "MFCC01 Franchise Journal";
    Permissions = TableData "G/L Entry" = r, tabledata "MFCC01 FranchiseLedgerEntry" = RIM;

    trigger OnRun()
    var
        FranchiseJnlLine: Record "MFCC01 Franchise Journal";
    begin
        FranchiseJnlLine.Copy(Rec);
        FranchiseJnlLine.SetAutoCalcFields();
        Code(FranchiseJnlLine);
        Rec := FranchiseJnlLine;
    end;

    var
        CZSetup: Record "MFCC01 Franchise Setup";
        NoSeriesLineResult: Record "No. Series Line";
        GenJnlLine: Record "Gen. Journal Line";
        FranchiseBatch: Record "MFCC01 Franchise Batch";
        TempNoSeries: Record "No. Series" temporary;
        GLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        LastDocNo: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        Text025: Label 'A maximum of %1 posting number series can be used in each journal.';
        Text001: Label 'is not within your range of allowed posting dates';

    local procedure Code(Var FranchiseJnlLine: Record "MFCC01 Franchise Journal")
    var

        FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry";
    begin
        CheckLines(FranchiseJnlLine);
        FindNextEntries();
        GLEntry.LockTable();
        IF GLEntry.FindLast() then;
        GetNoseriesLine();
        IF FranchiseJnlLine.FindSet(True) then
            repeat
                //FranchiseJnlLine.CheckDocNoBasedOnNoSeries(LastDocNo, FranchiseBatch."No. Series", NoSeriesMgt);
                //IF not FranchiseJnlLine.EmptyLine() then
                //LastDocNo := FranchiseJnlLine."Document No.";
                NoSeriesLineResult."Last No. Used" := LastDocNo;
                LastDocNo := IncStr(LastDocNo);
                FranchiseJnlLine."Document No." := LastDocNo;
                InsertFranchhiseLedgerEntry(FranchiseJnlLine, FranchiseLedgerEntry);
                Prepareposting(FranchiseLedgerEntry, false);
            Until FranchiseJnlLine.Next() = 0;
        UpdateLastnoused();
        FranchiseJnlLine.DeleteAll();

    end;


    procedure GetNoseriesLine()
    begin
        CZSetup.GetRecordonce();
        IF FranchiseBatch.Code = '' then
            FranchiseBatch.Get('DEFAULT');
        NoSeriesMgt.FindNoSeriesLine(NoSeriesLineResult, FranchiseBatch."No. Series", WorkDate());
        NoSeriesLineResult.FindFirst();
        LastDocNo := NoSeriesMgt.GetNextNo(FranchiseBatch."No. Series", WorkDate(), false);
    end;

    procedure UpdateLastnoused()
    begin
        NoSeriesLineResult."Last Date Used" := WorkDate();
        NoSeriesLineResult.Validate("Last No. Used");
        NoSeriesLineResult.Modify();
    end;

    procedure UpdateCurrentNo()
    begin
        NoSeriesLineResult."Last No. Used" := LastDocNo;
    end;

    local procedure CheckLines(Var FranchiseJnlLine: Record "MFCC01 Franchise Journal")
    var
        CheckFranchiseJnlLine: Record "MFCC01 Franchise Journal";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        CZSetup.GetRecordonce();
        FranchiseBatch.Get(FranchiseJnlLine."Batch Name");
        CZSetup.TestField("Royalty Account");
        CZSetup.TestField("Local Account");
        CZSetup.TestField("National Account");
        CZSetup.TestField("Local Department Code");
        CZSetup.TestField("National Department Code");

        CheckFranchiseJnlLine.Copy(FranchiseJnlLine);
        IF CheckFranchiseJnlLine.FindSet() then
            repeat
                if GenJnlCheckLine.DateNotAllowed(CheckFranchiseJnlLine."Posting Date") then
                    CheckFranchiseJnlLine.FieldError("Posting Date", Text001);
            until CheckFranchiseJnlLine.Next() = 0;
    end;


    local procedure ShouldSetDocNoToLastPosted(var FranchiseJnlLine: Record "MFCC01 Franchise Journal") Result: Boolean
    begin
        Result := FranchiseJnlLine."Document No." = LastDocNo;
        OnAfterShouldSetDocNoToLastPosted(FranchiseJnlLine, LastDocNo, Result);
    end;

    procedure FindNextEntries()
    var
        FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry";
    begin
        IF FranchiseLedgerEntry.FindLast() then;
        NextEntryNo := FranchiseLedgerEntry."Entry No." + 1;
    end;

    local procedure InsertFranchhiseLedgerEntry(FranchiseJnlLine: Record "MFCC01 Franchise Journal"; Var FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"): Integer
    var
        DimMgmt: Codeunit DimensionManagement;
    begin
        FranchiseLedgerEntry.Init();
        FranchiseLedgerEntry.TransferFields(FranchiseJnlLine);
        FranchiseLedgerEntry."Entry No." := NextEntryNo;
        DimMgmt.UpdateGlobalDimFromDimSetID(FranchiseLedgerEntry."Dimension Set ID",
        FranchiseLedgerEntry."Shortcut Dimension 1 Code", FranchiseLedgerEntry."Shortcut Dimension 2 Code");
        FranchiseLedgerEntry.Insert(True);

        NextEntryNo += 1;
        exit(FranchiseLedgerEntry."Entry No.");
    end;


    procedure InsertCancelFranchhiseLedgerEntry(var FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"; Var NewFranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"): Integer
    var
        DimMgmt: Codeunit DimensionManagement;
    begin
        NewFranchiseLedgerEntry.Init();
        NewFranchiseLedgerEntry.TransferFields(FranchiseLedgerEntry);
        NewFranchiseLedgerEntry."Entry No." := NextEntryNo;

        IF FranchiseLedgerEntry."Document Type" = FranchiseLedgerEntry."Document Type"::Invoice then
            NewFranchiseLedgerEntry."Document Type" := NewFranchiseLedgerEntry."Document Type"::"Credit Memo";

        IF FranchiseLedgerEntry."Document Type" = FranchiseLedgerEntry."Document Type"::"Credit Memo" then
            NewFranchiseLedgerEntry."Document Type" := NewFranchiseLedgerEntry."Document Type"::Invoice;


        NewFranchiseLedgerEntry."Document No." := LastDocNo;
        NewFranchiseLedgerEntry."Posting Date" := WorkDate();
        NewFranchiseLedgerEntry."Applies Document No." := FranchiseLedgerEntry."Document No.";
        NoSeriesLineResult."Last No. Used" := LastDocNo;
        LastDocNo := IncStr(LastDocNo);

        NewFranchiseLedgerEntry.Canceled := true;
        NewFranchiseLedgerEntry.Insert(True);

        FranchiseLedgerEntry.Canceled := true;
        FranchiseLedgerEntry.Modify();

        NextEntryNo += 1;
        exit(FranchiseLedgerEntry."Entry No.");
    end;

    procedure Prepareposting(FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"; Cancel: Boolean)
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        AccountType: Enum "Gen. Journal Account Type";
        BalanceAmount: Decimal;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        Customer: Record Customer;

    begin
        Clear(DefaultDimSource);
        AgreementHeader.Get(FranchiseLedgerEntry."Agreement ID");
        Customer.Get(AgreementHeader."Customer No.");
        IF FranchiseLedgerEntry."Royalty Fee" <> 0 then Begin
            InitJpurnalLine(FranchiseLedgerEntry,
            AccountType::"G/L Account", CZSetup."Royalty Account", Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."Royalty Fee");
            GenJnlLine."Dimension Set ID" := FranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, FranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."Royalty Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
            GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := FranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := FranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount := Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."Royalty Fee";
        End;
        Clear(DefaultDimSource);
        IF FranchiseLedgerEntry."Local Fee" <> 0 then Begin
            InitJpurnalLine(FranchiseLedgerEntry,
            AccountType::"G/L Account", CZSetup."Local Account", Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."Local Fee");
            GenJnlLine."Dimension Set ID" := FranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, FranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."Local Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
                GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Local Department Code");
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := FranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := FranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount += Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."Local Fee";
        End;
        Clear(DefaultDimSource);
        IF FranchiseLedgerEntry."National Fee" <> 0 then Begin
            InitJpurnalLine(FranchiseLedgerEntry,
            AccountType::"G/L Account", CZSetup."National Account", Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."National Fee");
            GenJnlLine."Dimension Set ID" := FranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, FranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."National Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
                GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."National Department Code");
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := FranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := FranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount += Sign(FranchiseLedgerEntry) * FranchiseLedgerEntry."National Fee";
        End;

        IF BalanceAmount <> 0 then Begin
            IF Not Cancel then
                InitJpurnalLine(FranchiseLedgerEntry, AccountType::Customer, FranchiseLedgerEntry."Customer No.",
                  Sign(FranchiseLedgerEntry) * BalanceAmount)
            else
                InitJpurnalLine(FranchiseLedgerEntry, AccountType::Customer, FranchiseLedgerEntry."Customer No.",
                     CancelSign(FranchiseLedgerEntry) * BalanceAmount);

            GenJnlLine."Recipient Bank Account" := AgreementHeader."Royalty Bank Account";
            GenJnlLine."Agreement No." := FranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := FranchiseLedgerEntry.Description;
            IF Cancel then Begin
                IF FranchiseLedgerEntry."Document Type" = FranchiseLedgerEntry."Document Type"::Invoice then
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                IF FranchiseLedgerEntry."Document Type" = FranchiseLedgerEntry."Document Type"::"Credit Memo" then
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                GenJnlLine."Applies-to Doc. No." := FranchiseLedgerEntry."Applies Document No.";
                //GenJnlLine.Modify();
            End;
            PostJournal();
        End;
    end;

    local procedure Sign(FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"): Integer
    begin
        Case FranchiseLedgerEntry."Document Type" of
            FranchiseLedgerEntry."Document Type"::Invoice:
                Exit(-1);
            FranchiseLedgerEntry."Document Type"::"Credit Memo":
                Exit(1);
        End;


    end;

    local procedure CancelSign(FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"): Integer
    begin
        Case FranchiseLedgerEntry."Document Type" of
            FranchiseLedgerEntry."Document Type"::Invoice:
                Exit(1);
            FranchiseLedgerEntry."Document Type"::"Credit Memo":
                Exit(-1);
        End;


    end;

    local procedure InitJpurnalLine(FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
      Amount: Decimal
     )
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := FranchiseLedgerEntry."Posting Date";
        GenJnlLine."Document Date" := FranchiseLedgerEntry."Document Date";
        Case FranchiseLedgerEntry."Document Type" of
            FranchiseLedgerEntry."Document Type"::Invoice:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
            FranchiseLedgerEntry."Document Type"::"Credit Memo":
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
        End;
        GenJnlLine."Document No." := FranchiseLedgerEntry."Document No.";
        GenJnlLine.Validate("Account Type", AccountType);
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine."Sales/Purch. (LCY)" := GenJnlLine."Amount (LCY)";
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; Accountno: Code[20])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::Customer, Accountno);
    end;

    local procedure InitDefaultDimSourceGL(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; GLAccountno: Code[20])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"G/L Account", GLAccountno);
    end;

    procedure PostJournal()
    begin
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckDocumentNo(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; LastDocNo: code[20]; LastPostedDocNo: code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShouldSetDocNoToLastPosted(varFranchiseJnlLine: Record "MFCC01 Franchise Journal"; LastDocNo: Code[20]; var Result: Boolean)
    begin
    end;
}