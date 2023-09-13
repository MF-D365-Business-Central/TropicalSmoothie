page 60000 "MFCC01 Customization Setup"
{
    Caption = 'Customization Setup';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Customization Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            group(Deferral)
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
            group(Journal)
            {

                field("Royalty Account"; Rec."Royalty Account")
                {
                    ToolTip = 'Specifies the value of the Royalty Account field.';
                }
                field("Local Account"; Rec."Local Account")
                {
                    ToolTip = 'Specifies the value of the Local Account field.';
                }
                field("National Account"; Rec."National Account")
                {
                    ToolTip = 'Specifies the value of the National Account field.';
                }

            }
            group(Agreement)
            {

                field("Commission Def. Account"; Rec."Commission Def. Account")
                {
                    ToolTip = 'Specifies the value of the Commission Def. Account field.';
                }
                field("Commission Payable Account"; Rec."Commission Payable Account")
                {
                    ToolTip = 'Specifies the value of the Commission Payable Account field.';
                }

                field("Agreement Def. Account"; Rec."Agreement Def. Account")
                {
                    ToolTip = 'Specifies the value of the Agreement Def. Account field.';
                }
            }
            group(Dimensions)
            {

                field("Local Department Code"; Rec."Local Department Code")
                {
                    ToolTip = 'Specifies the value of the Local Department Code field.';
                }
                field("National Department Code"; Rec."National Department Code")
                {
                    ToolTip = 'Specifies the value of the National Department Code field.';
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