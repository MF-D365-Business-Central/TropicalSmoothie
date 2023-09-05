pageextension 60000 "MFC Customer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here

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
                RunObject = Page "MFC Deferrals";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }

}