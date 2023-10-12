codeunit 60005 "Event handler"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", OnAfterCopyGLEntryFromGenJnlLine, '', false, false)]
    local procedure OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Agreement No." := GenJournalLine."Agreement No.";
    end;


}