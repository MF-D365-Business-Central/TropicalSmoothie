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


                    field("Accrued Fran Bonus GAAP"; Rec."Accrued Fran Bonus GAAP")
                    {
                        ToolTip = 'Specifies the value of the Accrued Fran Bonus field.';
                    }
                    field(CommissionRecognizedGAAP; Rec.CommissionRecognizedGAAP)
                    {
                        ToolTip = 'Specifies the value of the Commission Recognized field.';
                    }
                    field(PrepaidCommisionLTGAAP; Rec.PrepaidCommisionLTGAAP)
                    {
                        ToolTip = 'Specifies the value of the Prepaid Commision LT field.';
                    }
                    field(DefCommisionsinOperationsGAAP; Rec.DefCommisionsinOperationsGAAP)
                    {
                        ToolTip = 'Specifies the value of the Def Commisions in Operations field.';
                    }
                    field(RevenueRecognizedGAAP; Rec.RevenueRecognizedGAAP)
                    {
                        ToolTip = 'Specifies the value of the Revenue Recognized field.';
                    }
                    field(DefRevenueCafesinOperationGAAP; Rec.DefRevenueCafesinOperationGAAP)
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Operations field.';
                    }
                    field(DeferredRevenueDevelopmentGAPP; Rec.DeferredRevenueDevelopmentGAPP)
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Development field.';
                    }
                }
                Group(Statistical)
                {


                    field(NonGapInitialRevenueRecognized; Rec.NonGapInitialRevenueRecognized)
                    {
                        ToolTip = 'Specifies the value of the Non Gap Initial Revenue Recognized field.';
                    }
                    field(CommissionRecognized; Rec.CommissionRecognized)
                    {
                        ToolTip = 'Specifies the value of the Commission Recognized field.';
                    }
                    field(PrepaidCommisionLT; Rec.PrepaidCommisionLT)
                    {
                        ToolTip = 'Specifies the value of the Prepaid Commision LT field.';
                    }
                    field(DefCommisionsinOperations; Rec.DefCommisionsinOperations)
                    {
                        ToolTip = 'Specifies the value of the Def Commisions in Operations field.';
                    }
                    field(RevenueRecognized; Rec.RevenueRecognized)
                    {
                        ToolTip = 'Specifies the value of the Revenue Recognized field.';
                    }
                    field(DefRevenueCafesinOperation; Rec.DefRevenueCafesinOperation)
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Operations field.';
                    }
                    field(DeferredRevenueDevelopment; Rec.DeferredRevenueDevelopment)
                    {
                        ToolTip = 'Specifies the value of the Def Revenue Cafes in Development field.';
                    }
                }

            }
            group(Renewal)
            {
                group(RenewalGAAP)
                {
                    Caption = 'GAAP';
                    field("Franchise Renewal Fee GAAP"; Rec."Franchise Renewal Fee GAAP")
                    {
                        ToolTip = 'Specifies the value of the Franchise Renewal Fee field.';
                    }
                    field("Deferred Renewal Fee GAAP"; Rec."Deferred Renewal Fee GAAP")
                    {
                        ToolTip = 'Specifies the value of the Deferred Renewal Fee field.';
                    }
                }
                Group(RenewalStatistical)
                {
                    Caption = 'Statistical';
                    field("Franchise Renewal Fee"; Rec."Franchise Renewal Fee")
                    {
                        ToolTip = 'Specifies the value of the Franchise Renewal Fee field.';
                    }
                    field("Deferred Renewal Fee"; Rec."Deferred Renewal Fee")
                    {
                        ToolTip = 'Specifies the value of the Deferred Renewal Fee field.';
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