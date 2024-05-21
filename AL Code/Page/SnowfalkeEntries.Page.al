page 60013 "MFCC01 Snowflake Entries"
{
    Caption = 'Snowflake Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Snowflake Entry";
    SourceTableView = where(Status = filter(<> Processed));
    //Editable = false;
    InsertAllowed = false;
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
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Net Sales"; Rec."Net Sales")
                {
                    ToolTip = 'Specifies the value of the Net Sales field.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
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
                RunObject = report MFCC01SnowflakeImport;
            }
            // action(GetData)
            // {
            //     ApplicationArea = All;
            //     // Caption = 'Get Data';
            //     // Image = Import;
            //     // trigger OnAction()
            //     // begin
            //     //     PowerBI.GetData();
            //     // end;
            // }

            action(ValidateData)
            {
                ApplicationArea = All;
                Caption = 'Validate Data';
                Image = CheckList;
                trigger OnAction()
                var
                    ConfirmTxt: Label 'Do you want to Validate Snowflake data.?';
                begin
                    // IF not Confirm(ConfirmTxt, false, true) then
                    //     exit;
                    PowerBI.Validatedata();
                end;
            }

            action(PorcessData)
            {
                ApplicationArea = All;
                Caption = 'Process Data';
                Image = Process;
                trigger OnAction()
                var
                    ConfirmTxt: Label 'Do you want to Create franchise Journals Entries.?';
                begin
                    // IF not Confirm(ConfirmTxt, false, true) then
                    //     exit;
                    PowerBI.Processdata();
                end;
            }
        }
    }

    var
        PowerBI: Codeunit "MFCC01 PowerBI Integration";
}