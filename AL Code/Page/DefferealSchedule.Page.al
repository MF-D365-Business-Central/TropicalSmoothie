page 60001 "MFCC01 DeferralSchedule"
{
    Caption = 'Deferral Schedule';
    PageType = Card;
    SourceTable = "MFCC01 Deferral Header";

    layout
    {
        area(content)
        {

            group(General)
            {

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement No. field.';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }

                field("Amount to Defer"; Rec."Amount to Defer")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amount to defer per period.';
                }
                field("Net Amortized"; Rec."Net Amortized")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Amortized field.';
                }
                field("Net Balance"; Rec."Net Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Balance field.';
                }
                field(Amortized; Rec.Amortized)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amortized field.';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field.';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when to start calculating deferral amounts.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field.';
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how many accounting periods the total amounts will be deferred to.';
                }
                field("Remaining Periods"; Rec."Remaining Periods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Periods field.';
                }

                field("Amortized Periods"; Rec."Amortized Periods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amortized Periods field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
            part(DeferralSheduleSubform; "MFCC01 DeferralScheduleSubform")
            {
                ApplicationArea = Suite;
                SubPageLink =
                              "Document No." = FIELD("Document No.");
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
                        Changed := Rec.CalculateSchedule();
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


    var
        TotalToDeferErr: Label 'The sum of the deferred amounts must be equal to the amount in the Amount to Defer field.';
        Changed: Boolean;
        DisplayCustomerNo: Code[20];
        DisplayDocumentNo: Code[20];

        PostingDateErr: Label 'You cannot specify a posting date that is not equal to the start date.';


    trigger OnDeleteRecord(): Boolean
    Begin
        Rec.TestStausOpen(Rec);
    End;

    procedure SetParameter(DisplayCustomerNo: Code[20]; DocumentNo: Code[20])
    begin

        DisplayDocumentNo := DocumentNo;
        DisplayCustomerNo := DisplayCustomerNo;
    end;



    procedure GetParameter(): Boolean
    begin
        exit(Changed or CurrPage.DeferralSheduleSubform.PAGE.GetChanged())
    end;



    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitForm(var DeferralHeader: Record "MFCC01 Deferral Header"; DisplayCustomerNo: Code[20]; DisplayDocumentNo: Code[20];  var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnQueryClosePageOnAfterCalcShowNoofPeriodsError(DeferralHeader: Record "MFCC01 Deferral Header"; DeferralLine: Record "MFCC01 Deferral Line"; var ShowNoofPeriodsError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnQueryClosePageOnAfterDeferralLineSetFilters(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;
}

