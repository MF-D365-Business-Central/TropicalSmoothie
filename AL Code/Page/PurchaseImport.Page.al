page 60012 "MFCC01 Purchase Import"
{
    Caption = 'Purchase Import';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Purchase Import";
    InsertAllowed = false;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ToolTip = 'Specifies the value of the Invoice Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ToolTip = 'Specifies the value of the Line Amount field.';
                }
                field("Department Code"; Rec."Department Code")
                {
                    ToolTip = 'Specifies the value of the Department Code field.';
                }
                field("Market Code"; Rec."Market Code")
                {
                    ToolTip = 'Specifies the value of the Market Code field.';
                }
                field("Cafe Code"; Rec."Cafe Code")
                {
                    ToolTip = 'Specifies the value of the Cafe Code field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Invoice No. field.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
                }

            }
        }
    }

    actions
    {
        
        area(Navigation)
        {
            action(Document)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    PageHeler: Codeunit "Page Management";
                    PurchaseHeder: Record "Purchase Header";
                    PurchaseInvoice: Record "Purch. Inv. Header";
                    PurchaseCredMemo: Record "Purch. Cr. Memo Hdr.";
                begin

                    Case Rec.Status of
                        Rec.Status::Created:
                            Begin
                                PurchaseHeder.SetRange("Document Type", Rec."Document Type");
                                PurchaseHeder.SetRange("No.", Rec."Invoice No.");
                                IF PurchaseHeder.FindFirst() then
                                    PageHeler.PageRun(PurchaseHeder);
                            End;
                        Rec.Status::Posted:
                            Begin
                                Case Rec."Document Type" of
                                    Rec."Document Type"::Invoice, Rec."Document Type"::Order:
                                        Begin
                                            PurchaseInvoice.SetRange("Pre-Assigned No.", Rec."Invoice No.");
                                            IF PurchaseInvoice.FindFirst() then
                                                PageHeler.PageRun(PurchaseInvoice);
                                        End;
                                    Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order":
                                        Begin
                                            PurchaseCredMemo.SetRange("Pre-Assigned No.", Rec."Invoice No.");
                                            IF PurchaseCredMemo.FindFirst() then
                                                PageHeler.PageRun(PurchaseInvoice);
                                        End;
                                End;

                            End;
                    End;

                end;
            }
        }
       
        area(Processing)
        {
            action(ImportFromExcel)
            {
                ApplicationArea = All;
                Image = Import;
                Caption = 'Import';
                RunObject = report MFCC01PurchaseExcelImport;

            }

            action(Create)
            {
                ApplicationArea = All;
                Image = Create;
                Caption = 'Create';
                trigger OnAction()
                var
                    PurchaseImport: Codeunit "MFCC01 Purchase Import";
                Begin
                    PurchaseImport.GenerateInvoice();
                End;

            }

            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Caption = 'Post';
                trigger OnAction()
                var
                    PurchaseImport: Codeunit "MFCC01 Purchase Import";
                Begin
                    PurchaseImport.PostDocuments();
                End;
            }
        }
    }


}