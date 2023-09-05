page 60000 "Customisation Setup"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Customisation Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Deferral Template"; Rec."Deferral Template")
                {
                    ToolTip = 'Specifies the value of the Deferral Template field.';
                }

                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Bal. Account No. field.';
                }
            }
            group(Numbering)
            {

                field("Deferral Nos."; Rec."Deferral Nos.")
                {
                    ToolTip = 'Specifies the value of the Deferral Nos. field.';
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

    trigger OnOpenPage()
    begin
        Createifnew();
    end;

    local procedure Createifnew()
    begin
        IF not Rec.Get() then Begin
            Rec.Init();
            Rec.Insert();
        End;
    end;
}