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
    begin

        SalesImport.Reset();
        SalesImport.SetRange(Status, SalesImport.Status::New);
        IF SalesImport.FindSet(true) then
            repeat
                LineNo := 10000;
                SalesHeader := SalesImport.CreateSalesHeader();
                SalesImport.CreateSalesLine(LineNo, SalesHeader);
                SalesImport.Status := SalesImport.Status::Created;
                SalesImport."Invoice No." := SalesHeader."No.";
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
        SalesImport.SetCurrentKey("Invoice No.");
        SalesImport.SetRange(Status, SalesImport.Status::Created);
        IF SalesImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> SalesImport."Invoice No." then Begin
                    PrevDocumentNo := SalesImport."Invoice No.";
                    Posted := false;
                    ClearLastError();
                    SalesHeader.SetRange("Document Type", SalesImport."Document Type");
                    SalesHeader.SetRange("No.", SalesImport."Invoice No.");
                    IF SalesHeader.FindFirst() then;
                    UpdateComments(SalesHeader);
                    Commit();
                    PostOneDocument(SalesHeader, Posted);
                    UpdateComments(SalesHeader, GetLastErrorText());
                    IF Posted then
                        UpdatePosted(SalesHeader);
                End;

                // IF Posted then Begin
                //     SalesImport.Status := SalesImport.Status::Posted;
                //     SalesImport.Modify();
                //     Commit();
                // End;
                Commit();
            Until SalesImport.Next() = 0;

        DeletePosted();
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure PostOneDocument(SalesHeader: Record "Sales Header"; Var Posted: Boolean)

    begin
        Posted := false;
        IF Codeunit.Run(Codeunit::"Sales-Post", SalesHeader) then
            Posted := True;

    end;

    local procedure UpdateComments(SalesHeader: Record "Sales Header"; ErrorText: Text)
    var
        SalesImport2: Record "MFCC01 Sales Import";
    begin
        SalesImport2.Reset();
        SalesImport2.SetCurrentKey("Invoice No.");
        SalesImport2.SetRange(Status, SalesImport.Status::Created);
        SalesImport2.SetRange("Invoice No.", SalesHeader."No.");
        IF SalesImport2.FindSet() then
            SalesImport2.ModifyAll(Remarks, CopyStr(ErrorText, 1, 500));
    end;


    local procedure UpdatePosted(SalesHeader: Record "Sales Header")
    var
        SalesImport2: Record "MFCC01 Sales Import";
    begin
        SalesImport2.Reset();
        SalesImport2.SetCurrentKey("Invoice No.");
        SalesImport2.SetRange(Status, SalesImport.Status::Created);
        SalesImport2.SetRange("Invoice No.", SalesHeader."No.");
        IF SalesImport2.FindSet() then
            SalesImport2.ModifyAll(Status, SalesImport2.Status::Posted);
    end;

    local procedure UpdateComments(SalesHeader: Record "Sales Header")
    var
        SalesImport2: Record "MFCC01 Sales Import";
    begin
        SalesImport2.Reset();
        SalesImport2.SetCurrentKey("Invoice No.");
        SalesImport2.SetRange(Status, SalesImport.Status::Created);
        SalesImport2.SetRange("Invoice No.", SalesHeader."No.");
        IF SalesImport2.FindSet() then
            SalesImport2.ModifyAll(Remarks, '');
    end;

    local procedure DeletePosted()
    var
        SalesImport2: Record "MFCC01 Sales Import";
    begin
        SalesImport2.Reset();
        SalesImport2.SetCurrentKey("Invoice No.");
        SalesImport2.SetRange(Status, SalesImport.Status::Posted);
        SalesImport2.DeleteAll();
    end;
}