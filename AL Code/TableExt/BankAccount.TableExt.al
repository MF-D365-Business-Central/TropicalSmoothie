tableextension 60005 "MFCC01Bank Account Ext" extends "Bank Account"
{
    fields
    {
        field(80000; "E-Recevbl Exp. File Name"; Text[50])
        {
            Caption = 'E-Receivables Export File Name';
            DataClassification = CustomerContent;
        }
        field(80001; "Receivables Export Format"; Code[20])
        {
            Caption = 'Receivables Export Format';
            DataClassification = CustomerContent;
            TableRelation = "Bank Export/Import Setup".Code;
        }
        field(80003; "EFT Export Code Format"; Code[20])
        {
            Caption = 'EFT IAT Receivables Export Format';
            DataClassification = CustomerContent;
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST("Export-EFT"));
        }
    }
}