codeunit 60019 "MFCC01 Process Correction"
{



    local procedure ProcessCorrections(AgreementHeader: Record "MFCC01 Agreement Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        DocumentType: Enum "Sales Document Type";
        GenjnlcheckLine: Codeunit "Gen. Jnl.-Check Line";
        RevertDate: Date;
        CopyDoc: Codeunit "Copy Document Mgt.";
        CLE: Record "Cust. Ledger Entry";
        TaxExNo: Text[30];
        GLEntries: Record "G/L Entry";
    begin
        GLEntries.SetRange("Agreement No.", AgreementHeader."No.");
        IF GLEntries.FindSet() then
            repeat
                CLE.SetRange("Document No.", GLEntries."Document No.");
                CLE.SetRange("Posting Date", GLEntries."Posting Date");
                CLE.SetRange("Customer No.", GLEntries."Source No.");
                IF CLE.FindFirst() then BEgin
                    IF CLE."Original Amount" <> CLE."Remaining Amount" then
                        Unapplypayment(CLE);
                ENd;
            Until GLEntries.Next() = 0;
    end;






    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure PostDocument(var SalesHeader: Record "Sales Header"): Boolean

    begin
        Exit(Codeunit.Run(Codeunit::"Sales-Post (Yes/No)", SalesHeader));
    end;


    local procedure UpdateGLSetup(PostDate: Date)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Allow Posting From" := CalcDate('<-CM>', PostDate);
        GLSetup."Allow Posting To" := CalcDate('<CM>', Today);
        GLSetup.Modify();
    end;

    local procedure Unapplypayment(CLEntryNo: Record "Cust. Ledger Entry")
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        CheckCustLedgEntryToUnapply(CLEntryNo."Entry No.", DtldCustLedgEntry2);
        ApplyUnapplyParameters."Document No." := CLEntryNo."Document No.";
        ApplyUnapplyParameters."Posting Date" := WorkDate();
        CustEntryApplyPostedEntries.PostUnApplyCustomer(DtldCustLedgEntry2, ApplyUnapplyParameters);
    end;


    procedure CheckCustLedgEntryToUnapply(CustLedgEntryNo: Integer; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        ApplicationEntryNo: Integer;
    begin
        Clear(DetailedCustLedgEntry);
        ApplicationEntryNo := FindLastApplEntry(CustLedgEntryNo);
        if ApplicationEntryNo <> 0 then
            DetailedCustLedgEntry.Get(ApplicationEntryNo);
    end;

    procedure FindLastApplEntry(CustLedgEntryNo: Integer): Integer
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplicationEntryNo: Integer;
    begin
        DtldCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntryNo);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        DtldCustLedgEntry.SetRange(Unapplied, false);
        //OnFindLastApplEntryOnAfterSetFilters(DtldCustLedgEntry);
        ApplicationEntryNo := 0;
        if DtldCustLedgEntry.Find('-') then
            repeat
                if DtldCustLedgEntry."Entry No." > ApplicationEntryNo then
                    ApplicationEntryNo := DtldCustLedgEntry."Entry No.";
            until DtldCustLedgEntry.Next() = 0;
        exit(ApplicationEntryNo);
    end;

    local procedure ReleasdeSalesDocument(Var SalesHeader: Record "Sales Header")
    var
        Releasesales: Codeunit "Release Sales Document";
    begin

        Releasesales.PerformManualRelease(SalesHeader);
    end;

    local procedure ReOpenSalesDocument(Var SalesHeader: Record "Sales Header")
    var
        Releasesales: Codeunit "Release Sales Document";
    begin

        Releasesales.PerformManualRelease(SalesHeader);
    end;


    local procedure GetCredmemoNo(PreAssgnNo: code[20]): code[20]
    var
        salesCred: Record "Sales Cr.Memo Header";
    begin

        salesCred.SetRange("Pre-Assigned No.", PreAssgnNo);
        IF Not salesCred.findlast then
            Clear(PreAssgnNo);
        Exit(salesCred."No.");
    end;

    local procedure GetInvoiceNo(PreAssgnNo: code[20]): code[20]
    var
        salesINV: Record "Sales Invoice Header";
    begin

        salesINV.SetRange("Pre-Assigned No.", PreAssgnNo);
        IF Not salesINV.findlast then
            Clear(PreAssgnNo);
        Exit(salesINV."No.");
    end;

}