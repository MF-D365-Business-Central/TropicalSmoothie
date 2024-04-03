page 60020 "MFCC01 PostedSnowflakeEntries"
{
    Caption = 'Posted Snowflake Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Snowflake Entry";
    SourceTableView = where(Status = filter(Processed));
    Editable = false;
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

}