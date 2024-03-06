page 60002 "MFCC01 DeferralScheduleSubform"
{
    Caption = 'Deferral Schedule Detail';
    PageType = ListPart;
    SourceTable = "MFCC01 Deferral Line";
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the record.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the line''s net amount.';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted field.';
                }
            }
            group(Control8)
            {
                ShowCaption = false;
                group(Control7)
                {
                    ShowCaption = false;
                    field(TotalDeferral; TotalDeferral)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Total Amount to Defer';
                        Editable = false;
                        Enabled = false;
                        ToolTip = 'Specifies the total amount to defer.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateTotal();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Changed := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Changed := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Changed := true;
    end;

    var
        TotalDeferral: Decimal;
        Changed: Boolean;

    local procedure UpdateTotal()
    begin
        CalcTotal(Rec, TotalDeferral);
    end;

    local procedure CalcTotal(var DeferralLine: Record "MFCC01 Deferral Line"; var TotalDeferral: Decimal)
    var
        DeferralLineTemp: Record "MFCC01 Deferral Line";
        ShowTotalDeferral: Boolean;
    begin
        DeferralLineTemp.CopyFilters(DeferralLine);
        ShowTotalDeferral := DeferralLineTemp.CalcSums(Amount);
        if ShowTotalDeferral then
            TotalDeferral := DeferralLineTemp.Amount;
    end;

    procedure GetChanged(): Boolean
    begin
        exit(Changed);
    end;
}
