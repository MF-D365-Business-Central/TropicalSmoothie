codeunit 60000 "MFCC01 Deferral Utilities"
{

    trigger OnRun()
    begin
    end;

    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        AmountRoundingPrecision: Decimal;
        InvalidPostingDateErr: Label '%1 is not within the range of posting dates for your company.', Comment = '%1=The date passed in for the posting date.';
        DeferSchedOutOfBoundsErr: Label 'The deferral schedule falls outside the accounting periods that have been set up for the company.';
        SelectDeferralCodeMsg: Label 'A deferral code must be selected for the line to view the deferral schedule.';
        DescriptionTok: Label '%1-%2', Locked = true;

    procedure CreateRecurringDescription(PostingDate: Date; Description: Text[100]) FinalDescription: Text[100]
    var
        AccountingPeriod: Record "Accounting Period";
        Day: Integer;
        Week: Integer;
        Month: Integer;
        Year: Integer;
        MonthText: Text[30];
    begin
        Day := Date2DMY(PostingDate, 1);
        Week := Date2DWY(PostingDate, 2);
        Month := Date2DMY(PostingDate, 2);
        MonthText := Format(PostingDate, 0, '<Month Text>');
        Year := Date2DMY(PostingDate, 3);
        if IsAccountingPeriodExist(AccountingPeriod, PostingDate) then begin
            AccountingPeriod.SetRange("Starting Date", 0D, PostingDate);
            if not AccountingPeriod.FindLast() then
                AccountingPeriod.Name := '';
        end;
        FinalDescription :=
          CopyStr(StrSubstNo(Description, Day, Week, Month, MonthText, AccountingPeriod.Name, Year), 1, MaxStrLen(Description));
    end;

    procedure CreateDeferralSchedule(CustomerNo: Code[20]; DocumentNo: Code[20]; AmountToDefer: Decimal; StartDate: Date; NoOfPeriods: Integer; ApplyDeferralPercentage: Boolean; DeferralDescription: Text[100]; CurrencyCode: Code[10])
    var
        DeferralHeader: Record "MFCC01 Deferral Header";
        DeferralLine: Record "MFCC01 Deferral Line";
        AdjustedDeferralAmount: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDeferralSchedule(
             CustomerNo, DocumentNo, AmountToDefer,
            StartDate, NoOfPeriods, ApplyDeferralPercentage, DeferralDescription, CurrencyCode, IsHandled);
        if IsHandled then
            exit;

        InitCurrency(CurrencyCode);


        AdjustedDeferralAmount := AmountToDefer;
        if ApplyDeferralPercentage then
            AdjustedDeferralAmount := Round(AdjustedDeferralAmount * (100 / 100), AmountRoundingPrecision);

        SetDeferralRecords(
            DeferralHeader, CustomerNo, DocumentNo,
             NoOfPeriods, AdjustedDeferralAmount, StartDate,
             DeferralDescription, AmountToDefer, CurrencyCode);
        CalculateDaysPerPeriod(DeferralHeader, DeferralLine);

        OnAfterCreateDeferralSchedule(DeferralHeader, DeferralLine);
    end;

    procedure CalcNoOfPeriods(StartDate: Date; EndDate: Date) NoOfPeriods: Integer
    var
        AccountingPeriod: Record "Accounting Period";
        AccountingPeriod2: Record "Accounting Period";
    begin
        if IsAccountingPeriodExist(AccountingPeriod, StartDate) then begin
            AccountingPeriod.SetFilter("Starting Date", '>=%1&<=%2', StartDate, EndDate);
            AccountingPeriod.FindFirst();
        end;
        if AccountingPeriod."Starting Date" <> StartDate then
            NoOfPeriods := 1;


        StartDate := AccountingPeriod."Starting Date";
        repeat

            NoOfPeriods += 1;
            IF NoOfPeriods = 83 then
                NoOfPeriods := NoOfPeriods;

        Until AccountingPeriod.Next() = 0;
        AccountingPeriod2.SetFilter("Starting Date", '>%1&<=%2', AccountingPeriod."Starting Date", EndDate);
        IF AccountingPeriod2.FindFirst() then
            NoOfPeriods += 1;

    end;

    local procedure CheckPostingDate(DeferralHeader: Record "MFCC01 Deferral Header"; DeferralLine: Record "MFCC01 Deferral Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPostingDate(DeferralHeader, DeferralLine, IsHandled);
        if IsHandled then
            exit;

        if GenJnlCheckLine.DeferralPostingDateNotAllowed(DeferralLine."Posting Date") then
            Error(InvalidPostingDateErr, DeferralLine."Posting Date");
    end;

    local procedure CalculateDaysPerPeriod(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    var
        AccountingPeriod: Record "Accounting Period";
        AmountToDefer: Decimal;
        PeriodicCount: Integer;
        NumberOfDaysInPeriod: Integer;
        NumberOfDaysInSchedule: Integer;
        PostDate: Date;
        FirstPeriodDate: Date;
        SecondPeriodDate: Date;
        EndDate: Date;
        NoExtraPeriod: Boolean;
        DailyDeferralAmount: Decimal;
        RunningDeferralTotal: Decimal;
    begin
        OnBeforeCalculateDaysPerPeriod(DeferralHeader, DeferralLine);

        if IsAccountingPeriodExist(AccountingPeriod, DeferralHeader."Start Date") then begin
            AccountingPeriod.SetFilter("Starting Date", '>=%1', DeferralHeader."Start Date");
            if not AccountingPeriod.FindFirst() then
                Error(DeferSchedOutOfBoundsErr);
        end;


        // If comparison used <=, it messes up the calculations

        OnCalculateDaysPerPeriodOnAfterCalcEndDate(DeferralHeader, DeferralLine, EndDate);

        NumberOfDaysInSchedule := (DeferralHeader."End Date" - DeferralHeader."Start Date");
        DailyDeferralAmount := (DeferralHeader."Amount to Defer" / NumberOfDaysInSchedule);

        for PeriodicCount := 1 to DeferralHeader."No. of Periods" do begin
            InitializeDeferralHeaderAndSetPostDate(DeferralLine, DeferralHeader, PeriodicCount, PostDate);

            if PeriodicCount = 1 then begin
                Clear(RunningDeferralTotal);
                FirstPeriodDate := DeferralHeader."Start Date";

                // Get the starting date of the next accounting period
                SecondPeriodDate := GetNextPeriodStartingDate(PostDate);
                NumberOfDaysInPeriod := (SecondPeriodDate - FirstPeriodDate);

                AmountToDefer := Round(NumberOfDaysInPeriod * DailyDeferralAmount, AmountRoundingPrecision);
                RunningDeferralTotal := RunningDeferralTotal + AmountToDefer;
            end else begin
                // Get the starting date of the accounting period of the posting date is in
                FirstPeriodDate := GetCurPeriodStartingDate(PostDate);

                // Get the starting date of the next accounting period
                SecondPeriodDate := GetNextPeriodStartingDate(PostDate);

                NumberOfDaysInPeriod := (SecondPeriodDate - FirstPeriodDate);

                if PeriodicCount <> DeferralHeader."No. of Periods" then begin
                    // Not the last period
                    AmountToDefer := Round(NumberOfDaysInPeriod * DailyDeferralAmount, AmountRoundingPrecision);
                    RunningDeferralTotal := RunningDeferralTotal + AmountToDefer;
                end else
                    AmountToDefer := (DeferralHeader."Amount to Defer" - RunningDeferralTotal);
            end;

            DeferralLine."Posting Date" := PostDate;
            UpdateDeferralLineDescription(DeferralLine, DeferralHeader, PostDate);

            CheckPostingDate(DeferralHeader, DeferralLine);

            DeferralLine.Amount := AmountToDefer;

            OnCalculateDaysPerPeriodOnBeforeDeferralLineInsert(DeferralHeader, DeferralLine);
            DeferralLine.Insert();
        end;

        OnAfterCalculateDaysPerPeriod(DeferralHeader, DeferralLine);
    end;

    local procedure UpdateDeferralLineDescription(var DeferralLine: Record "MFCC01 Deferral Line"; DeferralHeader: Record "MFCC01 Deferral Header"; PostDate: Date)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDeferralLineDescription(DeferralLine, DeferralHeader, PostDate, IsHandled);
        if IsHandled then
            exit;

        DeferralLine.Description := CreateRecurringDescription(PostDate, '%5 %6');
    end;

    procedure FilterDeferralLines(var DeferralLine: Record "MFCC01 Deferral Line"; CustomerNo: Code[20]; DocumentNo: Code[20])
    begin
        DeferralLine.SetRange("Customer No.", CustomerNo);
        DeferralLine.SetRange("Document No.", DocumentNo);
    end;

    procedure IsDateNotAllowed(PostingDate: Date) Result: Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        IsHandled: Boolean;
    begin
        OnBeforeIsDateNotAllowed(PostingDate, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if UserId() <> '' then
            if UserSetup.Get(UserId()) then begin
                UserSetup.CheckAllowedDeferralPostingDates(1);
                AllowPostingFrom := UserSetup."Allow Deferral Posting From";
                AllowPostingTo := UserSetup."Allow Deferral Posting To";
            end;
        if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
            GeneralLedgerSetup.Get();
            GeneralLedgerSetup.CheckAllowedDeferralPostingDates(1);
            AllowPostingFrom := GeneralLedgerSetup."Allow Deferral Posting From";
            AllowPostingTo := GeneralLedgerSetup."Allow Deferral Posting To";
        end;
        if AllowPostingTo = 0D then
            AllowPostingTo := DMY2Date(31, 12, 9999);
        Result := not (PostingDate in [AllowPostingFrom .. AllowPostingTo]);
    end;

    local procedure SetStartDate(DeferralTemplate: Record "Deferral Template"; StartDate: Date) AdjustedStartDate: Date
    var
        AccountingPeriod: Record "Accounting Period";
        DeferralStartDate: Enum "Deferral Calculation Start Date";
    begin
        // "Start Date" passed in needs to be adjusted based on the Deferral Code's Start Date setting;
        case DeferralTemplate."Start Date" of
            DeferralStartDate::"Posting Date":
                AdjustedStartDate := StartDate;
            DeferralStartDate::"Beginning of Period":
                begin
                    if AccountingPeriod.IsEmpty() then
                        exit(CalcDate('<-CM>', StartDate));
                    AccountingPeriod.SetRange("Starting Date", 0D, StartDate);
                    if AccountingPeriod.FindLast() then
                        AdjustedStartDate := AccountingPeriod."Starting Date";
                end;
            DeferralStartDate::"End of Period":
                begin
                    if AccountingPeriod.IsEmpty() then
                        exit(CalcDate('<CM>', StartDate));
                    AccountingPeriod.SetFilter("Starting Date", '>%1', StartDate);
                    if AccountingPeriod.FindFirst() then
                        AdjustedStartDate := CalcDate('<-1D>', AccountingPeriod."Starting Date");
                end;
            DeferralStartDate::"Beginning of Next Period":
                begin
                    if AccountingPeriod.IsEmpty() then
                        exit(CalcDate('<CM + 1D>', StartDate));
                    AccountingPeriod.SetFilter("Starting Date", '>%1', StartDate);
                    if AccountingPeriod.FindFirst() then
                        AdjustedStartDate := AccountingPeriod."Starting Date";
                end;
            DeferralStartDate::"Beginning of Next Calendar Year":
                AdjustedStartDate := CalcDate('<CY + 1D>', StartDate);
        end;

        OnAfterSetStartDate(DeferralTemplate, StartDate, AdjustedStartDate);
    end;

    procedure SetDeferralRecords(var DeferralHeader: Record "MFCC01 Deferral Header"; CustomerNo: Code[20]; DocumentNo: Code[20]; NoOfPeriods: Integer; AdjustedDeferralAmount: Decimal; AdjustedStartDate: Date; DeferralDescription: Text[100]; AmountToDefer: Decimal; CurrencyCode: Code[10])
    begin
        if not DeferralHeader.Get(DocumentNo) then begin
            // Need to create the header record.

            DeferralHeader."Customer No." := CustomerNo;
            DeferralHeader."Document No." := DocumentNo;
            DeferralHeader.Insert();
        end;
        DeferralHeader."Amount to Defer" := AdjustedDeferralAmount;
        // if AdjustStartDate or (DeferralHeader."Initial Amount to Defer" = 0) then
        //     DeferralHeader."Initial Amount to Defer" := AmountToDefer;

        DeferralHeader."Start Date" := AdjustedStartDate;
        DeferralHeader."No. of Periods" := NoOfPeriods;
        DeferralHeader."Schedule Description" := DeferralDescription;
        DeferralHeader."Currency Code" := CurrencyCode;
        OnSetDeferralRecordsOnBeforeDeferralHeaderModify(DeferralHeader);
        DeferralHeader.Modify();
        // Remove old lines as they will be recalculated/recreated
        RemoveDeferralLines(CustomerNo, DocumentNo);
    end;

    local procedure RemoveDeferralLines(CustomerNo: Code[20]; DocumentNo: Code[20])
    var
        DeferralLine: Record "MFCC01 Deferral Line";
    begin
        FilterDeferralLines(DeferralLine, CustomerNo, DocumentNo);
        DeferralLine.DeleteAll();
    end;

    local procedure ValidateDeferralTemplate(DeferralTemplate: Record "Deferral Template")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateDeferralTemplate(DeferralTemplate, IsHandled);
        if IsHandled then
            exit;

        DeferralTemplate.TestField("Deferral Account");
        DeferralTemplate.TestField("Deferral %");
        DeferralTemplate.TestField("No. of Periods");
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
        AmountRoundingPrecision := Currency."Amount Rounding Precision";
    end;

    procedure InitializeDeferralHeaderAndSetPostDate(var DeferralLine: Record "MFCC01 Deferral Line"; DeferralHeader: Record "MFCC01 Deferral Header"; PeriodicCount: Integer; var PostDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        DeferralLine.Init();

        DeferralLine."Customer No." := DeferralHeader."Customer No.";
        DeferralLine."Document No." := DeferralHeader."Document No.";
        DeferralLine."Currency Code" := DeferralHeader."Currency Code";
        OnInitializeDeferralHeaderAndSetPostDateAfterInitDeferralLine(DeferralLine);

        if PeriodicCount = 1 then begin
            if not AccountingPeriod.IsEmpty() then begin
                AccountingPeriod.SetFilter("Starting Date", '..%1', DeferralHeader."Start Date");
                if not AccountingPeriod.FindFirst() then
                    Error(DeferSchedOutOfBoundsErr);
            end;
            PostDate := DeferralHeader."Start Date";
        end else begin
            if IsAccountingPeriodExist(AccountingPeriod, CalcDate('<CM>', PostDate) + 1) then begin
                AccountingPeriod.SetFilter("Starting Date", '>%1', PostDate);
                if not AccountingPeriod.FindFirst() then
                    Error(DeferSchedOutOfBoundsErr);
            end;
            PostDate := AccountingPeriod."Starting Date";
        end;
    end;

    local procedure IsAccountingPeriodExist(var AccountingPeriod: Record "Accounting Period"; PostingDate: Date): Boolean
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
    begin
        AccountingPeriod.Reset();
        if not AccountingPeriod.IsEmpty() then
            exit(true);

        AccountingPeriodMgt.InitDefaultAccountingPeriod(AccountingPeriod, PostingDate);
        exit(false);
    end;


    local procedure GetNextPeriodStartingDate(PostingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty() then
            exit(CalcDate('<CM+1D>', PostingDate));

        AccountingPeriod.SetFilter("Starting Date", '>%1', PostingDate);
        if AccountingPeriod.FindFirst() then
            exit(AccountingPeriod."Starting Date");

        Error(DeferSchedOutOfBoundsErr);
    end;

    local procedure GetCurPeriodStartingDate(PostingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty() then
            exit(CalcDate('<-CM>', PostingDate));

        AccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        AccountingPeriod.FindLast();
        exit(AccountingPeriod."Starting Date");
    end;

    local procedure GetDeferralDescription(Customerno: Code[20]; DocumentNo: Code[20]; Description: Text[100]) Result: Text[100]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDeferralDescription(Customerno, DocumentNo, Description, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if Customerno <> '' then
            exit(CopyStr(StrSubstNo(DescriptionTok, Customerno, Description), 1, 100));
        exit(CopyStr(StrSubstNo(DescriptionTok, DocumentNo, Description), 1, 100));
    end;

    procedure CreatedeferralScheduleFromAgreement(Var Agreementheader: Record "MFCC01 Agreement Header")
    var
        DeferralHeader: Record "MFCC01 Deferral Header";
        CZSetup: Record "MFCC01 Franchise Setup";
        Type: Enum "MFCC01 Deferral Type";
    begin
        Agreementheader.TestField(Status, Agreementheader.Status::Opened);
        CZSetup.GetRecordonce();
        IF (Agreementheader."FranchiseFeescheduleNo." = '') And (Agreementheader."Agreement Amount" <> 0) then Begin
            Type := Type::"Franchise Fee";
            IF Agreementheader."License Type" = Agreementheader."License Type"::Transferred then
                Type := Type::Transferred;
            CreateDeferralHeader(DeferralHeader, Agreementheader, CZSetup, Type);
            DeferralHeader.CalculateSchedule();
            DeferralHeader.Status := DeferralHeader.Status::Open;
            DeferralHeader.Modify();
            Agreementheader."FranchiseFeescheduleNo." := DeferralHeader."Document No.";
        End;

        IF (Agreementheader."CommissionScheduleNo." = '') and (Agreementheader."SalesPerson Commission" <> 0) then Begin
            Type := Type::Commission;
            CreateDeferralHeader(DeferralHeader, Agreementheader, CZSetup, Type);
            DeferralHeader.CalculateSchedule();
            DeferralHeader.Status := DeferralHeader.Status::Open;
            DeferralHeader.Modify();
            Agreementheader."CommissionScheduleNo." := DeferralHeader."Document No.";
        End;

        Agreementheader.Modify();
    end;

    procedure CreatedeferralScheduleFromRenewal(Var Renewal: Record "MFCC01 Agreement Renewal")
    var
        DeferralHeader: Record "MFCC01 Deferral Header";
        AgreementHeader: Record "MFCC01 Agreement Header";
        CZSetup: Record "MFCC01 Franchise Setup";
    begin

        CZSetup.GetRecordonce();
        IF (Renewal."RenewalscheduleNo." = '') And (Renewal."Renewal Fees" <> 0) then Begin
            AgreementHeader.Get(Renewal."Agreement No.");
            CreateDeferralHeader(DeferralHeader, Renewal, CZSetup, AgreementHeader);
            DeferralHeader.CalculateSchedule();
            DeferralHeader.Status := DeferralHeader.Status::Open;
            DeferralHeader.Modify();
            Renewal."RenewalscheduleNo." := DeferralHeader."Document No.";
            Renewal.Modify();

            AgreementHeader."RenewalFeescheduleNo." := DeferralHeader."Document No.";
            AgreementHeader."Renewal No. of Periods" := Renewal."No. of Periods";
            AgreementHeader.Modify();
        End;

    end;

    local procedure CreateDeferralHeader(var DeferralHeader: Record "MFCC01 Deferral Header"; Agreementheader: Record "MFCC01 Agreement Header"; CZSetup: Record "MFCC01 Franchise Setup"; Type: Enum "MFCC01 Deferral Type")

    begin
        DeferralHeader.Init();
        DeferralHeader."Document No." := '';
        DeferralHeader.Insert(true);
        DeferralHeader."Start Date" := Agreementheader."Franchise Revenue Start Date";
        DeferralHeader.Validate("End Date", Agreementheader."Term Expiration Date");
        DeferralHeader.Type := Type;
        IF (Type = Type::"Franchise Fee")OR(Type=Type::Transferred) then
            DeferralHeader.validate("Amount to Defer", Agreementheader."Agreement Amount");
        IF Type = Type::Commission then
            DeferralHeader.validate("Amount to Defer", Agreementheader."SalesPerson Commission");
        DeferralHeader."Agreement No." := Agreementheader."No.";
        DeferralHeader."Customer No." := Agreementheader."Customer No.";
        //DeferralHeader.Commision := Commision;
        DeferralHeader.Modify(true)

    end;


    local procedure CreateDeferralHeader(var DeferralHeader: Record "MFCC01 Deferral Header"; Renewal: Record "MFCC01 Agreement Renewal"; CZSetup: Record "MFCC01 Franchise Setup"; Agreementheader: Record "MFCC01 Agreement Header")

    begin
        DeferralHeader.Init();
        DeferralHeader."Document No." := '';
        DeferralHeader.Insert(true);
        DeferralHeader."Start Date" := Renewal."Effective Date";
        DeferralHeader.Validate("End Date", Renewal."Term Expiration Date");
        DeferralHeader.validate("Amount to Defer", Renewal."Renewal Fees");
        DeferralHeader."Agreement No." := Agreementheader."No.";
        DeferralHeader."Customer No." := Agreementheader."Customer No.";
        DeferralHeader.Type := DeferralHeader.Type::Renewal;
        DeferralHeader.Modify(true)

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateDaysPerPeriod(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateEqualPerPeriod(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateStraightline(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateUserDefined(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDeferralSchedule(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;



    [IntegrationEvent(false, false)]
    local procedure OnAfterSetStartDate(DeferralTemplate: Record "Deferral Template"; var StartDate: Date; var AdjustedStartDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateDaysPerPeriod(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateEqualPerPeriod(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateStraightline(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateUserDefined(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDeferralSchedule(CustomerNo: Code[20]; DocumentNo: Code[20]; AmountToDefer: Decimal; StartDate: Date; NoOfPeriods: Integer; ApplyDeferralPercentage: Boolean; DeferralDescription: Text[100]; CurrencyCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeferralCodeOnValidate(customerno: Code[20]; DocumentNo: Code[20]; Amount: Decimal; PostingDate: Date; Description: Text[100]; CurrencyCode: Code[10]; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterAdjustTotalAmountForDeferrals(var AmtToDefer: Decimal; var AmtToDeferACY: Decimal; var TotalAmount: Decimal; var TotalAmountACY: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcDeferralNoOfPeriods(var NoOfPeriods: Integer; StartDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPostingDate(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: record "MFCC01 Deferral Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDeferralDescription(Customerno: Code[10]; DocumentNo: Code[20]; Description: Text[100]; var Result: Text[100]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateEqualPerPeriodOnBeforeDeferralLineInsert(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateStraightlineOnAfterCalcSecondPeriodDate(DeferralHeader: Record "MFCC01 Deferral Header"; PostDate: Date; var FirstPeriodDate: Date; var SecondPeriodDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateStraightlineOnBeforeDeferralLineInsert(var DeferralLine: Record "MFCC01 Deferral Line"; DeferralHeader: Record "MFCC01 Deferral Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateStraightlineOnBeforeCalcPeriodicDeferralAmount(var DeferralHeader: Record "MFCC01 Deferral Header"; var PeriodicDeferralAmount: Decimal; AmountRoundingPrecision: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateDaysPerPeriodOnAfterCalcEndDate(var DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: Record "MFCC01 Deferral Line"; var EndDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateDaysPerPeriodOnBeforeDeferralLineInsert(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateUserDefinedOnBeforeDeferralLineInsert(DeferralHeader: Record "MFCC01 Deferral Header"; var DeferralLine: record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetDeferralRecordsOnBeforeDeferralHeaderModify(var DeferralHeader: Record "MFCC01 Deferral Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsDateNotAllowed(PostingDate: Date; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDeferralLineDescription(var DeferralLine: Record "MFCC01 Deferral Line"; DeferralHeader: Record "MFCC01 Deferral Header"; PostDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDeferralTemplate(DeferralTemplate: Record "Deferral Template"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeDeferralHeaderAndSetPostDateAfterInitDeferralLine(var DeferralLine: Record "MFCC01 Deferral Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenLineScheduleEditOnBeforeDeferralScheduleSetParameters(var DeferralSchedule: Page "MFCC01 DeferralSchedule"; Customerno: COde[20]; DocumentNo: Code[20]; DeferralHeader: Record "MFCC01 Deferral Header"; var IsHandled: Boolean)
    begin
    end;
}

