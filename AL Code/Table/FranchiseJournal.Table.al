table 60008 "MFCC01 Franchise Journal"
{
    Caption = 'Franchise Journal';
    DataClassification = CustomerContent;

    fields
    {

        field(2; "Batch Name"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Franchise Batch".Code;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;

        }
        field(4; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Document Date"; Date)
        {
            DataClassification = CustomerContent;

        }
        field(6; "Document Type"; Enum "MFCC01 Franchise Document Type")
        {
            DataClassification = CustomerContent;

        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No." where(Blocked = const(" "));

            trigger OnValidate()
            Begin
                CreateDim();
                CopyAgreement();
            End;

        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(12; "Agreement ID"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No." where("Customer No." = field("Customer No."));

            trigger OnValidate()
            Begin
                CalcAmounts();
            End;
        }
        field(13; "Net Sales"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            trigger OnValidate()
            Begin
                CalcAmounts();
            End;
        }
        field(14; "Royalty Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Ad Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Other Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, Rec."Shortcut Dimension 1 Code");
            end;
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, Rec."Shortcut Dimension 2 Code");
            end;
        }


    }

    keys
    {
        key(Key1; "Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }



    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    var

        CZSetup: Record "MFCC01 Customization Setup";
        FranchiseBatch: Record "MFCC01 Franchise Batch";
        FranchiseJnlLine: Record "MFCC01 Franchise Journal";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        CZSetupRead: Boolean;

    local procedure GetSetup()
    begin
        IF Not CZSetupRead then Begin
            CZSetup.Get();
            CZSetupRead := true;
        End;
    end;

    procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDimensions(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            Rec, "Dimension Set ID", StrSubstNo('%1 %2', "Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        IsChanged := OldDimSetID <> "Dimension Set ID";
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, CurrFieldNo);
    end;

    local procedure CopyAgreement()
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
    begin
        AgreementHeader.SetRange("Customer No.", Rec."Customer No.");
        AgreementHeader.SetRange(Status, AgreementHeader.Status::Active);
        IF Not AgreementHeader.FindFirst() then
            Clear(AgreementHeader);
        Rec."Agreement ID" := AgreementHeader."No.";
    end;

    local procedure CreateDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimSource(DefaultDimSource);
        Rec."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code",
        Rec."Dimension Set ID", 0);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure SetUpNewLine(LastFranchiseJnlLine: Record "MFCC01 Franchise Journal"; BottomLine: Boolean)
    var
        IsHandled: Boolean;

    begin
        GetSetup();
        IsHandled := false;
        OnBeforeSetUpNewLine(FranchiseBatch, FranchiseJnlLine, LastFranchiseJnlLine, CZSetupRead, BottomLine, IsHandled, Rec);
        if IsHandled then
            exit;

        FranchiseBatch.Get("Batch Name");
        FranchiseJnlLine.SetRange("Batch Name", "Batch Name");
        if FranchiseJnlLine.FindFirst() then begin
            "Posting Date" := LastFranchiseJnlLine."Posting Date";
            "Document Date" := LastFranchiseJnlLine."Posting Date";
            "Document No." := LastFranchiseJnlLine."Document No.";

            IsHandled := false;
            OnSetUpNewLineOnBeforeIncrDocNo(FranchiseJnlLine, LastFranchiseJnlLine, BottomLine, IsHandled, Rec, FranchiseBatch);
            if BottomLine and not IsHandled
            then
                IncrementDocumentNo(FranchiseBatch, "Document No.");
        end else begin
            "Posting Date" := WorkDate();
            "Document Date" := WorkDate();
            IsHandled := false;
            OnSetUpNewLineOnBeforeSetDocumentNo(FranchiseJnlLine, LastFranchiseJnlLine, BottomLine, IsHandled, Rec);
            if not IsHandled then
                if FranchiseBatch."No. Series" <> '' then begin
                    Clear(NoSeriesMgt);
                    "Document No." := NoSeriesMgt.TryGetNextNo(FranchiseBatch."No. Series", "Posting Date");
                end;
        end;
        OnAfterSetupNewLine(Rec, FranchiseBatch, LastFranchiseJnlLine, BottomLine);
    end;

    procedure IncrementDocumentNo(FranchiseBatch: Record "MFCC01 Franchise Batch"; var LastDocNumber: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        if FranchiseBatch."No. Series" <> '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, FranchiseBatch."No. Series", "Posting Date");
            if NoSeriesLine."Increment-by No." > 1 then
                NoSeriesMgt.IncrementNoText(LastDocNumber, NoSeriesLine."Increment-by No.")
            else
                LastDocNumber := IncStr(LastDocNumber);
        end else
            LastDocNumber := IncStr(LastDocNumber);
    end;

    procedure InitNewLine(PostingDate: Date; DocumentDate: Date; VATDate: Date; PostingDescription: Text[100]; ShortcutDim1Code: Code[20]; ShortcutDim2Code: Code[20]; DimSetID: Integer; ReasonCode: Code[10])
    begin
        Init();
        "Posting Date" := PostingDate;
        "Document Date" := DocumentDate;

        Description := PostingDescription;
        "Shortcut Dimension 1 Code" := ShortcutDim1Code;
        "Shortcut Dimension 2 Code" := ShortcutDim2Code;
        "Dimension Set ID" := DimSetID;

        OnAfterInitNewLine(Rec);
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", Rec."Customer No.");
    end;


    procedure EmptyLine() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeEmptyLine(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit(
          ("Customer No." = '') and ("Net Sales" = 0) and
          ("Agreement ID" = ''));
    end;

    local procedure CalcAmounts()
    var
        AgreementLine: Record "MFCC01 Agreement Line";
    begin


        AgreementLine.SetRange("Agreement No.", Rec."Agreement ID");
        AgreementLine.SetFilter("Starting Date", '<=%1', Rec."Document Date");
        AgreementLine.SetFilter("Ending Date", '>=%1', Rec."Document Date");
        IF not AgreementLine.FindFirst() then
            Clear(AgreementLine);

        Rec."Royalty Fee" := (AgreementLine."Royalty Fees %" * Rec."Net Sales") / 100;
        Rec."Ad Fee" := (AgreementLine."Local Fees %" * Rec."Net Sales") / 100;
        Rec."Other Fee" := (AgreementLine."National Fees %" * Rec."Net Sales") / 100;


    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDimensions(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; xFranchiseJnlLine: Record "MFCC01 Franchise Journal"; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; var xFranchiseJnlLine: Record "MFCC01 Franchise Journal"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; var xFranchiseJnlLine: Record "MFCC01 Franchise Journal"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetUpNewLine(var FranchiseBatch: Record "MFCC01 Franchise Batch"; var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; LastFranchiseJnlLine: Record "MFCC01 Franchise Journal"; var GLSetupRead: Boolean; BottomLine: Boolean; var IsHandled: Boolean; var Rec: Record "MFCC01 Franchise Journal")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNewLine(var FranchiseJnlLine: Record "MFCC01 Franchise Journal")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUpNewLineOnBeforeIncrDocNo(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; LastFranchiseJnlLine: Record "MFCC01 Franchise Journal"; var BottomLine: Boolean; var IsHandled: Boolean; var Rec: Record "MFCC01 Franchise Journal"; FranchiseBatch: Record "MFCC01 Franchise Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUpNewLineOnBeforeSetDocumentNo(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; LastFranchiseJnlLine: Record "MFCC01 Franchise Journal"; var BottomLine: Boolean; var IsHandled: Boolean; var Rec: Record "MFCC01 Franchise Journal")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var FranchiseJnlLine: Record "MFCC01 Franchise Journal"; FranchiseBatch: Record "MFCC01 Franchise Batch"; LastFranchiseJnlLine: Record "MFCC01 Franchise Journal"; BottomLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmptyLine(FranchiseJnlLine: Record "MFCC01 Franchise Journal"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}