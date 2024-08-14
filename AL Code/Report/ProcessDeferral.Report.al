report 60000 "MFCC01 Process Deferral"
{
    Caption = 'Process Franchise Deferral';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("MFCC01 Deferral Header"; "MFCC01 Deferral Header")
        {
            DataItemTableView = where(Status = const(Open));
            RequestFilterFields = "Agreement No.", "Document No.", "Customer No.";
            dataitem("MFCC01 Deferral Line"; "MFCC01 Deferral Line")
            {
                DataItemLink = "Document No." = field("Document No.");
                DataItemTableView = where(Posted = const(false), Amount = filter(<> 0));
                trigger OnPreDataItem()
                Begin
                    Setrange("Posting Date", PostingDate, Todate);
                End;

                trigger OnAfterGetRecord()
                Begin
                    PostDeferralLine();
                End;

                trigger OnPostDataItem()
                Begin
                    "MFCC01 Deferral Header".CloseDeferralDocument();
                End;
            }
            trigger OnAfterGetRecord()
            var
                Agreement: Record "MFCC01 Agreement Header";
            Begin
                IF Agreement.Get("MFCC01 Deferral Header"."Agreement No.") then
                    IF Agreement.Status <> Agreement.Status::Opened then
                        CurrReport.Skip();
            End;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'From Date';
                        ApplicationArea = All;
                    }
                    field(ToDate; ToDate)
                    {
                        Caption = 'TO Date';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;
                }
            }
        }
        trigger OnInit()
        Begin
            PostingDate := WorkDate();
            Todate := WorkDate();
        End;
    }

    trigger OnPreReport()
    Begin
        IF PostingDate = 0D then
            PostingDate := Today();
        CZSetup.GetRecordonce();
        CZSetup.TestField(CommissionRecognizedGAAP);
        CZSetup.TestField(RevenueRecognizedGAAP);

        CZSetup.TestField(DefCommisionsinOperationsGAAP);
        CZSetup.TestField(DefRevenueCafesinOperationGAAP);

        GLEntry.LockTable();
    End;

    local procedure PostDeferralLine()
    var
        GenJnlLine: Record "Gen. Journal Line";

        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        PostDate: Date;
    begin
        PostDate := "MFCC01 Deferral Line"."Posting Date";
        IF "MFCC01 Deferral Line"."New Posting Date" <> 0D then
            PostDate := "MFCC01 Deferral Line"."New Posting Date";
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostDate;
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        // IF "MFCC01 Deferral Header".Type = "MFCC01 Deferral Header".Type::Commission then
        //     GenJnlLine.Validate("Account No.", CZSetup.DefCommisionsinOperationsGAAP)
        // Else
        //     GenJnlLine.Validate("Account No.", CZSetup.RevenueRecognizedgaap);

        Case "MFCC01 Deferral Header".Type of
            "MFCC01 Deferral Header".Type::Commission:
                GenJnlLine.Validate("Account No.", CZSetup.DefCommisionsinOperationsGAAP);
            "MFCC01 Deferral Header".Type::"Franchise Fee",
            "MFCC01 Deferral Header".Type::Transferred:
                GenJnlLine.Validate("Account No.", CZSetup.RevenueRecognizedgaap);
            "MFCC01 Deferral Header".Type::Renewal:
                GenJnlLine.Validate("Account No.", CZSetup."Franchise Renewal Fee GAAP");
        End;
        GenJnlLine.Validate("Currency Code", "MFCC01 Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, -"MFCC01 Deferral Line".Amount);
        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
    GenJnlLine."Dimension Set ID", 0);
        GenJnlLine."Agreement No." := "MFCC01 Deferral Header"."Agreement No.";
        "MFCC01 Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostDate;
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        IF "MFCC01 Deferral Header".Type = "MFCC01 Deferral Header".Type::Commission then
            GenJnlLine.Validate("Account No.", CZSetup.CommissionRecognizedGAAP)
        Else
            GenJnlLine.Validate("Account No.", CZSetup.DefRevenueCafesinOperationGAAP);

        Case "MFCC01 Deferral Header".Type of
            "MFCC01 Deferral Header".Type::Commission:
                GenJnlLine.Validate("Account No.", CZSetup.CommissionRecognizedGAAP);
            "MFCC01 Deferral Header".Type::"Franchise Fee",
            "MFCC01 Deferral Header".Type::Transferred:
                GenJnlLine.Validate("Account No.", CZSetup.DefRevenueCafesinOperationGAAP);
            "MFCC01 Deferral Header".Type::Renewal:
                GenJnlLine.Validate("Account No.", CZSetup."Deferred Renewal Fee GAAP");
        End;
        GenJnlLine.Validate("Currency Code", "MFCC01 Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, "MFCC01 Deferral Line".Amount);
        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        GenJnlLine."Agreement No." := "MFCC01 Deferral Header"."Agreement No.";
        "MFCC01 Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;
        "MFCC01 Deferral Line".Modify();
        Commit();
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", "MFCC01 Deferral Header"."Customer No.");
    end;

    var
        CZSetup: Record "MFCC01 Franchise Setup";
        DimMgt: Codeunit DimensionManagement;
        PostingDate: Date;
        ToDate: Date;
        GLEntry: Record "G/L Entry";
}