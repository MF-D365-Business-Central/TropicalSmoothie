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
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }

    actions
    {
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