page 60018 "Dimension Combination FM"
{
    Caption = 'Dimension Combination FMM-MARKET';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Dimension Combination";
    SourceTableView = where("Parent Dimension Code" = const('FMM'));
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
                    TableRelation = "Dimension".Code where("Code" = const('FMM'));
                }
                field("Parent Dimension Value"; Rec."Parent Dimension Value")
                {
                    ToolTip = 'Specifies the value of the Parent Dimension Value field.';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('FMM'));
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Dimension Code field.';
                    TableRelation = "Dimension".Code where("Code" = const('MARKET'));
                }
                field("Child Dimension Value"; Rec."Child Dimension Value")
                {
                    ToolTip = 'Specifies the value of the Child Dimension Value field.';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('MARKET'));
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
            action(DeleteAll)
            {
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                begin
                    DeleteALLDimCombintion();
                end;
            }
        }
    }

    local procedure DeleteALLDimCombintion()
    var
        DimValueCombination: Record "Dimension Value Combination";
    begin
        IF DimValueCombination.FindSet() then
            DimValueCombination.DeleteAll();
        Message('Completed');
    end;

    local procedure UpdateCombination()
    var
        DimCombination: Record "Dimension Combination";
        DimValueCombination: Record "Dimension Value Combination";
        DimensionImport: Record "MFCC01 Dimension Combination";
        Dimension: Record Dimension;
        FMMDimValues: Record "Dimension Value";
        MARKETDimValues: Record "Dimension Value";
    begin
        DimCombination.SetRange("Dimension 1 Code", 'FMM');
        DimCombination.SetRange("Dimension 2 Code", 'MARKET');
        IF Not DimCombination.FindFirst() then begin
            DimCombination.Init();
            DimCombination."Dimension 1 Code" := 'FMM';
            DimCombination."Dimension 2 Code" := 'MARKET';
            DimCombination."Combination Restriction" := DimCombination."Combination Restriction"::Limited;
            DimCombination.Insert(True);
        end;

        FMMDimValues.Reset();
        FMMDimValues.SetRange("Dimension Code", 'FMM');
        IF FMMDimValues.FindSet then
            repeat

                MARKETDimValues.Reset();
                MARKETDimValues.SetRange("Dimension Code", 'MARKET');
                IF MARKETDimValues.FindSet then
                    repeat
                        DimensionImport.Reset();
                        DimensionImport.SetRange("Parent Dimension Code", FMMDimValues."Dimension Code");
                        DimensionImport.SetRange("Parent Dimension Value", FMMDimValues.Code);
                        DimensionImport.SetRange("Dimension Code", MARKETDimValues."Dimension Code");
                        DimensionImport.SetRange("Child Dimension Value", MARKETDimValues.Code);
                        IF Not DimensionImport.FindFirst() then Begin
                            DimValueCombination.Reset();
                            DimValueCombination.SetRange("Dimension 1 Code", FMMDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 1 Value Code", FMMDimValues.Code);
                            DimValueCombination.SetRange("Dimension 2 Code", MARKETDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 2 Value Code", MARKETDimValues.Code);
                            IF DimValueCombination.IsEmpty() then Begin
                                DimValueCombination.Init();
                                DimValueCombination."Dimension 1 Code" := FMMDimValues."Dimension Code";
                                DimValueCombination."Dimension 1 Value Code" := FMMDimValues.Code;
                                DimValueCombination."Dimension 2 Code" := MARKETDimValues."Dimension Code";
                                DimValueCombination."Dimension 2 Value Code" := MARKETDimValues.Code;
                                DimValueCombination.Insert(true);
                            End;
                        End else begin
                            DimValueCombination.Reset();
                            DimValueCombination.SetRange("Dimension 1 Code", FMMDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 1 Value Code", FMMDimValues.Code);
                            DimValueCombination.SetRange("Dimension 2 Code", MARKETDimValues."Dimension Code");
                            DimValueCombination.SetRange("Dimension 2 Value Code", MARKETDimValues.Code);
                            IF DimValueCombination.FindFirst() then
                                DimValueCombination.Delete();
                        end;
                    until MARKETDimValues.Next() = 0;
            until FMMDimValues.Next() = 0;

        Message('Completed');
    end;
}