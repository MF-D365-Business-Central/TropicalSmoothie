codeunit 60013 "MFCC01 FA Import"
{
    trigger OnRun()
    begin

    end;

    var
        FAImport: Record "MFCC01 FA Import";
        Text006: label 'Processing Entry...\\';
        Window: Dialog;

    procedure CreateAsset()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
        PrevDocumentNo: Code[20];
        FixedAsset: Record "Fixed Asset";
        FADespriciationBook: Record "FA Depreciation Book";
    begin
        LineNo := 10000;
        FAImport.Reset();
        Window.Open(Text006 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        FAImport.SetRange(Status, FAImport.Status::New);
        FAImport.SetFilter(Category, '<>%1', '');
        FAImport.SetFilter("Starting Date", '<>%1', 0D);
        IF FAImport.FindSet(true) then
            repeat
                Window.Update(1, FAImport."Entry No.");
                FixedAsset.Init();
                FixedAsset."No." := '';
                FixedAsset.insert(true);
                FixedAsset.Description := CopyStr(FAImport.Description, 1, 100);
                FixedAsset.validate("FA Class Code", FAImport."FA Class Code");
                FixedAsset.validate("FA Subclass Code", FAImport."FA SubClass Code");
                FixedAsset.Modify();
                FADespriciationBook.Init();
                FADespriciationBook."FA No." := FixedAsset."No.";
                FADespriciationBook.validate("Depreciation Book Code", 'COMPANY');
                FADespriciationBook.validate("Depreciation Starting Date", FAImport."Starting Date");
                FADespriciationBook.validate("No. of Depreciation Months", FAImport."Useful Life In Months");
                FADespriciationBook.Validate("FA Posting Group", FAImport."FA Posting Group");
                FADespriciationBook.Insert(true);

                FAImport.Status := FAImport.Status::Created;
                FAImport."FA No." := FixedAsset."No.";
                FAImport.Modify();
            Until FAImport.Next() = 0;
        Window.Close();
    end;

    procedure PostbookValue()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        FAGenJournalLine: Record "Gen. Journal Line";
        BalancingGenJnlLine: Record "Gen. Journal Line";
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
        FAImport: Record "MFCC01 FA Import";
        GenJnlTemplate: Record "Gen. Journal Template";
        FixedAssetAcquisitionWizard: Codeunit "Fixed Asset Acquisition Wizard";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post line";
    begin
        Window.Open(Text006 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        FAImport.SetRange(Status, FAImport.Status::Created);
        FAImport.SetFilter(Category, '<>%1', '');
        FAImport.SetFilter("Book Value", '<>%1', 0);
        IF FAImport.FindSet(true) then
            repeat
                Window.Update(1, FAImport."Entry No.");
                FAGenJournalLine.Init();
                FAGenJournalLine."Journal Template Name" := FixedAssetAcquisitionWizard.SelectFATemplate();
                FAGenJournalLine."Journal Batch Name" := FixedAssetAcquisitionWizard.GetGenJournalBatchName(
                    CopyStr(FAImport.GetFilter("FA No."), 1, 20));

                FAGenJournalLine.Validate("Line No.", FAGenJournalLine.GetNewLineNo(FAGenJournalLine."Journal Template Name", FAGenJournalLine."Journal Batch Name"));
                FAGenJournalLine.Validate("Document No.", GenerateLineDocNo(FAGenJournalLine."Journal Batch Name", FAGenJournalLine."Posting Date", FAGenJournalLine."Journal Template Name"));
                FAGenJournalLine."Document Type" := FAGenJournalLine."Document Type"::Invoice;
                FAGenJournalLine.Validate("Account Type", FAGenJournalLine."Account Type"::"Fixed Asset");
                FAGenJournalLine.Validate("Account No.", FAImport."FA No.");
                FAGenJournalLine.Validate("FA Posting Type", FAGenJournalLine."FA Posting Type"::"Acquisition Cost");
                FAGenJournalLine."Posting Date" := FAImport."Starting Date";
                FAGenJournalLine.Validate(Amount, FAImport."Book Value");
                FAPostingGr.GetPostingGroup(FAGenJournalLine."Posting Group", FAGenJournalLine."Depreciation Book Code");
                FAGenJournalLine.Validate("Bal. Account Type", FAGenJournalLine."Bal. Account Type"::"G/L Account");
                FAGenJournalLine.Validate("Bal. Account No.", FAPostingGr."Acquisition Cost Account");

                IF GenJnlPostLine.RunWithCheck(FAGenJournalLine) <> 0 then
                    IF PostDepriciationValue(FAImport) then begin
                        FAImport.Status := FAImport.Status::Posted;
                        FAImport.Modify();
                    End;
            Until FAImport.Next() = 0;
        Window.Close();
    end;


    procedure PostbookValue(FAImport: Record "MFCC01 FA Import")
    var
        FAGenJournalLine: Record "Gen. Journal Line";
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
        GenJnlTemplate: Record "Gen. Journal Template";
        FixedAssetAcquisitionWizard: Codeunit "Fixed Asset Acquisition Wizard";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post line";
    begin

        FAGenJournalLine.Init();
        FAGenJournalLine."Journal Template Name" := FixedAssetAcquisitionWizard.SelectFATemplate();
        FAGenJournalLine."Journal Batch Name" := FixedAssetAcquisitionWizard.GetGenJournalBatchName(
            CopyStr(FAImport.GetFilter("FA No."), 1, 20));

        FAGenJournalLine.Validate("Line No.", FAGenJournalLine.GetNewLineNo(FAGenJournalLine."Journal Template Name", FAGenJournalLine."Journal Batch Name"));
        FAGenJournalLine.Validate("Document No.", GenerateLineDocNo(FAGenJournalLine."Journal Batch Name", FAGenJournalLine."Posting Date", FAGenJournalLine."Journal Template Name"));
        FAGenJournalLine."Document Type" := FAGenJournalLine."Document Type"::Invoice;
        FAGenJournalLine.Validate("Account Type", FAGenJournalLine."Account Type"::"Fixed Asset");
        FAGenJournalLine.Validate("Account No.", FAImport."FA No.");
        FAGenJournalLine.Validate("FA Posting Type", FAGenJournalLine."FA Posting Type"::"Acquisition Cost");
        FAGenJournalLine."Posting Date" := FAImport."Starting Date";
        FAGenJournalLine.Validate(Amount, FAImport."Book Value");
        FAPostingGr.GetPostingGroup(FAGenJournalLine."Posting Group", FAGenJournalLine."Depreciation Book Code");
        FAGenJournalLine.Validate("Bal. Account Type", FAGenJournalLine."Bal. Account Type"::"G/L Account");
        FAGenJournalLine.Validate("Bal. Account No.", FAPostingGr."Acquisition Cost Account");

        IF GenJnlPostLine.RunWithCheck(FAGenJournalLine) <> 0 then
            IF PostDepriciationValue(FAImport) then begin
                FAImport.Status := FAImport.Status::Posted;
                FAImport.Modify();
            End;

    end;


    procedure PostDepriciationValue(FAImport: Record "MFCC01 FA Import"): Boolean
    var
        FAGenJournalLine: Record "Gen. Journal Line";
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
        GenJnlTemplate: Record "Gen. Journal Template";
        FixedAssetAcquisitionWizard: Codeunit "Fixed Asset Acquisition Wizard";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post line";
    begin

        FAGenJournalLine.Init();
        FAGenJournalLine."Journal Template Name" := FixedAssetAcquisitionWizard.SelectFATemplate();
        FAGenJournalLine."Journal Batch Name" := FixedAssetAcquisitionWizard.GetGenJournalBatchName(
            CopyStr(FAImport.GetFilter("FA No."), 1, 20));

        FAGenJournalLine.Validate("Line No.", FAGenJournalLine.GetNewLineNo(FAGenJournalLine."Journal Template Name", FAGenJournalLine."Journal Batch Name"));
        FAGenJournalLine.Validate("Document No.", GenerateLineDocNo(FAGenJournalLine."Journal Batch Name", FAGenJournalLine."Posting Date", FAGenJournalLine."Journal Template Name"));
        FAGenJournalLine."Document Type" := FAGenJournalLine."Document Type"::Invoice;
        FAGenJournalLine.Validate("Account Type", FAGenJournalLine."Account Type"::"Fixed Asset");
        FAGenJournalLine.Validate("Account No.", FAImport."FA No.");
        FAGenJournalLine.Validate("FA Posting Type", FAGenJournalLine."FA Posting Type"::Depreciation);
        FAGenJournalLine."Posting Date" := FAImport."Starting Date";
        FAGenJournalLine.Validate(Amount, -FAImport."Accumulated Depreciation");
        FAPostingGr.GetPostingGroup(FAGenJournalLine."Posting Group", FAGenJournalLine."Depreciation Book Code");
        FAGenJournalLine.Validate("Bal. Account Type", FAGenJournalLine."Bal. Account Type"::"G/L Account");
        FAGenJournalLine.Validate("Bal. Account No.", FAPostingGr."Acquisition Cost Account");

        Exit(GenJnlPostLine.RunWithCheck(FAGenJournalLine) <> 0);

    end;

    local procedure GenerateLineDocNo(BatchName: Code[10]; PostingDate: Date; TemplateName: Code[20]) DocumentNo: Code[20]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GenJournalBatch.Get(TemplateName, BatchName);
        if GenJournalBatch."No. Series" <> '' then
            DocumentNo := NoSeriesManagement.GetNextNo(GenJournalBatch."No. Series", PostingDate, true);
    end;


}