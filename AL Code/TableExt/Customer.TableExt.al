tableextension 60000 MFCC01Customer extends Customer
{
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

    }


}