page 60004 "MFCC01 Agreements"
{
    Caption = 'Franchise Agreements';
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Agreement Date"; Rec."Agreement Date")
                {
                    ToolTip = 'Specifies the value of the Agreement Date field.';
                }
                field("Franchise Revenue Start Date"; Rec."Franchise Revenue Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchise Revenue Start Date field.';
                }
                field("Term Expiration Date"; Rec."Term Expiration Date")
                {
                    ToolTip = 'Specifies the value of the Term Expiration Date field.';
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ToolTip = 'Specifies the value of the No. of Periods field.';
                }
                field("Royalty Bank Account"; Rec."Royalty Bank Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Bank Account field.';
                }
                field("License Type"; Rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement Type field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("CommissionscheduleNo."; Rec."CommissionscheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Commission schedule No. field.';
                }
                field("FranchiseFeescheduleNo."; Rec."FranchiseFeescheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Royalty schedule No. field.';
                }
                field("RenewalFeescheduleNo."; Rec."RenewalFeescheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Renewal Fee Schedule No. field.';
                }
                field("Franchise Bank Account"; Rec."Franchise Bank Account")
                {
                    ToolTip = 'Specifies the value of the Franchise Bank Account field.';
                }
                field("Agreement Amount"; Rec."Agreement Amount")
                {
                    ToolTip = 'Specifies the value of the Agreement Amount field.';
                }
                field(NonGapInitialRevenueRecognized; Rec.NonGapInitialRevenueRecognized)
                {
                    ToolTip = 'Specifies the value of the Non Gap Initial Revenue Recognized GAAP field.';
                }
                field("Posted Agreement Amount"; Rec."Posted Agreement Amount")
                {
                    ToolTip = 'Specifies the value of the Posted Agreement Amount field.';
                }
                field("Posted Commission Amount"; Rec."Posted Commission Amount")
                {
                    ToolTip = 'Specifies the value of the Posted Commission Amount field.';
                }

                field(PostedCommissionExpenseAmount; Rec.PostedCommissionExpenseAmount)
                {
                    ToolTip = 'Specifies the value of the Posted Commission Expense  Amount field.';
                }
                field(PostedRevenueStatisticalAmount; Rec.PostedRevenueStatisticalAmount)
                {
                    ToolTip = 'Specifies the value of the Posted Revenue Statistical Amount field.';
                }
                field("SalesPerson Commission"; Rec."SalesPerson Commission")
                {
                    ToolTip = 'Specifies the value of the SalesPerson Commission field.';
                }
                field("Termination Date"; Rec."Termination Date")
                {
                    ToolTip = 'Specifies the value of the Termination Date field.';
                }

                //GGG

            }
        }
        area(FactBoxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
                RunPageLink = "Agreement No." = field("No."), "Customer No." = field("Customer No.");
            }
            action(Renewals)
            {
                ApplicationArea = All;
                Image = ResourcePlanning;
                RunObject = page "MFCC01 Agreement Renewal";
                RunPageLink = "Agreement No." = field("No.");
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
                    RunPageLink = "Agreement No." = field("No.");
                }
                action(Statntries)
                {
                    Caption = 'Statistical Ledger Entries';
                    ApplicationArea = All;
                    Image = Entries;
                    RunPageMode = View;

                    //RunObject = Page "Statistical Ledger Entry List";
                    //RunPageLink = "Document No." = field("No.");
                    trigger OnAction()
                    var
                        StatLedger: Record "Statistical Ledger Entry";
                        StatLedgerList: Page "Statistical Ledger Entry List";
                    begin
                        StatLedger.SetFILTER("Document No.", StrSubstNo('%1*', Rec."No."));
                        StatLedgerList.SetTableView(StatLedger);
                        StatLedgerList.Run();
                    end;
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
            action("Co&mments")
            {
                ApplicationArea = Comments;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Comment Sheet";
                RunPageLink = "Table Name" = CONST("MFCC01 Agreement Header"),
                                  "No." = FIELD("No.");
                ToolTip = 'View or add comments for the record.';
            }
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
                Visible = false;
                trigger OnAction()
                var
                    DeferralUtility: Codeunit "MFCC01 Deferral Utilities";
                begin
                    DeferralUtility.CreatedeferralScheduleFromAgreement(Rec);
                end;
            }
            action(ProcessCommission)
            {
                Caption = 'Process Commission';
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                var
                    AgreementMgmt: Codeunit "MFCC01 Agreement Management";
                Begin
                    AgreementMgmt.ProcessCommission(Rec);
                End;
            }
            action(Import)
            {
                ApplicationArea = All;
                Image = Import;
                RunObject = report MFCC01AgreementExcelImport;
            }
        }
    }
}