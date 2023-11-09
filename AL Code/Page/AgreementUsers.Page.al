page 60007 "MFCC01 Agreement Users"
{
    Caption = 'Users';
    PageType = ListPart;
    SourceTable = "MFCC01 Agreement Users";
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Owner First Name"; Rec."Owner First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Owner First Name field.';
                }
                field("Owner Last Name"; Rec."Owner Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Owner Last Name field.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field.';
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone field.';
                }

                field(Active; Rec.Phone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone field.';
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