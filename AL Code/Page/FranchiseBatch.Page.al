page 60009 "MFCC01 Franchise Batches"
{
    Caption = 'Franchise Batches';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Franchise Batch";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ToolTip = 'Specifies the value of the No. Series field.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the value of the Source Code field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditJournal)
            {
                Caption = 'Edit Journal';
                Image = EditJournal;
                ApplicationArea = All;

                trigger OnAction()
                var
                    FranchiseJournal: Page "MFCC01 Franchise Journal";
                begin
                    FranchiseJournal.SetBatchName(Rec.Code);
                    FranchiseJournal.Run();
                end;
            }
        }
    }


}