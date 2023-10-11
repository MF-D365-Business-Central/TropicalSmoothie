page 60013 "MFCC01 Fixed Asset Import"
{
    Caption = 'Fixed Asset Import';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFCC01 FA Import";
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
                field(Category; Rec.Category)
                {
                    ToolTip = 'Specifies the value of the Category field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("FA Class Code"; Rec."FA Class Code")
                {
                    ToolTip = 'Specifies the value of the FA Class Code field.';
                }
                field("FA SubClass Code"; Rec."FA SubClass Code")
                {
                    ToolTip = 'Specifies the value of the FA SubClass Code field.';
                }
                field("FA Posting Group"; Rec."FA Posting Group")
                {
                    ToolTip = 'Specifies the value of the FA Posting Group field.';
                }
                field("Useful Life In Months"; Rec."Useful Life In Months")
                {
                    ToolTip = 'Specifies the value of the Useful Life In Months field.';
                }
                field("Book Value"; Rec."Book Value")
                {
                    ToolTip = 'Specifies the value of the Book Value field.';
                }
                field("Accumulated Depreciation"; Rec."Accumulated Depreciation")
                {
                    ToolTip = 'Specifies the value of the Accumulated Depreciation field.';
                }
                field("FA No."; Rec."FA No.")
                {
                    ToolTip = 'Specifies the value of the FA No. field.';
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
                RunObject = report MFCC01FAExcelImport;

            }
            action(Create)
            {
                ApplicationArea = All;
                Image = Create;
                Caption = 'Create';

                trigger OnAction()
                var
                    FAImport: Codeunit "MFCC01 FA Import";
                Begin
                    FAImport.CreateAsset();
                End;

            }

            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Caption = 'Post';
                trigger OnAction()
                var
                    FAImport: Codeunit "MFCC01 FA Import";
                Begin
                    FAImport.PostbookValue();
                End;
            }
            action(Postone)
            {
                ApplicationArea = All;
                Image = Post;
                Caption = 'Post Current';
                trigger OnAction()
                var
                    FAImport: Codeunit "MFCC01 FA Import";
                Begin
                    FAImport.PostbookValue(Rec);
                End;
            }
        }
    }


}