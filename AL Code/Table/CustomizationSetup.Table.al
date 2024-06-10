table 60000 "MFCC01 Franchise Setup"
{
    Caption = 'Franchise Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50; "Deferral Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
        }
        field(49; "Agreement Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
        }
        field(51; "Local Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code Where("Global Dimension No." = const(1));
        }
        field(52; "National Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code Where("Global Dimension No." = const(1));
        }
        field(53; "Royalty Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(54; "Local Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(55; "National Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(60; "Accrued Fran Bonus GAAP"; Code[20])
        {
            Caption = 'Accrued Fran Bonus';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(65; CommissionRecognizedGAAP; Code[20])
        {
            Caption = 'Commission Recognized';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(70; PrepaidCommisionLTGAAP; Code[20])
        {
            Caption = 'Prepaid Commision LT';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(75; DefCommisionsinOperationsGAAP; Code[20])
        {
            Caption = 'Def Commisions in Operations';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(80; RevenueRecognizedGAAP; Code[20])
        {
            Caption = 'Revenue Recognized';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(85; DefRevenueCafesinOperationGAAP; Code[20])
        {
            Caption = 'Def Revenue Cafes in Operations';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(90; DeferredRevenueDevelopmentGAPP; Code[20])
        {
            Caption = 'Def Revenue Cafes in Development';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(110; NonGapInitialRevenueRecognized; Decimal)
        {
            Caption = 'Non GAAP Initial Revenue Recognized';
            DataClassification = CustomerContent;
        }
        field(115; CommissionRecognized; Code[20])
        {
            Caption = 'Commission Recognized';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(120; PrepaidCommisionLT; Code[20])
        {
            Caption = 'Prepaid Commision LT';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(125; DefCommisionsinOperations; Code[20])
        {
            Caption = 'Def Commisions in Operations';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(130; RevenueRecognized; Code[20])
        {
            Caption = 'Revenue Recognized';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(135; DefRevenueCafesinOperation; Code[20])
        {
            Caption = 'Def Revenue Cafes in Operations';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(140; DeferredRevenueDevelopment; Code[20])
        {
            Caption = 'Def Revenue Cafes in Development';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(200; "Non GAAP Consolidation Company"; Boolean)
        {
            DataClassification = CustomerContent;
            //TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }

        //renewal
        field(210; "Franchise Renewal Fee GAAP"; Code[20])
        {
            Caption = 'Franchise Renewal Fee';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(211; "Deferred Renewal Fee GAAP"; Code[20])
        {
            Caption = 'Deferred Renewal Fee';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(212; "Franchise Renewal Fee"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(213; "Deferred Renewal Fee"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(214; "Corp Department Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code Where("Global Dimension No." = const(1));
        }
        field(215; "Franchise Journal Batch"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Franchise Batch".Code;
        }
        field(250; "PrePaid Commissions ST GAAP"; Code[20])
        {
            Caption = 'PrePaid Commissions ST';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(251; "Deferred Revenue ST GAAP"; Code[20])
        {
            Caption = 'Deferred Revenue ST';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(252; "Deferred Revenue LT GAAP"; Code[20])
        {
            Caption = 'Deferred Revenue LT';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }
        field(253; "PrePaid Commissions ST"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(254; "Deferred Revenue ST"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(255; "Deferred Revenue LT"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(256; "Tansfer Fee"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
        field(257; "Tansfer Fee GAPP"; Code[20])
        {
            Caption = 'Tansfer Fee';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where(Blocked = const(false));
        }

        field(258; DeferredRevenueTransfer; Code[20])
        {
            Caption = 'Def Revenue Transfer';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account"."No." where(Blocked = const(false));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
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

    procedure GetRecordonce()
    begin
        IF Not ReadRecord then begin
            Rec.Get();
            ReadRecord := true;
        end;
    end;

    var
        ReadRecord: Boolean;
}