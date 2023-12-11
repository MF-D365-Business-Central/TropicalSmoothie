page 60020 "Vendor bank Events"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Workflow Step";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field.';
                }
                field("Function Name"; Rec."Function Name")
                {
                    ToolTip = 'Specifies the value of the Function Name field.';
                }
                field("Entry Point"; Rec."Entry Point")
                {
                    ToolTip = 'Specifies the value of the Entry Point field.';
                }
                field(Argument; Rec.Argument)
                {
                    ToolTip = 'Specifies the value of the Argument field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Next Workflow Step ID"; Rec."Next Workflow Step ID")
                {
                    ToolTip = 'Specifies the value of the Next Workflow Step ID field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;


}

page 60021 "Events Workflow"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Workflow Event";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the workflow event that comes before the workflow event in the workflow sequence.';
                }
                field("Dynamic Req. Page Entity Name"; Rec."Dynamic Req. Page Entity Name")
                {
                    ToolTip = 'Specifies the value of the Dynamic Req. Page Entity Name field.';
                }
                field("Function Name"; Rec."Function Name")
                {
                    ToolTip = 'Specifies the value of the Function Name field.';
                }
                field(Independent; Rec.Independent)
                {
                    ToolTip = 'Specifies the value of the Independent field.';
                }
                field("Request Page ID"; Rec."Request Page ID")
                {
                    ToolTip = 'Specifies the value of the Request Page ID field.';
                }
                field("Used for Record Change"; Rec."Used for Record Change")
                {
                    ToolTip = 'Specifies the value of the Used for Record Change field.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}

page 60022 "Response workflow"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Workflow Response";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the workflow response.';
                }
                field("Function Name"; Rec."Function Name")
                {
                    ToolTip = 'Specifies the value of the Function Name field.';
                }
                field(Independent; Rec.Independent)
                {
                    ToolTip = 'Specifies the value of the Independent field.';
                }
                field("Response Option Group"; Rec."Response Option Group")
                {
                    ToolTip = 'Specifies the value of the Response Option Group field.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}

page 60024 "WF Event/Response Combination"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WF Event/Response Combination";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Function Name"; Rec."Function Name")
                {
                    ToolTip = 'Specifies the value of the Function Name field.';
                }
                field("Predecessor Function Name"; Rec."Predecessor Function Name")
                {
                    ToolTip = 'Specifies the value of the Predecessor Function Name field.';
                }
                field("Predecessor Type"; Rec."Predecessor Type")
                {
                    ToolTip = 'Specifies the value of the Predecessor Type field.';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}
