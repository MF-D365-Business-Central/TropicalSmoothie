tableextension 60001 "MFCC01 Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here

        field(60001; "Agreement No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MFCC01 Agreement Header"."No.";
        }
        field(60003; "Approver ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60004; "Cafe No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            trigger OnValidate()
            Begin
                // IF xRec."Cafe No." <> Rec."Cafe No." then
                //     CopyCustomerDefaultDimensions();
            End;
        }
        modify("Recipient Bank Account")
        {
            trigger OnAfterValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
            begin
                Case True of
                    Rec."Account Type" = Rec."Account Type"::Vendor:
                        IF VendorBankAccount.Get(Rec."Account No.", Rec."Recipient Bank Account") then
                            VendorBankAccount.TestField(Status, VendorBankAccount.Status::Released);
                    Rec."Bal. Account Type" = Rec."Bal. Account Type"::Vendor:
                        IF VendorBankAccount.Get(Rec."Bal. Account No.", Rec."Recipient Bank Account") then
                            VendorBankAccount.TestField(Status, VendorBankAccount.Status::Released);
                End;
            end;
        }
        field(60005; "Description 2"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    local procedure CopyCustomerDefaultDimensions()
    var
        Customer: Record Customer;
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionSetEntry: Record "Dimension Set Entry";
        DefDimension: Record "Default Dimension";
        DimMgmt: Codeunit DimensionManagement;
    begin
        IF Rec."Line No." = 0 then
            Exit;
        TempDimensionSetEntry.DeleteAll();
        IF Customer.Get(Rec."Cafe No.") then Begin
            DimensionSetEntry.SetRange("Dimension Set ID", Rec."Dimension Set ID");
            IF DimensionSetEntry.FindSet() then
                repeat
                    TempDimensionSetEntry.Init();
                    TempDimensionSetEntry.Validate("Dimension Code", DimensionSetEntry."Dimension Code");
                    TempDimensionSetEntry.Validate("Dimension Value Code", DimensionSetEntry."Dimension Value Code");
                    TempDimensionSetEntry.insert();
                Until DimensionSetEntry.Next() = 0;
            DefDimension.Reset();
            DefDimension.SetRange("Table ID", Database::Customer);
            DefDimension.SetRange("No.", Customer."No.");
            DefDimension.Setfilter("Dimension Value Code", '<>%1', '');
            IF DefDimension.FindSet() then
                repeat
                    TempDimensionSetEntry.Reset();
                    TempDimensionSetEntry.SetRange("Dimension Code", DefDimension."Dimension Code");
                    TempDimensionSetEntry.SetRange("Dimension Value Code", DefDimension."Dimension Value Code");
                    IF Not TempDimensionSetEntry.FindFirst() then Begin
                        TempDimensionSetEntry.Init();
                        TempDimensionSetEntry.Validate("Dimension Code", DefDimension."Dimension Code");
                        TempDimensionSetEntry.Validate("Dimension Value Code", DefDimension."Dimension Value Code");
                        TempDimensionSetEntry.insert();
                    End;
                until DefDimension.Next() = 0;

            Rec.Validate("Dimension Set ID", DimMgmt.GetDimensionSetID(TempDimensionSetEntry));
        End;
    end;
}