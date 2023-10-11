page 60004 "MFCC01 Agreements"
{
    Caption = 'Agreements';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Agreement Header";
    Editable = false;
    CardPageId = "MFCC01 Agreement";
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';

                }
                field("Agreement Date"; Rec."Agreement Date")
                {
                    ToolTip = 'Specifies the value of the Agreement Date field.';
                }

                field("Opening Date"; Rec."Franchise Revenue Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field.';
                }

                field("Franchise Revenue Start Date"; Rec."Franchise Revenue Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchise Revenue Start Date field.';
                }
                field("Royalty Bank Account"; Rec."Royalty Bank Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Bank Account field.';
                }

                field("License Type"; Rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Type field.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("ComissionscheduleNo."; Rec."ComissionscheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Comission schedule No. field.';
                }
                field("RoyaltyscheduleNo."; Rec."RoyaltyscheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Royalty schedule No. field.';
                }
                field("Franchise Bank Account"; Rec."Franchise Bank Account")
                {
                    ToolTip = 'Specifies the value of the Franchise Bank Account field.';
                }

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Deferrals)
            {
                ApplicationArea = All;
                Image = Installments;
                RunPageMode = View;
                RunObject = Page "MFCC01 Deferrals";
                RunPageLink = "Agreement No." = field("No."), "Customer No." = field("No.");
            }
            group(Entries)
            {

                action(GLntries)
                {
                    Caption = 'G/L Entries';
                    ApplicationArea = All;
                    Image = Entries;
                    RunPageMode = View;
                    RunObject = Page "General Ledger Entries";
                    RunPageLink = "Document No." = field("No.");
                }
                action(Statntries)
                {
                    Caption = 'Statistical Ledger Entries';
                    ApplicationArea = All;
                    Image = Entries;
                    RunPageMode = View;
                    RunObject = Page "Statistical Ledger Entry List";
                    RunPageLink = "Document No." = field("No.");
                }
                action(Franchisentries)
                {
                    Caption = 'Franchise Ledger Entries';
                    ApplicationArea = All;
                    Image = Entries;
                    RunPageMode = View;
                    RunObject = Page "MFCC01 FranchiseLedgerEntries";
                    RunPageLink = "Agreement ID" = field("No.");
                }
            }
        }
        area(Processing)
        {

            action(Sign)
            {
                ApplicationArea = All;
                Image = Signature;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetStatusSigned(Rec);
                end;
            }
            action(Open)
            {
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetStatusOpen(Rec);
                end;
            }
            action(Terminate)
            {
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetStatusTerminate(Rec);
                end;
            }
            action(CreateSchedule)
            {
                Caption = 'Create Schedule';
                ApplicationArea = All;
                Image = Installments;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
                begin
                    DeferralUtility.CreatedeferralScheduleFromAgreement(Rec);
                end;
            }
        }
    }


}