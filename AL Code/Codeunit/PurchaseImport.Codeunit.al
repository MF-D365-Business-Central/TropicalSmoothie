codeunit 60004 "MFCC01 Purchase Import"
{
    trigger OnRun()
    begin

    end;

    var
        PurchaseImport: Record "MFCC01 Purchase Import";

    procedure GenerateInvoice()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        PrevDocumentNo: Code[20];
    begin
        LineNo := 10000;
        PurchaseImport.Reset();
        PurchaseImport.SetCurrentKey("Document No.");
        PurchaseImport.SetRange(Status, PurchaseImport.Status::New);
        IF PurchaseImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> PurchaseImport."Document No." then Begin
                    PurchHeader := PurchaseImport.CreatePurchHeader();
                    PrevDocumentNo := PurchaseImport."Document No.";
                End;

                PurchaseImport.CreatePurchLine(LineNo);
                PurchaseImport.Status := PurchaseImport.Status::Created;
                PurchaseImport.Modify();
            Until PurchaseImport.Next() = 0;
    end;

    procedure PostDocuments()
    var
        PurchHeader: Record "Purchase Header";
        Posted: Boolean;
        PrevDocumentNo: Code[20];
    begin
        Posted := false;
        PurchaseImport.Reset();
        PurchaseImport.SetCurrentKey("Document No.");
        PurchaseImport.SetRange(Status, PurchaseImport.Status::Created);
        IF PurchaseImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> PurchaseImport."Document No." then Begin
                    Posted := false;
                    Commit();
                    PurchHeader.SetRange("Document Type", PurchaseImport."Document Type");
                    PurchHeader.SetRange("No.", PurchaseImport."Document No.");
                    IF PurchHeader.FindFirst() then;
                    PostOneDocument(PurchHeader, Posted);
                End;

                IF Posted then Begin
                    PurchaseImport.Status := PurchaseImport.Status::Posted;
                    PurchaseImport.Modify();
                End;
            Until PurchaseImport.Next() = 0;
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure PostOneDocument(PurchHeader: Record "Purchase Header"; Var Posted: Boolean)

    begin
        IF Codeunit.Run(Codeunit::"Purch.-Post", PurchHeader) then
            Posted := True;
    end;
}