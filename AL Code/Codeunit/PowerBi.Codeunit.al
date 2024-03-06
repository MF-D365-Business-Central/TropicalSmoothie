codeunit 60006 "MFCC01 PowerBI Integration"
{
    Permissions = tabledata "MFCC01 Snowflake Entry" = RMID;
    trigger OnRun()
    begin
    end;

    procedure NetSales(response: Text): Text
    var
        JObj: JsonObject;
        JLnArr: JsonArray;
        JTok: JsonToken;
    begin
        Error(response);
        GetLastEntry();
        response := response.Replace('\', '');
        response := response.Replace('"[{"', '[{"');
        response := response.Replace('"}]"', '"}]');
        IF not JLnArr.ReadFrom(response) then Begin
            Error(response);
        End;
        Error(response);
        InsertLns(JLnArr);//Write Lines
        JLnArr.WriteTo(response);
        Exit(response);
    end;

    procedure NetSales2(response: Text): Text
    var
        JObj: JsonObject;
        JLnArr: JsonArray;
        JTok: JsonToken;
        JsonBuff: Record "JSON Buffer" temporary;
        Name: Text;
    begin

        GetLastEntry();
        response := response.Replace('\', '');
        response := response.Replace('"[{"', '[{"');
        response := response.Replace('"}]"', '"}]');
        IF not JLnArr.ReadFrom(response) then Begin
            Error(response);
        End;
        JsonBuff.ReadFromText(response);
        IF JsonBuff.FindSet() then
            repeat
                Name := JsonBuff.Path;
            Until JsonBuff.Next() = 0;

        InsertLns(JLnArr);//Write Lines
        JLnArr.WriteTo(response);
        Exit(response);
    end;

    procedure InsertLns(JArr: JsonArray)
    var
        JTok: JsonToken;
        JsonObj: JsonObject;
        J: JsonValue;
        LJTok: List of [JsonToken];
        Counter: Integer;
        I: Integer;
        Result: JsonToken;
    begin
        foreach JTok in JArr do
            if JTok.IsObject then
                JsonObj := JTok.AsObject();
        LJTok := JsonObj.Values;
        Counter := LJTok.Count;

        for i := 1 to Counter Do Begin
            LJTok.Get(i, Result);
        End;

    end;

    procedure GetJsonToken(jObject: JsonObject;
        TokenKey: text) jToken: JsonToken
    begin
        if not jObject.Get(TokenKey, jToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    local procedure InsertLn(JObj: JsonObject)
    var
        LineDictionary: Dictionary of [Text, Text];
    Begin
        FillDictionary(JObj, LineDictionary);
        CreateSnowflakeEntries(LineDictionary);
    End;

    local procedure FillDictionary(paramJoLine: JsonObject; var LnDictionary: Dictionary of [Text, Text]);
    begin
        LnDictionary.Add('STORE_NUMBER', ReadJsonNodeValue(paramJoLine, '$.STORE_NUMBER'));
        LnDictionary.Add('DATE', ReadJsonNodeValue(paramJoLine, '$.DATE'));
        LnDictionary.Add('NET_SALES', ReadJsonNodeValue(paramJoLine, '$.NET_SALES'));
    end;

    procedure ReadJsonNodeValue(paramjObject: JsonObject; paramjQuery: Text): Text
    var
        selectedToken: JsonToken;
    begin
        if paramjObject.SelectToken(paramjQuery, selectedToken) then
            if not selectedToken.AsValue().IsNull() then
                exit(format(selectedToken.AsValue().AsText()));
        exit('');
    end;


    local procedure CreateSnowflakeEntries(LineDictionary: Dictionary of [Text, Text])
    var
        SnowflakeEntry: Record "MFCC01 Snowflake Entry";
    begin
        SnowflakeEntry.Init();
        SnowflakeEntry."Entry No." := LineNo;
        SnowflakeEntry."Customer No." := LineDictionary.Get('STORE_NUMBER');
        Evaluate(SnowflakeEntry."Document Date", LineDictionary.Get('DATE'));
        Evaluate(SnowflakeEntry."Net Sales", LineDictionary.Get('NET_SALES'));
        SnowflakeEntry.Insert();
        LineNo += 1;
    end;

    local procedure GetLastEntry()
    var
        SnowflakeEntry: Record "MFCC01 Snowflake Entry";
    begin
        SnowflakeEntry.Reset;
        IF SnowflakeEntry.FindLast() then;

        LineNo := SnowflakeEntry."Entry No." + 1;
    end;

    procedure Validatedata()
    var
        SnowflakeEntry: Record "MFCC01 Snowflake Entry";
        Customer: Record Customer;
        Window: Dialog;

    begin
        Window.Open('Processing Data..');
        SnowflakeEntry.Reset();
        SnowflakeEntry.SetFilter(Status, '%1|%2', SnowflakeEntry.Status::New, SnowflakeEntry.Status::Error);
        IF SnowflakeEntry.FindSet(true) then
            repeat
                SnowflakeEntry.Remarks := '';
                IF Not Customer.get(SnowflakeEntry."Customer No.") then
                    SnowflakeEntry.Remarks := 'Customer does not exist';

                IF Not GetAgreement(SnowflakeEntry."Customer No.", SnowflakeEntry."Document Date") then
                    SnowflakeEntry.Remarks += ' Agreement does not exist'
                else
                    if not GetAgreementLine(SnowflakeEntry."Customer No.", SnowflakeEntry."Document Date") then
                        SnowflakeEntry.Remarks += ' Royalty % does not exist';
                IF SnowflakeEntry."Net Sales" = 0 then
                    SnowflakeEntry.Remarks += ' Net Sales must not be Zero';
                IF SnowflakeEntry.Remarks <> '' then
                    SnowflakeEntry.Status := SnowflakeEntry.Status::Error
                else
                    SnowflakeEntry.Status := SnowflakeEntry.Status::Validated;
                SnowflakeEntry.Modify();
            Until SnowflakeEntry.Next() = 0;
        Window.Close();
    end;

    procedure Processdata()
    var
        SnowflakeEntry: Record "MFCC01 Snowflake Entry";
        Customer: Record Customer;
        Frantach: Record "MFCC01 Franchise Batch";
        Window: Dialog;
    begin
        Window.Open('Processing Data..');
        CZSetup.GetRecordonce();
        CZSetup.TestField("Franchise Journal Batch");
        BatchName := CZSetup."Franchise Journal Batch";
        Frantach.SetRange(Code, BatchName);
        Frantach.FindFirst();
        NoSeriesCode := Frantach."No. Series";
        InitLineno();
        SnowflakeEntry.Reset();
        SnowflakeEntry.Setrange(Status, SnowflakeEntry.Status::Validated);
        IF SnowflakeEntry.FindSet(true) then
            repeat
                SnowflakeEntry.Remarks := '';
                CreateFanchiseJournal(SnowflakeEntry."Customer No.", SnowflakeEntry."Document Date", SnowflakeEntry."Net Sales");
                SnowflakeEntry.Status := SnowflakeEntry.Status::Processed;
                SnowflakeEntry.Modify();
            Until SnowflakeEntry.Next() = 0;
        Window.Close();
    end;

    local procedure GetAgreement(CustomerNo: Code[20]; DocDate: Date): Boolean
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        AgreementNo: Code[20];
    begin
        AgreementHeader.Reset();
        AgreementHeader.SetRange("Customer No.", CustomerNo);
        AgreementHeader.SetRange(Status, AgreementHeader.Status::Terminated);
        AgreementHeader.SetFilter("Termination Date", '>=%1', DocDate);
        IF AgreementHeader.FindFirst() then
            AgreementNo := AgreementHeader."No."
        Else Begin
            AgreementHeader.SetRange(Status, AgreementHeader.Status::Opened);
            AgreementHeader.SetRange("Termination Date");
            IF AgreementHeader.FindFirst() then
                AgreementNo := AgreementHeader."No.";
        End;

        IF AgreementNo = '' then
            Exit(false);

        Exit(true);
    end;

    // local procedure GetAgreementLine(CustomerNo: Code[20]; DocDate: Date): Boolean
    // var
    //     AgreementHeader: Record "MFCC01 Agreement Header";
    //     AgreementLine: Record "MFCC01 Agreement Line";
    // begin
    //     AgreementHeader.SetRange("Customer No.", CustomerNo);
    //     AgreementHeader.SetRange(Status, AgreementHeader.Status::Opened);
    //     AgreementHeader.FindFirst();

    //     AgreementLine.SetRange("Agreement No.", AgreementHeader."No.");
    //     AgreementLine.SetFilter("Starting Date", '<=%1|%2', DocDate, 0D);
    //     AgreementLine.SetFilter("Ending Date", '>=%1|%2', DocDate, 0D);
    //     IF not AgreementLine.Findlast() then
    //         Exit(false);

    //     Exit(true);
    // end;

    local procedure GetAgreementLine(CustomerNo: Code[20]; DocDate: Date): Boolean
    var
        AgreementHeader: Record "MFCC01 Agreement Header";
        AgreementLine: Record "MFCC01 Agreement Line";
        AgreementNo: Code[20];
    begin
        AgreementHeader.Reset();
        AgreementHeader.SetRange("Customer No.", CustomerNo);
        AgreementHeader.SetRange(Status, AgreementHeader.Status::Terminated);
        AgreementHeader.SetFilter("Termination Date", '>=%1', DocDate);
        IF AgreementHeader.FindFirst() then
            AgreementNo := AgreementHeader."No."
        Else Begin
            AgreementHeader.SetRange(Status, AgreementHeader.Status::Opened);
            AgreementHeader.SetRange("Termination Date");
            IF AgreementHeader.FindFirst() then
                AgreementNo := AgreementHeader."No.";
        End;

        IF AgreementNo = '' then
            Exit(False);
        AgreementLine.SetRange("Agreement No.", AgreementNo);
        AgreementLine.SetFilter("Starting Date", '<=%1|%2', DocDate, 0D);
        AgreementLine.SetFilter("Ending Date", '>=%1|%2', DocDate, 0D);
        IF Not AgreementLine.Findlast then
            Exit(false);
        Exit(true);
    end;


    local procedure CreateFanchiseJournal(CustomerNo: Code[20]; DocDate: Date; NetSales: Decimal)
    var
        FrachJnl: Record "MFCC01 Franchise Journal";
        LastFrachJnl: Record "MFCC01 Franchise Journal";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
    begin
        LastFrachJnl.SetRange("Batch Name", BatchName);
        if LastFrachJnl.FindFirst() then;

        FrachJnl.Init();
        FrachJnl."Batch Name" := BatchName;
        //FrachJnl.SetUpNewLine(LastFrachJnl, true);
        FrachJnl."Document No." := NoSeriesMgmt.GetNextNo(NoSeriesCode, WorkDate(), True);
        FrachJnl."Document Type" := FrachJnl."Document Type"::Invoice;
        FrachJnl."Document Date" := DocDate;
        FrachJnl."Posting Date" := CalcDate('<CW>', DocDate);
        FrachJnl."Line No." := LineNo;
        LineNo += 10000;
        FrachJnl.Insert();
        FrachJnl.Validate("Customer No.", CustomerNo);
        FrachJnl.Validate("Net Sales", NetSales);
        FrachJnl.Modify(true);
    end;

    local procedure SetBatchName(CurrentBatchName: Code[20])
    begin
        BatchName := CurrentBatchName;
    end;

    local procedure InitLineno()
    var
        FrachJnl: Record "MFCC01 Franchise Journal";
    begin
        FrachJnl.Setrange("Batch Name", BatchName);
        IF FrachJnl.FindLast() then;
        LineNo := FrachJnl."Line No." + 10000;
    end;

    var
        CZSetup: Record "MFCC01 Franchise Setup";
        BatchName: Code[20];
        NoSeriesCode: Code[20];
        LineNo: Integer;
}