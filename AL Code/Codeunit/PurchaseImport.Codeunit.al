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
        PurchaseImport.SetCurrentKey("Vendor No.", "External Document No.");
        PurchaseImport.SetRange(Status, PurchaseImport.Status::New);
        IF PurchaseImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> (PurchaseImport."External Document No." + PurchaseImport."Vendor No.") then Begin
                    PurchHeader := PurchaseImport.CreatePurchHeader();
                    PrevDocumentNo := PurchaseImport."External Document No." + PurchaseImport."Vendor No.";
                End;

                PurchaseImport.CreatePurchLine(LineNo, PurchHeader);
                PurchaseImport."Invoice No." := PurchHeader."No.";
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
        PurchaseImport.SetCurrentKey("Invoice No.");
        PurchaseImport.SetRange(Status, PurchaseImport.Status::Created);
        IF PurchaseImport.FindSet(true) then
            repeat
                IF PrevDocumentNo <> PurchaseImport."Invoice No." then Begin
                    Posted := false;
                    PrevDocumentNo := PurchaseImport."Invoice No.";
                    PurchHeader.SetRange("Document Type", PurchaseImport."Document Type");
                    PurchHeader.SetRange("No.", PurchaseImport."Invoice No.");
                    IF PurchHeader.FindFirst() then;
                    UpdateComments(PurchHeader);
                    Commit();
                    PostOneDocument(PurchHeader, Posted);
                    UpdateComments(PurchHeader, GetLastErrorText());
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


    local procedure UpdateComments(PurchHeader: Record "Purchase Header"; ErrorText: Text)
    var
        PurchaseImport2: Record "MFCC01 Purchase Import";
    begin
        PurchaseImport2.Reset();
        PurchaseImport2.SetCurrentKey("Invoice No.");
        PurchaseImport2.SetRange(Status, PurchaseImport.Status::Created);
        PurchaseImport2.SetRange("Invoice No.", PurchHeader."No.");
        IF PurchaseImport2.FindSet() then
            PurchaseImport2.ModifyAll(Remarks, CopyStr(ErrorText, 1, 500));
    end;

    local procedure UpdateComments(PurchHeader: Record "Purchase Header")
    var
        PurchaseImport2: Record "MFCC01 Purchase Import";
    begin
        PurchaseImport2.Reset();
        PurchaseImport2.SetCurrentKey("Invoice No.");
        PurchaseImport2.SetRange(Status, PurchaseImport.Status::Created);
        PurchaseImport2.SetRange("Invoice No.", PurchHeader."No.");
        IF PurchaseImport2.FindSet() then
            PurchaseImport2.ModifyAll(Remarks, '');
    end;
}