page 60003 "MFCC01 Deferrals"
{
    Caption = 'Deferrals';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Deferral Header";
    Editable = false;
    CardPageId = "MFCC01 DeferralSchedule";

    layout
    {
        area(Content)
        {
            repeater(Cotnrol1)
            {
                field("Agreement No."; Rec."Agreement No.")
                {
                    ToolTip = 'Specifies the value of the Agreement No. field.';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Deferral Code"; Rec."Deferral Code")
                {
                    ToolTip = 'Specifies the value of the Deferral Code field.';
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ToolTip = 'Specifies how many accounting periods the total amounts will be deferred to.';
                }
                field("Amount to Defer"; Rec."Amount to Defer")
                {
                    ToolTip = 'Specifies the amount to defer per period.';
                }
                field("Calc. Method"; Rec."Calc. Method")
                {
                    ToolTip = 'Specifies how the Amount field for each period is calculated. Straight-Line: Calculated per the number of periods, distributed by period length. Equal Per Period: Calculated per the number of periods, distributed evenly on periods. Days Per Period: Calculated per the number of days in the period. User-Defined: Not calculated. You must manually fill the Amount field for each period.';
                }
                field("Schedule Description"; Rec."Schedule Description")
                {
                    ToolTip = 'Specifies the value of the Schedule Description field.';
                }
            }
        }
    }


    actions
    {
        area(processing)
        {
            group("Actions")
            {
                Caption = 'Actions';
                action(CalculateSchedule)
                {
                    ApplicationArea = Suite;
                    Caption = 'Calculate Schedule';
                    Image = CalculateCalendar;
                    ToolTip = 'Calculate the MFC Deferral Schedule by which revenue or expense amounts will be distributed over multiple accounting periods.';

                    trigger OnAction()
                    begin
                        Rec.CalculateSchedule();
                    end;
                }
                action(ReOpen)
                {
                    ApplicationArea = All;
                    Image = ReOpen;
                    trigger OnAction()
                    begin
                        Rec.ReopenDocument(Rec);
                    end;
                }
                action(Certify)
                {
                    ApplicationArea = All;
                    Image = Certificate;
                    trigger OnAction()
                    begin
                        Rec.SetDocumentCertified(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CalculateSchedule_Promoted; CalculateSchedule)
                {
                }
            }
        }
    }




}