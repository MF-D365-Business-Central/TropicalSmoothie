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
                field("Local Advertizing fee"; Rec."Local Advertizing fee")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Advertizing fee field.';
                }
                field("National Advertizing Fee"; Rec."National Advertizing Fee")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the National Advertizing Fee field.';
                }
                field("Franchising Commission"; Rec."Franchising Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchising Commission field.';
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