page 60003 "MFCC01 Deferrals"
{
    Caption = 'Franchise Deferrals';
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
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }

                field("Agreement No."; Rec."Agreement No.")
                {
                    ToolTip = 'Specifies the value of the Agreement No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies when to start calculating deferral amounts.';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.';
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ToolTip = 'Specifies how many accounting periods the total amounts will be deferred to.';
                }
                field("Remaining Periods"; Rec."Remaining Periods")
                {
                    ToolTip = 'Specifies the value of the Remaining Periods field.';
                }

                field("Amortized Periods"; Rec."Amortized Periods")
                {
                    ToolTip = 'Specifies the value of the Amortized Periods field.';
                }
                field("Amount to Defer"; Rec."Amount to Defer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount to defer per period.';
                }
                field("Net Amortized"; Rec."Net Amortized")
                {
                    ToolTip = 'Specifies the value of the Net Amortized field.';
                }
                field("Net Balance"; Rec."Net Balance")
                {
                    ToolTip = 'Specifies the value of the Net Balance field.';
                }
                field(Amortized; Rec.Amortized)
                {
                    ToolTip = 'Specifies the value of the Amortized field.';
                }
                field(Balance; Rec.Balance)
                {
                    ToolTip = 'Specifies the value of the Balance field.';
                }

                field("Schedule Description"; Rec."Schedule Description")
                {
                    ToolTip = 'Specifies the value of the Schedule Description field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }


    actions
    {
        area(Navigation)
        {
            action(GLntries)
            {
                Caption = 'G/L Entries';
                ApplicationArea = All;
                Image = Entries;
                RunPageMode = View;
                RunObject = Page "General Ledger Entries";
                RunPageLink = "Document No." = field("Document No.");
            }
        }
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