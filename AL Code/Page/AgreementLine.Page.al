page 60006 "MFCC01 Agreement Lines"
{
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "MFCC01 Agreement Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    ApplicationArea = suite;
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Royalty Fees"; Rec."Royalty Fees")
                {
                    ToolTip = 'Specifies the value of the Royalty Fees field.';
                }
                field("Local Fees"; Rec."Local Fees")
                {
                    ToolTip = 'Specifies the value of the Local Fees field.';
                }
                field("National Fees"; Rec."National Fees")
                {
                    ToolTip = 'Specifies the value of the National Fees field.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }


}