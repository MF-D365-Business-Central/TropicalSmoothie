page 60019 "Dimension Combination MC"
{
    Caption = 'Dimension Combination MARKET-CAFE';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Dimension Combination";
    SourceTableView = where("Parent Dimension Code" = const('MARKET'));
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Parent Dimension Code"; Rec."Parent Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Parent Dimension Code field.';
                    TableRelation = "Dimension".Code where("Code" = const('MARKET'));
                }
                field("Parent Dimension Value"; Rec."Parent Dimension Value")
                {
                    ToolTip = 'Specifies the value of the Parent Dimension Value field.';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('MARKET'));
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Dimension Code field.';
                    TableRelation = "Dimension".Code where("Code" = const('CAFE'));
                }
                field("Child Dimension Value"; Rec."Child Dimension Value")
                {
                    ToolTip = 'Specifies the value of the Child Dimension Value field.';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('CAFE'));
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Update)
            {
                ApplicationArea = All;
                Image = UpdateDescription;
                trigger OnAction()
                begin
                    UpdateCombination();
                end;
            }
        }
    }

    local procedure UpdateCombination()
    var
        DimCombination: Record "Dimension Combination";
        DimValueCombination: Record "Dimension Value Combination";
        DimensionImport: Record "MFCC01 Dimension Combination";
        Dimension: Record Dimension;
        MARKETDimValues: Record "Dimension Value";
        CAFEDimValues: Record "Dimension Value";
    begin
        DimCombination.SetRange("Dimension 1 Code", 'MARKET');
        DimCombination.SetRange("Dimension 2 Code", 'CAFE');
        IF Not DimCombination.FindFirst() then begin
            DimCombination.Init();
            DimCombination."Dimension 1 Code" := 'MARKET';
            DimCombination."Dimension 2 Code" := 'CAFE';
            DimCombination."Combination Restriction" := DimCombination."Combination Restriction"::Limited;
            DimCombination.Insert(True);
        end;

        MARKETDimValues.Reset();
        MARKETDimValues.SetRange("Dimension Code", 'MARKET');
        IF MARKETDimValues.FindSet then
            repeat

                CAFEDimValues.Reset();
                CAFEDimValues.SetRange("Dimension Code", 'CAFE');
                IF CAFEDimValues.FindSet then
                    repeat
                        DimensionImport.Reset();
                        DimensionImport.SetRange("Parent Dimension Code", MARKETDimValues."Dimension Code");
                        DimensionImport.SetRange("Parent Dimension Value", MARKETDimValues.Code);
                        DimensionImport.SetRange("Dimension Code", CAFEDimValues."Dimension Code");
                        DimensionImport.SetRange("Child Dimension Value", CAFEDimValues.Code);
                        IF Not DimensionImport.FindFirst() then Begin
                            DimValueCombination.Reset();
                            DimValueCombination.SetRange("Dimension 1 Code", MARKETDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 1 Value Code", MARKETDimValues.Code);
                            DimValueCombination.SetRange("Dimension 2 Code", CAFEDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 2 Value Code", CAFEDimValues.Code);
                            IF DimValueCombination.IsEmpty() then begin
                                DimValueCombination.Init();
                                DimValueCombination."Dimension 1 Code" := MARKETDimValues."Dimension Code";
                                DimValueCombination."Dimension 1 Value Code" := MARKETDimValues.Code;
                                DimValueCombination."Dimension 2 Code" := CAFEDimValues."Dimension Code";
                                DimValueCombination."Dimension 2 Value Code" := CAFEDimValues.Code;
                                DimValueCombination.Insert(true);
                            End;
                        End else begin
                            DimValueCombination.Reset();
                            DimValueCombination.SetRange("Dimension 1 Code", MARKETDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 1 Value Code", MARKETDimValues.Code);
                            DimValueCombination.SetRange("Dimension 2 Code", CAFEDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 2 Value Code", CAFEDimValues.Code);
                            IF DimValueCombination.FindFirst() then
                                DimValueCombination.Delete();
                        end;
                    until CAFEDimValues.Next() = 0;

            until MARKETDimValues.Next() = 0;

        Message('Completed');
    end;

}