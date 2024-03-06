reportextension 60000 MFCC01StandardSalesInvoice extends "Standard Sales - Invoice"
{
    dataset
    {
        // Add changes to dataitems and columns here
        add(Line)
        {
            column(Posting_Description; Header."Posting Description")
            {
            }
            column(Posting_DescriptionLbl; Header.FieldCaption("Posting Description"))
            {
            }
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = RDLC;
    //         LayoutFile = 'mylayout.rdl';
    //     }
    // }
}