page 60005 "MFCC01 Agreement"
{
    Caption = 'Agreement';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "MFCC01 Agreement Header";
    ApplicationArea = suite;

    layout
    {
        area(Content)
        {
            group(General)
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
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Opening Date"; Rec."Opening Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field.';
                }
                field("Term Expiration Date"; Rec."Term Expiration Date")
                {
                    ToolTip = 'Specifies the value of the Term Expiration Date field.';
                }
                field("Royalty Reporting Start Date"; Rec."Royalty Reporting Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Reporting Start Date field.';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Effective Date field.';
                }

                field("Franchising Commission"; Rec."Franchising Commission")
                {
                    ToolTip = 'Specifies the value of the Franchising Commission field.';
                }
                field("SalesPerson Commission"; Rec."SalesPerson Commission")
                {
                    ToolTip = 'Specifies the value of the SalesPerson Commission field.';
                }


                field("Renewal FA Effective Date"; Rec."Renewal FA Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal FA Effective Date field.';
                }

                field("Royalty Bank Account"; Rec."Royalty Bank Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Bank Account field.';
                }
                field("Franchie Bank Account"; Rec."Franchie Bank Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchie Bank Account field.';
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
            }
            part(Lines; "MFCC01 Agreement Lines")
            {
                UpdatePropagation = Both;
                ApplicationArea = Suite;
                SubPageLink =
                              "Customer No." = FIELD("Customer No."), "Agreement No." = field("No.");
            }
            part(Users; "MFCC01 Agreement Users")
            {
                UpdatePropagation = Both;
                ApplicationArea = Suite;
                SubPageLink =
                              "Customer No." = FIELD("Customer No."), "Agreement No." = field("No.");
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
                Promoted = true;
                PromotedCategory = New;
                RunPageMode = View;
                RunObject = Page "MFCC01 Deferrals";
                RunPageLink = "Agreement No." = field("No."), "Customer No." = field("No.");
            }
        }
        area(Processing)
        {
            action(ReOpen)
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
            action(Activate)
            {
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetStatusActive(Rec);
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
        }
    }


}