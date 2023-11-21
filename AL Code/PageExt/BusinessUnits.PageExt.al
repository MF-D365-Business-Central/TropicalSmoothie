pageextension 60003 "MFCC01Business Unit List" extends "Business Unit List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        modify("Run Consolidation")
        {
            Enabled = Not NonGaapEnable;
        }
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
    begin
        IF CZSetup.Get() then;
        NonGaapEnable := CZSetup."Non GAAP Consolidation Company";
    end;

    var
        CZSetup: Record "MFCC01 Franchise Setup";
        NonGaapEnable: Boolean;
}