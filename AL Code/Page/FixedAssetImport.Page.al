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
                field("Useful Life In Months"; Rec."Useful Life In Months")
                {
                    ToolTip = 'Specifies the value of the Useful Life In Months field.';
                }
                field("Method/Conv"; Rec."Method/Conv")
                {
                    ToolTip = 'Specifies the value of the Method/Conv field.';
                }
                field("In Service Date"; Rec."In Service Date")
                {
                    ToolTip = 'Specifies the value of the In Service Date field.';
                }
                field("Disposal Date"; Rec."Disposal Date")
                {
                    ToolTip = 'Specifies the value of the Disposal Date field.';
                }
                field("Historical Cost/Other Basis"; Rec."Historical Cost/Other Basis")
                {
                    ToolTip = 'Specifies the value of the Historical Cost/Other Basis field.';
                }
                field("FMV Cost/Other Basis"; Rec."FMV Cost/Other Basis")
                {
                    ToolTip = 'Specifies the value of the FMV Cost/Other Basis field.';
                }
                field("Accumulated Depreciation"; Rec."Accumulated Depreciation")
                {
                    ToolTip = 'Specifies the value of the Accumulated Depreciation field.';
                }
                field(NBV; Rec.NBV)
                {
                    ToolTip = 'Specifies the value of the NBV field.';
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

        }
    }


}