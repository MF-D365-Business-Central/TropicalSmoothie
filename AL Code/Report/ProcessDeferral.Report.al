report 60000 "Process Deferral"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("MFC Deferral Header"; "MFC Deferral Header")
        {
            DataItemTableView = where(Status = const(Certified));
            dataitem("MFC Deferral Line"; "MFC Deferral Line")
            {
                DataItemLink = "Customer No." = field("Customer No."), "Document No." = field("Document No.");
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
                    "MFC Deferral Header".CloseDeferralDocument();
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
    End;

    local procedure PostDeferralLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
        DeferralTemplate: Record "Deferral Template";

        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        DeferralTemplate.Get("MFC Deferral Header"."Deferral Code");

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := "MFC Deferral Line"."Posting Date";
        GenJnlLine."Document No." := "MFC Deferral Header"."Document No." + '/' + Format("MFC Deferral Line"."Posting Date");
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", DeferralTemplate."Deferral Account");

        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", "MFC Deferral Header"."Bal. Account No.");
        GenJnlLine.Validate("Currency Code", "MFC Deferral Line"."Currency Code");
        GenJnlLine.Validate(Amount, "MFC Deferral Line".Amount);

        InitDefaultDimSource(DefaultDimSource);
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code",
        GenJnlLine."Dimension Set ID", 0);

        "MFC Deferral Line".Posted := GenJnlPostLine.RunWithCheck(GenJnlLine) <> 0;
        "MFC Deferral Line".Modify();
    end;

    local procedure InitDefaultDimSource(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        Clear(DefaultDimSource);
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer", "MFC Deferral Header"."Customer No.");
    end;



    var
        PostingDate: Date;
        DimMgt: Codeunit DimensionManagement;
}