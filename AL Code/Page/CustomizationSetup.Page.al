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
                field("Non GAAP Consolidation Company"; Rec."Non GAAP Consolidation Company")
                {
                    ToolTip = 'Specifies the value of the Non GAAP Consolidation Company field.';
                }

            }
            group(Numbering)
            {

                field("Deferral Nos."; Rec."Deferral Nos.")
                {
                    ToolTip = 'Specifies the value of the Deferral Nos. field.';
                }
                field("Agreement Nos."; Rec."Agreement Nos.")
                {
                    ToolTip = 'Specifies the value of the Agreement Nos. field.';
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
                group(GAAP)
                {
                    field("Commission Payble Account"; Rec."Commission Payble Account")
                    {
                        ToolTip = 'Specifies the value of the Commission Payble Account field.';
                    }
                    field("Commission Recognised GAAP"; Rec."Commission Recognised GAAP")
                    {
                        ToolTip = 'Specifies the value of the Commission Recognised field.';
                    }
                    field("Prepaid Commision"; Rec."Prepaid Commision")
                    {
                        ToolTip = 'Specifies the value of the Commission Payable Account field.';
                    }
                    field("Revenue Recognised GAAP"; Rec."Revenue Recognised GAAP")
                    {
                        ToolTip = 'Specifies the value of the "Revenue Recognised field.';
                    }
                    field("Def Revenue Cafes in Operation"; Rec."Def Revenue Cafes in Operation")
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Operation field.';
                    }
                    field("Deferred Revenue Development"; Rec."Deferred Revenue Development")
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Operation Under Developent field.';
                    }


                }
                Group(Statistical)
                {
                    field(NonGapInitialRevenueRecognised; Rec.NonGapInitialRevenueRecognised)
                    {
                        ToolTip = 'Specifies the value of the Non Gap Initial Revenue Recognised field.';
                    }
                    field("Commission Expense Account"; Rec."Commission Expense Account")
                    {
                        ToolTip = 'Specifies the value of the Commission Expense Account field.';
                    }
                    field(CommissionDeferredExpenseAcc; Rec.CommissionDeferredExpenseAcc)
                    {
                        ToolTip = 'Specifies the value of the Commission Deferred Expense Account field.';
                    }
                    field("Revenue Recognised"; Rec."Revenue Recognised")
                    {
                        ToolTip = 'Specifies the value of the Revenue Recognised field.';
                    }
                    field("Deferred Revenue Operational"; Rec."Deferred Revenue Operational")
                    {
                        ToolTip = 'Specifies the value of the Deferred Revenue Recognised field.';
                    }
                    field("Revenue Recognised Development";
                    Rec."Revenue Recognised Development")
                    {
                        ToolTip = 'Specifies the value of the Revenue Recognised Under Development field.';
                    }

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