tableextension 60000 MFCC01Customer extends Customer
{
    LookupPageId = "Currency Card";
    fields
    {
        // Add changes to table fields here
        field(60000; "Franchisee Type"; Enum MFCC01FrnachiseeType)
        {
            DataClassification = CustomerContent;
        }
        field(60001; "Franchisee Status"; Enum MFCC01FrnachiseeStatus)
        {
            DataClassification = CustomerContent;
        }

        field(60002; "Opening Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        // field(60003; "First Agreement No."; Date)
        // {
        //     DataClassification = CustomerContent;
        // }
        // field(60004; "Last Agreement No."; Date)
        // {
        //     Editable = false;
        //     DataClassification = CustomerContent;
        // }
    }


}