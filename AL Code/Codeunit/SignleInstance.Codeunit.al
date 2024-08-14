codeunit 60019 "MFCC01 Single Instance"
{
    SingleInstance = true;

    procedure SetUseCurretnDate(NewUseCurrentDate: Boolean)
    begin
        UseCurrentDate := NewUseCurrentDate;
    end;


    procedure GetUseCurretnDate(): Boolean
    begin
        Exit(UseCurrentDate);
    end;

    var
        UseCurrentDate: Boolean;


}