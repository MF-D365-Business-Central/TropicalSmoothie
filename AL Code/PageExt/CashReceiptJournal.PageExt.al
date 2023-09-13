pageextension 60002 "MFCC01 Cash Receipt Journal" extends "Cash Receipt Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Apply Entries")
        {
            action(Suggest)
            {
                ApplicationArea = All;
                Caption = 'Suggest Customer Payments';
                Promoted = true;
                PromotedCategory = Process;
                Image = Suggest;

                  trigger OnAction()
                    var
                        SuggestCustomerPayments: Report "Suggest Customer Payments";
                    begin
                        Clear(SuggestCustomerPayments);
                        SuggestCustomerPayments.SetGenJnlLine(Rec);
                        SuggestCustomerPayments.RunModal();
                    end;
            }
        }
    }

    var
        myInt: Integer;
}