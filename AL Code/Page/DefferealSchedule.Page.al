page 60001 "MFC Deferral Schedule"
{
    Caption = 'MFC Deferral Schedule';
    PageType = Card;
    SourceTable = "MFC Deferral Header";

    layout
    {
        area(content)
        {

            group(General)
            {

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
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
                field("Deferral Code"; Rec."Deferral Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deferral Code field.';
                }
                field("Amount to Defer"; Rec."Amount to Defer")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the amount to defer per period.';
                }
                field("Calc. Method"; Rec."Calc. Method")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how the Amount field for each period is calculated. Straight-Line: Calculated per the number of periods, distributed by period length. Equal Per Period: Calculated per the number of periods, distributed evenly on periods. Days Per Period: Calculated per the number of days in the period. User-Defined: Not calculated. You must manually fill the Amount field for each period.';
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how many accounting periods the total amounts will be deferred to.';
                }

                field(StartDateCalcMethod; StartDateCalcMethod)
                {
                    ApplicationArea = Suite;
                    Caption = 'Start Date Calc. Method';
                    Editable = false;
                    ToolTip = 'Specifies the method used to calculate the start date that is used for calculating deferral amounts.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when to start calculating deferral amounts.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bal. Account No. field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
            part(DeferralSheduleSubform; "MFC Deferral Schedule Subform")
            {
                ApplicationArea = Suite;
                SubPageLink =
                              "Document No." = FIELD("Document No.");
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

        StartDateCalcMethod: Text;

    trigger OnDeleteRecord(): Boolean
    Begin
        Rec.TestStausOpen(Rec);
    End;

    procedure SetParameter(DisplayCustomerNo: Code[20]; DocumentNo: Code[20])
    begin

        DisplayDocumentNo := DocumentNo;
        DisplayCustomerNo := DisplayCustomerNo;
    end;

    trigger OnAfterGetRecord()
    Begin
        InitForm();
    End;

    procedure GetParameter(): Boolean
    begin
        exit(Changed or CurrPage.DeferralSheduleSubform.PAGE.GetChanged())
    end;

    procedure InitForm()
    var
        DeferralTemplate: Record "Deferral Template";
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitForm(Rec, DisplayCustomerNo, DisplayDocumentNo, StartDateCalcMethod, IsHandled);
        if IsHandled then
            exit;

        IF DeferralTemplate.Get(Rec."Deferral Code") then;
        StartDateCalcMethod := Format(DeferralTemplate."Start Date");

    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitForm(var DeferralHeader: Record "MFC Deferral Header"; DisplayCustomerNo: Code[20]; DisplayDocumentNo: Code[20]; var StartDateCalcMethod: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnQueryClosePageOnAfterCalcShowNoofPeriodsError(DeferralHeader: Record "MFC Deferral Header"; DeferralLine: Record "MFC Deferral Line"; var ShowNoofPeriodsError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnQueryClosePageOnAfterDeferralLineSetFilters(DeferralHeader: Record "MFC Deferral Header"; var DeferralLine: Record "MFC Deferral Line")
    begin
    end;
}

