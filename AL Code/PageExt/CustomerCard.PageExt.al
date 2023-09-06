pageextension 60000 "MFCC01 Customer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addbefore(Invoicing)
        {
            group(Franchisee)
            {

                field("Franchisee Type"; Rec."Franchisee Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchisee Type field.';
                }
                field("Franchisee Status"; Rec."Franchisee Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Franchisee Status field.';
                }
                field("Opening Date"; Rec."Opening Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field.';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast("&Customer")
        {
            action(Deferrals)
            {
                ApplicationArea = All;
                Image = Installments;
                Promoted = true;
                PromotedCategory = Category9;
                RunPageMode = View;
                RunObject = Page "MFCC01 Deferrals";
                RunPageLink = "Customer No." = field("No.");
            }
            action(Agreements)
            {
                ApplicationArea = All;
                Image = Agreement;
                Promoted = true;
                PromotedCategory = Category9;
                RunPageMode = View;
                RunObject = Page "MFCC01 Agreements";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }

}