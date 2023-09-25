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

        GLEntry.LockTable();
    End;

    local procedure PostDeferralLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
        DeferralTemplate: Record "Deferral Template";

        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        DeferralTemplate.Get("MFCC01 Deferral Header"."Deferral Code");

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := "MFCC01 Deferral Line"."Posting Date";
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No." + '/' + Format("MFCC01 Deferral Line"."Posting Date");
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", DeferralTemplate."Deferral Account");
        GenJnlLine.Validate("Currency Code", "MFCC01 Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, "MFCC01 Deferral Line".Amount);
        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);
        "MFCC01 Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := "MFCC01 Deferral Line"."Posting Date";
        GenJnlLine."Document No." := "MFCC01 Deferral Header"."Document No." + '/' + Format("MFCC01 Deferral Line"."Posting Date");
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", "MFCC01 Deferral Header"."Bal. Account No.");
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
        PostingDate: Date;
        DimMgt: Codeunit DimensionManagement;
        GLEntry: Record "G/L Entry";
}