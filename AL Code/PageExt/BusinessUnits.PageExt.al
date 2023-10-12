pageextension 60003 "MFCC01Business Unit List" extends "Business Unit List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Run Consolidation")
        {
            action("Run Consolidation Non GAAP")
            {
                ApplicationArea = Suite;
                Caption = 'Run Consolidation -Non GAAP';
                Ellipsis = true;
                Image = ImportDatabase;
                RunObject = Report "Import Consolidation Non GAAP";
                ToolTip = 'Run consolidation.';
                Enabled = NonGaapEnable;
            }
        }
    }


    trigger OnOpenPage()
    Begin
        SetControlProperties();
    End;

    local procedure SetControlProperties()
    var
        myInt: Integer;
    begin
        CZSetup.Get();
        NonGaapEnable := CZSetup."Non GAAP Consolidation Company";
    end;

    var
        CZSetup: Record "MFCC01 Customization Setup";
        NonGaapEnable: Boolean;
}