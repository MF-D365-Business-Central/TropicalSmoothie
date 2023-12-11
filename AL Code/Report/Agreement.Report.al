report 60010 "Agreements"
{
    Caption = 'Agreement Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = DefaultAgreement;

    dataset
    {
        dataitem("MFCC01 Agreement Header"; "MFCC01 Agreement Header")
        {
            RequestFilterFields = "No.";
            column(No_MFCC01AgreementHeader; "No.")
            {
            }
            column(CustomerNo_MFCC01AgreementHeader; "Customer No.")
            {
            }
            column(Status_MFCC01AgreementHeader; Status)
            {
            }
            column(LicenseType_MFCC01AgreementHeader; "License Type")
            {
            }
            column(AgreementDate_MFCC01AgreementHeader; "Agreement Date")
            {
            }
            column(FranchiseRevenueStartDate_MFCC01AgreementHeader; "Franchise Revenue Start Date")
            {
            }
            column(TermExpirationDate_MFCC01AgreementHeader; "Term Expiration Date")
            {
            }
            column(RenewalStatus; Renewal.Status)
            { }
            column(RenewalDate; Renewal."Renewal Date")
            { }

            ///
            column(AgreementNoLbl; AgreementNoLbl)
            { }
            column(CafeLbl; CafeLbl)
            { }
            column(StatusLbl; StatusLbl)
            { }
            column(LicenseTypeLbl; LicenseTypeLbl)
            { }
            column(AgreementdateLbl; AgreementdateLbl)
            { }
            column(StartdateLbl; StartdateLbl)
            { }
            column(EnddateLbl; EnddateLbl)
            { }
            column(OpendateLbl; OpendateLbl)
            { }
            column(TermdateLbl; TermdateLbl)
            { }
            column(RenewaldateLbl; RenewaldateLbl)
            { }
            column(ownerLbl; ownerLbl)
            { }
            column(emailLbl; emailLbl)
            { }
            column(RoyaltystartingdateLbl; RoyaltystartingdateLbl)
            { }
            column(RoyaltyendingdateLbl; RoyaltyendingdateLbl)
            { }
            column(royaltypercentageactiveoneLbl; royaltypercentageactiveoneLbl)
            { }
            column(nationaladfeeLbl; nationaladfeeLbl)
            { }
            column(localadfundfeeLbl; localadfundfeeLbl)
            { }
            column(OwnerFirstName_MFCC01AgreementUsers; AgreementUsers."Owner First Name")
            {
            }
            column(OwnerLastName_MFCC01AgreementUsers; AgreementUsers."Owner Last Name")
            {
            }
            column(EMail_MFCC01AgreementUsers; AgreementUsers."E-Mail")
            {
            }
            column(TerminationDate_MFCC01AgreementHeader; "Termination Date")
            {
            }
            dataitem("MFCC01 Agreement Line"; "MFCC01 Agreement Line")
            {
                DataItemLink = "Agreement No." = field("No.");


                column(StartingDate_MFCC01AgreementLine; "Starting Date")
                {
                }
                column(EndingDate_MFCC01AgreementLine; "Ending Date")
                {
                }
                column(RoyaltyFees_MFCC01AgreementLine; "Royalty Fees %")
                {
                }
                column(NationalFees_MFCC01AgreementLine; "National Fees %")
                {
                }
                column(LocalFees_MFCC01AgreementLine; "Local Fees %")
                {
                }
            }
            trigger OnAfterGetRecord()
            Begin
                AgreementUsers.SetRange("Agreement No.", "MFCC01 Agreement Header"."No.");
                IF AgreementUsers.FindFirst() then;


                Renewal.SetRange("Agreement No.", "MFCC01 Agreement Header"."No.");
                Renewal.SetRange(Status, Renewal.Status::Renewed);
                IF Renewal.FindFirst() then;
            End;

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {

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
    }

    rendering
    {
        layout(DefaultAgreement)
        {
            Type = RDLC;
            LayoutFile = './AL Code/Report/Layout/Agreement.rdl';
        }
    }

    var
        Renewal: Record "MFCC01 Agreement Renewal";
        AgreementUsers: Record "MFCC01 Agreement Users";
        AgreementNoLbl: Label 'Agreement no.';
        CafeLbl: Label 'Café';
        StatusLbl: Label 'Status';
        LicenseTypeLbl: Label 'Lincense Type';
        AgreementdateLbl: Label 'Agreement date';
        StartdateLbl: Label 'Start date';
        EnddateLbl: Label 'End date';
        OpendateLbl: Label 'Open date';
        TermdateLbl: Label 'Term date';
        RenewaldateLbl: Label 'Renewal date';
        ownerLbl: Label 'owner';
        emailLbl: Label 'email';
        RoyaltystartingdateLbl: Label 'Royalty starting date';
        RoyaltyendingdateLbl: Label 'Royalty ending date';
        royaltypercentageactiveoneLbl: Label 'royalty percentage (active one)';
        nationaladfeeLbl: Label 'national ad fee %';
        localadfundfeeLbl: Label 'local ad fund fee %';


}