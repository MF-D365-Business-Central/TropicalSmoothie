page 60010 "MFCC01 Franchise Journal"
{
    Caption = 'Franchise Journal';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MFCC01 Franchise Journal";
    AutoSplitKey = true;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                field(BatchName; BatchName)
                {
                    Caption = 'Batch Name';
                    TableRelation = "MFCC01 Franchise Batch".Code;
                    trigger OnValidate()
                    begin
                        FilterJournals();
                    end;
                }
            }
            repeater(Control1)
            {

                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    trigger OnValidate()
                    Begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    End;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Agreement ID"; Rec."Agreement ID")
                {
                    ToolTip = 'Specifies the value of the Agreement ID field.';
                }
                field("Net Sales"; Rec."Net Sales")
                {
                    ToolTip = 'Specifies the value of the Net Sales field.';
                }
                field("Royalty Fee"; Rec."Royalty Fee")
                {
                    ToolTip = 'Specifies the value of the Royalty Fee field.';
                }
                field("Ad Fee"; Rec."Ad Fee")
                {
                    ToolTip = 'Specifies the value of the Ad Fee field.';
                }
                field("Other Fee"; Rec."Other Fee")
                {
                    ToolTip = 'Specifies the value of the Other Fee field.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 3);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 4);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 5);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 6);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 7);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 8);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                var
                    ConfirmTxt: Label 'Do you want to Post Franchise Journals.?';
                begin
                    IF not Confirm(ConfirmTxt, false, true) then
                        exit;
                    Codeunit.RUn(Codeunit::"MFCC01 Franchise Jnl. Post", Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(Dimensions)
            {
                ApplicationArea = All;
                Image = Dimensions;
                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
            action(Entries)
            {
                ApplicationArea = All;
                Image = Entries;
                Promoted = true;
                PromotedCategory = New;
                RunPageMode = View;
                RunObject = Page "General Ledger Entries";
                RunPageLink = "Document No." = field("Agreement ID");
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetBatchName(BatchName);
        SetDimensionVisibility();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec, BelowxRec);
    end;

    trigger OnAfterGetRecord()
    Begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    End;

    local procedure FilterJournals()
    begin
        Rec.FilterGroup(2);
        Rec.Setrange("Batch Name", BatchName);
        Rec.FilterGroup(0);
    end;

    procedure SetBatchName(MyBatchName: Code[20])
    begin
        BatchName := MyBatchName;
        IF BatchName = '' then Begin
            FranchiseBatch.FindFirst();
            BatchName := FranchiseBatch.Code;
        End;
        FilterJournals();
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;

    var
        BatchName: Code[20];
        FranchiseBatch: Record "MFCC01 Franchise Batch";

    protected var

        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var FranchiseJournalLine: Record "MFCC01 Franchise Journal"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    begin
    end;
}