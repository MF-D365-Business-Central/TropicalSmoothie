page 60005 "MFCC01 Agreement"
{
    Caption = 'Agreement';
    PageType = Card;
    SourceTable = "MFCC01 Agreement Header";
    ApplicationArea = suite;

    layout
    {
        area(Content)
        {
            group(General)
            {


                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
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
                field("Agreement Amount"; Rec."Agreement Amount")
                {
                    ToolTip = 'Specifies the value of the Agreement Amount field.';
                }


                field("SalesPerson Commission"; Rec."SalesPerson Commission")
                {
                    ToolTip = 'Specifies the value of the SalesPerson Commission field.';
                }
                field(NonGapInitialRevenueRecognized; Rec.NonGapInitialRevenueRecognized)
                {
                    ToolTip = 'Specifies the value of the Non Gap Initial Revenue Recognized GAAP field.';
                }

                field("Royalty Bank Account"; Rec."Royalty Bank Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Bank Account field.';
                }
                field("Franchise Bank Account"; Rec."Franchise Bank Account")
                {
                    ToolTip = 'Specifies the value of the Franchise Bank Account field.';
                }

                field("License Type"; Rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement Type field.';
                }
                field("CommissionscheduleNo."; Rec."CommissionscheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Commission schedule No. field.';
                }
                field("RoyaltyscheduleNo."; Rec."RoyaltyscheduleNo.")
                {
                    ToolTip = 'Specifies the value of the Royalty schedule No. field.';
                }
                field("Termination Date"; Rec."Termination Date")
                {
                    ToolTip = 'Specifies the value of the Termination Date field.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
            part(Lines; "MFCC01 Agreement Lines")
            {
                UpdatePropagation = Both;
                ApplicationArea = Suite;
                SubPageLink = "Agreement No." = field("No.");
            }
            part(Users; "MFCC01 Agreement Users")
            {
                UpdatePropagation = Both;
                ApplicationArea = Suite;
                SubPageLink = "Agreement No." = field("No.");
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
        }
    }


}