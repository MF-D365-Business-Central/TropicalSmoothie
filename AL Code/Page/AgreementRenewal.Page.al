page 60015 "MFCC01 Agreement Renewal"
{
    Caption = 'Agreement Renewal';
    PageType = list;
    SourceTable = "MFCC01 Agreement Renewal";

    layout
    {
        area(Content)
        {
            repeater(control1)
            {

                field("Renewal Date"; Rec."Renewal Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal Date field.';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Effective Date field.';
                }
                field("Renewal Fees"; Rec."Renewal Fees")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal Fees field.';
                }
                field("RenewalscheduleNo."; Rec."RenewalscheduleNo.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renewal Schedule No. field.';
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

            action(Sign)
            {
                ApplicationArea = All;
                Caption = 'Sign';
                Image = Signature;
                trigger OnAction()
                begin
                    Rec.SetStatusSigned();
                end;
            }
        }
        area(Navigation)
        {
            group(Entries)
            {

                action(GLntries)
                {
                    Caption = 'G/L Entries';
                    ApplicationArea = All;
                    Image = Entries;
                    RunPageMode = View;
                    RunObject = Page "General Ledger Entries";
                    RunPageLink = "Agreement No." = field("Agreement No.");
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
                        StatLedger.SetFILTER("Document No.", StrSubstNo('%1*', Rec."Agreement No."));
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
                    RunPageLink = "Agreement ID" = field("Agreement No.");
                }
            }
        }
    }
}

