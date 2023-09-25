codeunit 60003 "MFCC01 Sales Import"
{
    trigger OnRun()
    begin

    end;

    var
        SalesImport: Record "MFCC01 Sales Import";

    procedure GenerateInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
        PrevDocumentNo: Code[20];
    begin
        LineNo := 10000;
        SalesImport.Reset();
        SalesImport.SetCurrentKey("Document No.");
        SalesImport.SetRange(Status, SalesImport.Status::New);
        IF SalesImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> SalesImport."Document No." then Begin
                    SalesHeader := SalesImport.CreateSalesHeader();
                    PrevDocumentNo := SalesImport."Document No.";
                End;

                SalesImport.CreateSalesLine(LineNo);
                SalesImport.Status := SalesImport.Status::Created;
                SalesImport.Modify();
            Until SalesImport.Next() = 0;
    end;

    procedure PostDocuments()
    var
        SalesHeader: Record "Sales Header";
        Posted: Boolean;
        PrevDocumentNo: Code[20];
    begin
        Posted := false;
        SalesImport.Reset();
        SalesImport.SetCurrentKey("Document No.");
        SalesImport.SetRange(Status, SalesImport.Status::Created);
        IF SalesImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> SalesImport."Document No." then Begin
                    Posted := false;
                    Commit();
                    SalesHeader.SetRange("Document Type", SalesImport."Document Type");
                    SalesHeader.SetRange("No.", SalesImport."Document No.");
                    IF SalesHeader.FindFirst() then;
                    PostOneDocument(SalesHeader, Posted);
                End;

                IF Posted then Begin
                    SalesImport.Status := SalesImport.Status::Posted;
                    SalesImport.Modify();
                End;
            Until SalesImport.Next() = 0;
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure PostOneDocument(SalesHeader: Record "Sales Header"; Var Posted: Boolean)

    begin
        IF Codeunit.Run(Codeunit::"Sales-Post", SalesHeader) then
            Posted := True;
    end;
}