page 60004 "MFCC01 Agreements"
{
    Caption = 'Agreements';
    PageType = List;
    ApplicationArea = suite;
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
                field("Opening Date"; Rec."Opening Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field.';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Effective Date field.';
                }

                field("Renewal Fee-First($)(OTF)"; Rec."Renewal Fee-First($)(OTF)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal Fee-First($)(Only 1 time fee) field.';
                }
                field("Renewal FA Effective Date"; Rec."Renewal FA Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal FA Effective Date field.';
                }
                field("Royalty Reporting Start Date"; Rec."Royalty Reporting Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Royalty Reporting Start Date field.';
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
        }
    }

    actions
    {
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