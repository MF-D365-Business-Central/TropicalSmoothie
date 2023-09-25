codeunit 60013 "MFCC01 FA Import"
{
    trigger OnRun()
    begin

    end;

    var
        FAImport: Record "MFCC01 FA Import";

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

        FAImport.SetRange(Status, FAImport.Status::New);
        FAImport.SetFilter(Category, '<>%1', '');
        IF FAImport.FindSet(true) then
            repeat
                FixedAsset.Init();
                FixedAsset."No." := '';
                FixedAsset.insert(true);
                FixedAsset.Description := FAImport.Description;
                FixedAsset.validate("FA Class Code", 'TANGIBLE');
                FixedAsset.validate("FA Subclass Code", 'EQUIPMENT');
                FixedAsset.Modify();
                FADespriciationBook.Init();
                FADespriciationBook."FA No." := FixedAsset."No.";
                FADespriciationBook.validate("Depreciation Book Code", 'COMPANY');
                FADespriciationBook.validate("Depreciation Starting Date", FAImport."In Service Date");
                FADespriciationBook.validate("No. of Depreciation Months", FAImport."Useful Life In Months");

                FADespriciationBook.Insert(true);

                FAImport.Status := FAImport.Status::Created;
                FAImport."FA No." := FixedAsset."No.";
                FAImport.Modify();
            Until FAImport.Next() = 0;
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
    begin
        FAImport.SetRange(Status, FAImport.Status::Created);
        FAImport.SetFilter(Category, '<>%1', '');
        IF FAImport.FindSet(true) then
            repeat
                FAGenJournalLine.Init();
                FAGenJournalLine."Journal Template Name" := FixedAssetAcquisitionWizard.SelectFATemplate();
                FAGenJournalLine."Journal Batch Name" := FixedAssetAcquisitionWizard.GetGenJournalBatchName(
                    CopyStr(FAImport.GetFilter("FA No."), 1, 20));


                FAGenJournalLine.Validate("Line No.", FAGenJournalLine.GetNewLineNo(FAGenJournalLine."Journal Template Name", FAGenJournalLine."Journal Batch Name"));
                FAGenJournalLine.Validate("Document No.", GenerateLineDocNo(FAGenJournalLine."Journal Batch Name", FAGenJournalLine."Posting Date", FAGenJournalLine."Journal Template Name"));
                FAGenJournalLine."Document Type" := FAGenJournalLine."Document Type"::Invoice;
                FAGenJournalLine.Validate("Account Type", FAGenJournalLine."Account Type"::"Fixed Asset");
                FAGenJournalLine.Validate("Account No.", FAImport."FA No.");
                FAGenJournalLine."FA Posting Type" := FAGenJournalLine."FA Posting Type"::"Acquisition Cost";
                FAGenJournalLine."Posting Date" := FAImport."In Service Date";
                FAGenJournalLine.Validate(Amount, FAImport."Accumulated Depreciation");

                FAGenJournalLine.Insert(true);

                // Creating Balancing Line
                BalancingGenJnlLine.Copy(FAGenJournalLine);
                BalancingGenJnlLine.Validate("Account Type", BalancingGenJnlLine."Bal. Account Type"::"G/L Account");
                BalancingGenJnlLine.Validate("Account No.", '');
                BalancingGenJnlLine.Validate(Amount, -FAImport."Accumulated Depreciation");
                FAGenJournalLine.Validate("Line No.", FAGenJournalLine.GetNewLineNo(FAGenJournalLine."Journal Template Name", FAGenJournalLine."Journal Batch Name"));
                BalancingGenJnlLine.Insert(true);

                FAGenJournalLine.TestField("Posting Group");

                // Inserting additional fields in Fixed Asset line required for acquisition
                if FAPostingGr.GetPostingGroup(FAGenJournalLine."Posting Group", FAGenJournalLine."Depreciation Book Code") then begin
                    LocalGLAcc.Get(FAPostingGr."Acquisition Cost Account");
                    LocalGLAcc.CheckGLAcc();
                    FAGenJournalLine.Validate("Gen. Posting Type", LocalGLAcc."Gen. Posting Type");
                    FAGenJournalLine.Validate("Gen. Bus. Posting Group", LocalGLAcc."Gen. Bus. Posting Group");
                    FAGenJournalLine.Validate("Gen. Prod. Posting Group", LocalGLAcc."Gen. Prod. Posting Group");
                    FAGenJournalLine.Validate("VAT Bus. Posting Group", LocalGLAcc."VAT Bus. Posting Group");
                    FAGenJournalLine.Validate("VAT Prod. Posting Group", LocalGLAcc."VAT Prod. Posting Group");
                    FAGenJournalLine.Validate("Tax Group Code", LocalGLAcc."Tax Group Code");
                    FAGenJournalLine.Validate("VAT Prod. Posting Group");
                    FAGenJournalLine.Modify(true)
                end;

                // Inserting Source Code
                if FAGenJournalLine."Source Code" = '' then begin
                    GenJnlTemplate.Get(FAGenJournalLine."Journal Template Name");
                    FAGenJournalLine.Validate("Source Code", GenJnlTemplate."Source Code");
                    FAGenJournalLine.Modify(true);
                    BalancingGenJnlLine.Validate("Source Code", GenJnlTemplate."Source Code");
                    BalancingGenJnlLine.Modify(true);
                end;

                IF CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", FAGenJournalLine) then Begin
                    FAImport.Status := FAImport.Status::Posted;
                    FAImport.Modify();
                End else begin
                    FAGenJournalLine.Reset();
                    FAGenJournalLine.Setrange("Journal Template Name", FixedAssetAcquisitionWizard.SelectFATemplate());
                    FAGenJournalLine.Setrange("Journal Batch Name", FixedAssetAcquisitionWizard.GetGenJournalBatchName(
                        CopyStr(FAImport.GetFilter("FA No."), 1, 20)));
                    FAGenJournalLine.DeleteAll();
                end;
            Until FAImport.Next() = 0;
    end;

    local procedure GenerateLineDocNo(BatchName: Code[10]; PostingDate: Date; TemplateName: Code[20]) DocumentNo: Code[20]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GenJournalBatch.Get(TemplateName, BatchName);
        if GenJournalBatch."No. Series" <> '' then
            DocumentNo := NoSeriesManagement.TryGetNextNo(GenJournalBatch."No. Series", PostingDate);
    end;


}