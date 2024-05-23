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
        GlobalFranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry";
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
        NoSeriesLineResult: Record "No. Series Line";
    begin
        CheckLines(FranchiseJnlLine);
        FindNextEntries();
        GLEntry.LockTable();
        IF GLEntry.FindLast() then;
        NoSeriesMgt.FindNoSeriesLine(NoSeriesLineResult, FranchiseBatch."No. Series", WorkDate());
        NoSeriesLineResult.FindFirst();
        LastDocNo := NoSeriesMgt.GetNextNo(FranchiseBatch."No. Series", WorkDate(), false);
        IF FranchiseJnlLine.FindSet(True) then
            repeat
                //FranchiseJnlLine.CheckDocNoBasedOnNoSeries(LastDocNo, FranchiseBatch."No. Series", NoSeriesMgt);
                //IF not FranchiseJnlLine.EmptyLine() then
                //LastDocNo := FranchiseJnlLine."Document No.";
                LastDocNo := IncStr(LastDocNo);
                FranchiseJnlLine."Document No." := LastDocNo;
                InsertFranchhiseLedgerEntry(FranchiseJnlLine);
                Prepareposting();
            Until FranchiseJnlLine.Next() = 0;
        NoSeriesLineResult."Last Date Used" := WorkDate();
        NoSeriesLineResult."Last No. Used" := LastDocNo;
        NoSeriesLineResult.Modify();
        FranchiseJnlLine.DeleteAll();


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

    local procedure FindNextEntries()
    var
        FranchiseLedgerEntry: Record "MFCC01 FranchiseLedgerEntry";
    begin
        IF FranchiseLedgerEntry.FindLast() then;
        NextEntryNo := FranchiseLedgerEntry."Entry No." + 1;
    end;

    local procedure InsertFranchhiseLedgerEntry(FranchiseJnlLine: Record "MFCC01 Franchise Journal"): Integer
    var
        DimMgmt: Codeunit DimensionManagement;
    begin
        GlobalFranchiseLedgerEntry.Init();
        GlobalFranchiseLedgerEntry.TransferFields(FranchiseJnlLine);
        GlobalFranchiseLedgerEntry."Entry No." := NextEntryNo;
        DimMgmt.UpdateGlobalDimFromDimSetID(GlobalFranchiseLedgerEntry."Dimension Set ID",
        GlobalFranchiseLedgerEntry."Shortcut Dimension 1 Code", GlobalFranchiseLedgerEntry."Shortcut Dimension 2 Code");
        GlobalFranchiseLedgerEntry.Insert(True);

        NextEntryNo += 1;
        exit(GlobalFranchiseLedgerEntry."Entry No.");
    end;

    local procedure Prepareposting()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        AccountType: Enum "Gen. Journal Account Type";
        BalanceAmount: Decimal;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        Customer: Record Customer;

    begin
        Clear(DefaultDimSource);
        AgreementHeader.Get(GlobalFranchiseLedgerEntry."Agreement ID");
        Customer.Get(AgreementHeader."Customer No.");
        IF GlobalFranchiseLedgerEntry."Royalty Fee" <> 0 then Begin
            InitJpurnalLine(
            AccountType::"G/L Account", CZSetup."Royalty Account", Sign() * GlobalFranchiseLedgerEntry."Royalty Fee");
            GenJnlLine."Dimension Set ID" := GlobalFranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, GlobalFranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."Royalty Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
            GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := GlobalFranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := GlobalFranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount := Sign() * GlobalFranchiseLedgerEntry."Royalty Fee";
        End;
        Clear(DefaultDimSource);
        IF GlobalFranchiseLedgerEntry."Local Fee" <> 0 then Begin
            InitJpurnalLine(
            AccountType::"G/L Account", CZSetup."Local Account", Sign() * GlobalFranchiseLedgerEntry."Local Fee");
            GenJnlLine."Dimension Set ID" := GlobalFranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, GlobalFranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."Local Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
                GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."Local Department Code");
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := GlobalFranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := GlobalFranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount += Sign() * GlobalFranchiseLedgerEntry."Local Fee";
        End;
        Clear(DefaultDimSource);
        IF GlobalFranchiseLedgerEntry."National Fee" <> 0 then Begin
            InitJpurnalLine(
            AccountType::"G/L Account", CZSetup."National Account", Sign() * GlobalFranchiseLedgerEntry."National Fee");
            GenJnlLine."Dimension Set ID" := GlobalFranchiseLedgerEntry."Dimension Set ID";
            InitDefaultDimSource(DefaultDimSource, GlobalFranchiseLedgerEntry."Customer No.");
            InitDefaultDimSourceGL(DefaultDimSource, CZSetup."National Account");
            GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
                GenJnlLine."Dimension Set ID", 0);
            GenJnlLine.Validate("Shortcut Dimension 1 Code", CZSetup."National Department Code");
            GenJnlLine.Validate("Shortcut Dimension 2 Code", Customer."Global Dimension 2 Code");
            GenJnlLine."Agreement No." := GlobalFranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := GlobalFranchiseLedgerEntry.Description;
            PostJournal();
            BalanceAmount += Sign() * GlobalFranchiseLedgerEntry."National Fee";
        End;

        IF BalanceAmount <> 0 then Begin
            InitJpurnalLine(AccountType::Customer, GlobalFranchiseLedgerEntry."Customer No.",
              Sign() * BalanceAmount);
            GenJnlLine."Recipient Bank Account" := AgreementHeader."Royalty Bank Account";
            GenJnlLine."Agreement No." := GlobalFranchiseLedgerEntry."Agreement ID";
            GenJnlLine.Description := GlobalFranchiseLedgerEntry.Description;
            PostJournal();
        End;
    end;

    local procedure Sign(): Integer
    begin
        Case GlobalFranchiseLedgerEntry."Document Type" of
            GlobalFranchiseLedgerEntry."Document Type"::Invoice:
                Exit(-1);
            GlobalFranchiseLedgerEntry."Document Type"::"Credit Memo":
                Exit(1);
        End;
    end;

    local procedure InitJpurnalLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
      Amount: Decimal
     )
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := GlobalFranchiseLedgerEntry."Posting Date";
        GenJnlLine."Document Date" := GlobalFranchiseLedgerEntry."Document Date";
        Case GlobalFranchiseLedgerEntry."Document Type" of
            GlobalFranchiseLedgerEntry."Document Type"::Invoice:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
            GlobalFranchiseLedgerEntry."Document Type"::"Credit Memo":
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
        End;
        GenJnlLine."Document No." := GlobalFranchiseLedgerEntry."Document No.";
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