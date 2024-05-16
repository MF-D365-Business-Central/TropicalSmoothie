tableextension 60013 "CH01StatisticalAccJournalBatch" extends "Statistical Acc. Journal Batch"
{
    fields
    {
        // Add changes to table fields here

    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure GetBalance(): Decimal
    var
        StatJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        StatJournalLine.SetRange("Journal Batch Name", Name);
        StatJournalLine.SetRange(Amount, 0);
        exit(StatJournalLine.Count);
    end;

    procedure CheckBalance() Balance: Decimal
    begin
        Balance := GetBalance();

        if Balance = 0 then
            OnStatJournalBatchBalanced()
        else
            OnStatJournalBatchNotBalanced();
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnStatJournalBatchBalanced()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnStatJournalBatchNotBalanced()
    begin
    end;
}