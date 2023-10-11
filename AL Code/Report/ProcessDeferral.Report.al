report 60000 "MFCC01 Process Deferral"
{
    Caption = 'Process Deferral';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("MFCC01 Deferral Header"; "MFCC01 Deferral Header")
        {
            DataItemTableView = where(Status = const(Certified));
            dataitem("MFCC01 Deferral Line"; "MFCC01 Deferral Line")
            {
                DataItemLink = "Document No." = field("Document No.");
                DataItemTableView = where(Posted = const(false));
                trigger OnPreDataItem()
                Begin
                    SetRange("Posting Date", PostingDate);
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
                        Caption = 'Posting Date';
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
        End;
    }

    trigger OnPreReport()
    Begin
        IF PostingDate = 0D then
            PostingDate := Today();
        CZSetup.GetRecordonce();
        CZSetup.TestField("Revenue Recognised GAAP");
        CZSetup.TestField("Def Revenue Cafes in Operation");
        GLEntry.LockTable();
    End;

    local procedure PostDeferralLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := "MFCC01 Deferral Line"."Posting Date";
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", CZSetup."Def Revenue Cafes in Operation");
        GenJnlLine.Validate("Currency Code", "MFCC01 Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, "MFCC01 Deferral Line".Amount);
        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        "MFCC01 Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := "MFCC01 Deferral Line"."Posting Date";
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", CZSetup."Revenue Recognised GAAP");
        GenJnlLine.Validate("Currency Code", "MFCC01 Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, -"MFCC01 Deferral Line".Amount);
        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);

        "MFCC01 Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;
        "MFCC01 Deferral Line".Modify();
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", "MFCC01 Deferral Header"."Customer No.");
    end;



    var
        CZSetup: Record "MFCC01 Customization Setup";
        GLEntry: Record "G/L Entry";
        DimMgt: Codeunit DimensionManagement;
        PostingDate: Date;

}