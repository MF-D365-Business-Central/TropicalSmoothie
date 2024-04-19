page 60000 "MFCC01 Franchise Setup"
{
    Caption = 'Franchise Setup';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Franchise Setup";
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
                field("Franchise Journal Batch"; Rec."Franchise Journal Batch")
                {
                    ToolTip = 'Specifies the value of the Franchise Journal Batch field.';
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
                    field("PrePaid Commissions ST GAAP"; Rec."PrePaid Commissions ST GAAP")
                    {
                        ToolTip = 'Specifies the value of the PrePaid Commissions ST GAAP field.';
                    }
                    field("Deferred Revenue ST GAAP"; Rec."Deferred Revenue ST GAAP")
                    {
                        ToolTip = 'Specifies the value of the Deferred Revenue ST GAAP field.';
                    }
                    field("Deferred Revenue LT GAAP"; Rec."Deferred Revenue LT GAAP")
                    {
                        ToolTip = 'Specifies the value of the Deferred Revenue LT GAAP field.';
                    }
                    field("Tansfer Fee GAPP"; Rec."Tansfer Fee GAPP")
                    {
                        ToolTip = 'Specifies the value of the Tansfer Fee field.';
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
                    field("PrePaid Commissions ST"; Rec."PrePaid Commissions ST")
                    {
                        ToolTip = 'Specifies the value of the PrePaid Commissions ST field.';
                    }
                    field("Deferred Revenue ST"; Rec."Deferred Revenue ST")
                    {
                        ToolTip = 'Specifies the value of the Deferred Revenue ST field.';
                    }
                    field("Deferred Revenue LT"; Rec."Deferred Revenue LT")
                    {
                        ToolTip = 'Specifies the value of the Deferred Revenue LT field.';
                    }
                    field("Tansfer Fee"; Rec."Tansfer Fee")
                    {
                        ToolTip = 'Specifies the value of the Tansfer Fee field.';
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
                field("Corp Department Code"; Rec."Corp Department Code")
                {
                    Caption = 'Department Code For Fee & Royalty';
                    ToolTip = 'Specifies the value of the Corp Department Code field.';
                }
                field("Local Department Code"; Rec."Local Department Code")
                {
                    ToolTip = 'Specifies the value of the Local Department Code field.';
                }
                field("National Department Code"; Rec."National Department Code")
                {
                    ToolTip = 'Specifies the value of the National Department Code field.';
                }
                field(FRD; 'FRD - Set at GL & Stat Account')
                {
                    Editable = false;
                    Caption = 'Department Code For Commission';
                    ApplicationArea = All;
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