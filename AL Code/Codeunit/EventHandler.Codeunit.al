codeunit 60005 "Event handler"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", OnAfterCopyGLEntryFromGenJnlLine, '', false, false)]
    local procedure OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        FixedAsset: Record "Fixed Asset";
    begin
        GLEntry."Agreement No." := GenJournalLine."Agreement No.";
        Case GLEntry."Source Type" of

            GLEntry."Source Type"::"Bank Account":
                Begin
                    BankAccount.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := BankAccount.Name;
                End;
            GLEntry."Source Type"::Customer:
                Begin
                    Customer.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Customer.Name;
                End;
            GLEntry."Source Type"::Employee:
                Begin
                    Employee.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Employee.FullName();
                End;
            GLEntry."Source Type"::"Fixed Asset":
                Begin
                    FixedAsset.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := FixedAsset.Description;
                End;
            GLEntry."Source Type"::Vendor:
                Begin
                    Vendor.Get(GLEntry."Source No.");
                    GLEntry."Source Name" := Vendor.Name;
                End;
        End;
    end;


}