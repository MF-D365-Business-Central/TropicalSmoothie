page 60000 "MFCC01 Customisation Setup"
{
    Caption = 'Customisation Setup';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Customisation Setup";
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
                // field("Agreement Nos."; Rec."Agreement Nos.")
                // {
                //     ToolTip = 'Specifies the value of the Agreement Nos. field.';
                // }
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