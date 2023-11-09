page 60008 "MFCC01 Sales Import"
{
    Caption = 'Sales Import';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Sales Import";
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
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
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
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ToolTip = 'Specifies the value of the Line Amount field.';
                }
                field("Department Code"; Rec."Department Code")
                {
                    ToolTip = 'Specifies the value of the Department Code field.';
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
                    SalesHeder: Record "Sales Header";
                    SalesInvoice: Record "Sales Invoice Header";
                    SalesCredMemo: Record "Sales Cr.Memo Header";
                begin

                    Case Rec.Status of
                        Rec.Status::Created:
                            Begin
                                SalesHeder.SetRange("Document Type", Rec."Document Type");
                                SalesHeder.SetRange("No.", Rec."Document No.");
                                IF SalesHeder.FindFirst() then
                                    PageHeler.PageRun(SalesHeder);
                            End;
                        Rec.Status::Posted:
                            Begin
                                Case Rec."Document Type" of
                                    Rec."Document Type"::Invoice, Rec."Document Type"::Order:
                                        Begin
                                            SalesInvoice.SetRange("Pre-Assigned No.", Rec."Document No.");
                                            IF SalesInvoice.FindFirst() then
                                                PageHeler.PageRun(SalesInvoice);
                                        End;
                                    Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order":
                                        Begin
                                            SalesCredMemo.SetRange("Pre-Assigned No.", Rec."Document No.");
                                            IF SalesCredMemo.FindFirst() then
                                                PageHeler.PageRun(SalesInvoice);
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
                RunObject = report MFCC01SalesExcelImport;

            }
            action(Create)
            {
                ApplicationArea = All;
                Image = Create;
                Caption = 'Create';

                trigger OnAction()
                var
                    SalesImport: Codeunit "MFCC01 Sales Import";
                Begin
                    SalesImport.GenerateInvoice();
                End;

            }

            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Caption = 'Post';
                trigger OnAction()
                var
                    SalesImport: Codeunit "MFCC01 Sales Import";
                Begin
                    SalesImport.PostDocuments();
                End;
            }

        }
    }


}