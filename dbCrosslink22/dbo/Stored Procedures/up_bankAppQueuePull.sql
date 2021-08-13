








CREATE procedure [dbo].[up_bankAppQueuePull]
    @bankId char(1)
,   @batchSize int

as

declare @ts datetime
declare @bapps table(
    BankAppID int 
)

set nocount on

    set @ts = getdate()

    if @batchSize is null
        set @batchSize = 0

    set rowcount @batchSize

    -- Get the Republic apps
    if isnull(@bankId,'R') = 'R'
        begin 
            insert @bapps
                select
                    a.BankAppID
                from
                    (
                        select     
                            rba.Republic_BankAppID BankAppID
                        ,   row_number() over (partition by rba.EfinID order by rba.Republic_BankAppID desc) AS 'RowNumber' 
                        from          
                            dbo.Republic_BankApp rba
                        where
                            rba.Delivered = 1
                            and rba.[Sent] = 0
                    ) a 
                where
                    a.RowNumber = 1

            update rba
                set rba.[Sent] = 1
            ,   rba.SentDate = @ts
            from
                dbo.Republic_BankApp rba join @bapps a on rba.Republic_BankAppID = a.BankAppID

            select
                rba.Republic_BankAppID
            ,   rba.EfinID
            ,   rba.UserID
            ,   rba.[Master]
            ,   rba.OfficeName
            ,   rba.OfficePhysicalStreet
            ,   rba.OfficePhysicalCity
            ,   rba.OfficePhysicalState
            ,   rba.OfficePhysicalZip
            ,   rba.OfficeContactFirstName
            ,   rba.OfficeContactLastName
            ,   rba.AlternateOffice1FirstName
            ,   rba.AlternateOffice1LastName
            ,   rba.AlternateOfficeContact1Email
            ,   rba.OfficePhoneNumber
            ,   rba.CellPhoneNumber
            ,   rba.FaxNumber
            ,   rba.EmailAddress
            ,   rba.OwnerFirstName
            ,   rba.OwnerLastName
            ,   rba.OwnerSSN
            ,   rba.OwnerDOB
            ,   rba.EfinOwnerFirstName
            ,   rba.EfinOwnerLastName
            ,   rba.OwnerHomePhone
            ,   rba.OwnerAddress
            ,   rba.OwnerCity
            ,   rba.OwnerState
            ,   rba.OwnerZip
            ,   rba.IRSTransmittingOfficeInd
            ,   rba.ComplianceWithLawInd
            ,   rba.YearsInBusiness
            ,   rba.LastYearBankProducts
            ,   rba.BankProductFacilitator
            ,   rba.CardProgram
            ,   rba.MultiOffice
            ,   rba.TaxPrepLicensing
            ,   rba.ActualNumberBankProducts
            ,   rba.DocumentStorageInd
            ,   rba.CheckCardStorageInd
            ,   rba.EfinOwnerSSN
            ,   rba.TransmitterFeeDefault
            ,   rba.OfficeDoorInd
            ,   rba.DocumentAccessInd
            ,   rba.SensitiveDocumentDestInd
            ,   rba.LoginPassInd
            ,   rba.AntiVirusInd
            ,   rba.FirewallInd
            ,   rba.ProductTrainingInd
            ,   rba.PreviousViolationFineInd
            ,   rba.NumOfPersonnel
            ,   rba.LegalEntityStatusInd
			,	rba.WirelessInd
            ,   rba.LLCMembershipRegistration
            ,   rba.FulfillmentShippingStreet
            ,   rba.FulfillmentShippingCity
            ,   rba.FulfillmentShippingState
            ,   rba.FulfillmentShippingZip
            ,   rba.OfficeManagerFirstName
            ,   rba.OfficeManagerLastName
            ,   rba.OfficeManagerSSN
            ,   rba.OfficeManagerDOB
            ,   rba.MailingAddress
            ,   rba.MailingCity
            ,   rba.MailingState
            ,   rba.MailingZip
            ,   rba.OfficeContactSSN
            ,   rba.AlternateOfficeContact1SSN
            ,   rba.EFINOwnerDOB
            ,   rba.PTINInd
            ,   rba.AdvertisingInd
            ,   rba.WebsiteAddress
            ,   rba.FeeRoutingNumber
            ,   rba.FeeAccountNumber
            ,   rba.FeeAccountType
			,	rba.FeeAccountName
            ,   rba.Delivered
            ,   rba.Sent
            ,   rba.AgreeBank
            ,   rba.AgreeDate
            ,   rba.DeliveredDate
            ,   rba.SentDate
            ,   rba.UpdatedBy
            ,   rba.UpdatedDate
            ,   rba.Deleted
            ,   rba.SubmittedRecordType
            ,   rba.Roll
            ,   rba.PEITechFee
            ,   rba.PEIRALTransmitterFee
            ,   rba.EROTranFee
            ,   rba.SBPrepFee
            ,   rba.FeeAgree
            ,   rba.FeeAgreeDate
            ,   rba.PEIAgree
            ,   rba.PEIAgreeDate
            ,   rba.CheckStockID
            ,   rba.DebitProgramInd
            ,   rba.EIN
            ,   rba.PriorYearEFIN
            ,   rba.SupportedOsInd
			,	rba.MinorityOwnedInd
			,	rba.WomenOwnedInd
			,	rba.DisabilityOwnedInd
			,	rba.VeteranOwnedInd
			,	rba.OfficeStructureInd
			,	rba.MobileSoftwareInd
			,	rba.eSignConsent
			,	rba.eSignConsentDate
			,	rba.IPAddress
			,	rba.RejectRate
			,	rba.LossRate
			,	rba.FundingRate
			,	rba.EFINOwnerTaxReturnFirstName
			,	rba.EFINOwnerTaxReturnLastName
			,	rba.EFINOwnerTaxReturnTIN
			,	rba.EFINOwnerTaxReturnCert
			,	rba.IRSEFINValidInd
			,	rba.NetTranFee
			,	rba.PriorYearRejected
			,	rba.PriorYearAccepted
			,	rba.AgreeBy
			,	rba.CPTSAdminFee
			,	rba.PriorYearAck1040
			,	rba.PriorYearFunded1040
			,	rba.PriorYearLoansApproved
			,	rba.PriorYearLoansFunded
			,	rba.SPAInd
			,	rba.RequestedSPAAmount
			,	rba.SPAAgreeDate
			,	rba.EFFee
			,	rba.NetEFFee
			,	rba.CPTSAdminEFFee
			,	rba.SBFeeAll
			,	rba.EFFeeAll
			,	rba.IncorporatedDate
            from
                dbo.Republic_BankApp rba join @bapps a on rba.Republic_BankAppID = a.BankAppID

       end

    -- Get the Refundo apps
    if isnull(@bankId,'F') = 'F'
        begin 
            insert @bapps
                select
                    a.BankAppID
                from
                    (
                        select     
                            fba.Refundo_BankAppID BankAppID
                        ,   row_number() over (partition by fba.EfinID order by fba.Refundo_BankAppID desc) AS 'RowNumber' 
                        from          
                            dbo.Refundo_BankApp fba
                        where
                            fba.Delivered = 1
                            and fba.[Sent] = 0
                    ) a 
                where
                    a.RowNumber = 1

            update fba
                set fba.[Sent] = 1
            ,   fba.SentDate = @ts
            from
                dbo.Refundo_BankApp fba join @bapps a on fba.Refundo_BankAppID = a.BankAppID

            select
                fba.Refundo_BankAppID
            ,   fba.EfinID
            ,   fba.UserID
            ,   fba.[Master]
            ,   fba.OfficeName
            ,   fba.OfficePhysicalStreet
            ,   fba.OfficePhysicalCity
            ,   fba.OfficePhysicalState
            ,   fba.OfficePhysicalZip
            ,   fba.OfficeContactFirstName
            ,   fba.OfficeContactLastName
            ,   fba.AlternateOffice1FirstName
            ,   fba.AlternateOffice1LastName
            ,   fba.AlternateOfficeContact1Email
            ,   fba.OfficePhoneNumber
            ,   fba.CellPhoneNumber
            ,   fba.FaxNumber
            ,   fba.EmailAddress
            ,   fba.OwnerFirstName
            ,   fba.OwnerLastName
            ,   fba.OwnerSSN
            ,   fba.OwnerDOB
            ,   fba.EfinOwnerFirstName
            ,   fba.EfinOwnerLastName
            ,   fba.OwnerHomePhone
            ,   fba.OwnerAddress
            ,   fba.OwnerCity
            ,   fba.OwnerState
            ,   fba.OwnerZip
            ,   fba.IRSTransmittingOfficeInd
            ,   fba.ComplianceWithLawInd
            ,   fba.YearsInBusiness
            ,   fba.LastYearBankProducts
            ,   fba.BankProductFacilitator
            ,   fba.CardProgram
            ,   fba.MultiOffice
            ,   fba.TaxPrepLicensing
            ,   fba.ActualNumberBankProducts
            ,   fba.DocumentStorageInd
            ,   fba.CheckCardStorageInd
            ,   fba.EfinOwnerSSN
            ,   fba.TransmitterFeeDefault
            ,   fba.OfficeDoorInd
            ,   fba.DocumentAccessInd
            ,   fba.SensitiveDocumentDestInd
            ,   fba.LoginPassInd
            ,   fba.AntiVirusInd
            ,   fba.FirewallInd
            ,   fba.ProductTrainingInd
            ,   fba.PreviousViolationFineInd
            ,   fba.NumOfPersonnel
            ,   fba.LegalEntityStatusInd
            ,   fba.LLCMembershipRegistration
            ,   fba.FulfillmentShippingStreet
            ,   fba.FulfillmentShippingCity
            ,   fba.FulfillmentShippingState
            ,   fba.FulfillmentShippingZip
            ,   fba.OfficeManagerFirstName
            ,   fba.OfficeManagerLastName
            ,   fba.OfficeManagerSSN
            ,   fba.OfficeManagerDOB
            ,   fba.MailingAddress
            ,   fba.MailingCity
            ,   fba.MailingState
            ,   fba.MailingZip
            ,   fba.OfficeContactSSN
            ,   fba.AlternateOfficeContact1SSN
            ,   fba.EFINOwnerDOB
            ,   fba.PTINInd
            ,   fba.AdvertisingInd
            ,   fba.WebsiteAddress
            ,   fba.FeeRoutingNumber
            ,   fba.FeeAccountNumber
            ,   fba.FeeAccountType
            ,   fba.Delivered
            ,   fba.Sent
            ,   fba.AgreeBank
            ,   fba.AgreeDate
            ,   fba.DeliveredDate
            ,   fba.SentDate
            ,   fba.UpdatedBy
            ,   fba.UpdatedDate
            ,   fba.Deleted
            ,   fba.SubmittedRecordType
            ,   fba.Roll
            ,   fba.PEITechFee
            ,   fba.PEIRALTransmitterFee
            ,   fba.EROTranFee
            ,	fba.DocPrepFee
            ,   fba.SBPrepFee
            ,   fba.FeeAgree
            ,   fba.FeeAgreeDate
            ,   fba.PEIAgree
            ,   fba.PEIAgreeDate
            ,   fba.CheckStockID
            ,   fba.DebitProgramInd
            ,   fba.EIN
			,	fba.ReferralCode
			,	fba.ProductAuditPros
			,	fba.ProductBP
			,	fba.ProductPlasticPay
			,	fba.LastYearFundingRate
			,	fba.LastYearFedEfiles
			,	fba.IRSEFINValidInd
			,	fba.AgreeBy
			,	fba.CPTSAdminFee
			,	fba.EFFee
			,	fba.NetEFFee
			,	fba.CPTSAdminEFFee
			,	fba.SBFeeAll
			,	fba.EFFeeAll
			,	fba.IPAddress
			,	fba.OwnerEmail
			from
                dbo.Refundo_BankApp fba join @bapps a on fba.Refundo_BankAppID = a.BankAppID

       end

    -- Get the Refund Advantage apps
    if isnull(@bankId,'V') = 'V'
        begin 
            insert @bapps
                select
                    a.BankAppID
                from
                    (
                        select     
                            vba.Refund_Advantage_BankAppID BankAppID
                        ,   row_number() over (partition by vba.EfinID order by vba.Refund_Advantage_BankAppID desc) AS 'RowNumber' 
                        from          
                            dbo.Refund_Advantage_BankApp vba
                        where
                            vba.Delivered = 1
                            and vba.[Sent] = 0
                    ) a 
                where
                    a.RowNumber = 1

                update vba
                    set vba.[Sent] = 1
                ,   vba.SentDate = @ts
                from
                    dbo.Refund_Advantage_BankApp vba join @bapps a on vba.Refund_Advantage_BankAppID = a.BankAppID


                select 
				vba.Refund_Advantage_BankAppID
				,vba.EfinID
				,vba.UserID
				,vba.Master
				,vba.MasterUserID
				,vba.MasterEFINSSN
				,vba.EFINOwnerFirstName
				,vba.EFINOwnerLastName
				,vba.EFINOwnerHomePhone
				,vba.EFINOwnerCellPhone
				,vba.EFINOwnerIDNumber
				,vba.EFINOwnerIDType
				,vba.EFINOwnerIDExpirationDate
				,vba.EFINOwnerIDIssueState
				,vba.EFINOwnerAddress
				,vba.EFINOwnerCity
				,vba.EFINOwnerState
				,vba.EFINOwnerZip
				,vba.EFINOwnerSSN
				,vba.EFINOwnerDateOfBirth
				,vba.EFINOwnerEmailAddress
				,vba.OfficeName
				,vba.OfficeType
				,vba.OfficeAddressStreet
				,vba.OfficeAddressCity
				,vba.OfficeAddressState
				,vba.OfficeAddressZip
				,vba.OfficeWebsite
				,vba.OfficePhone
				,vba.OfficeFax
				,vba.OfficeLocationType
				,vba.TaxIDType
				,vba.TaxID
				,vba.ContactName
				,vba.ContactTitle
				,vba.ContactPreferredLanguage
				,vba.ContactEmailAddress
				,vba.ContactPhone
				,vba.FeeAccountName
				,vba.FeeRoutingNumber
				,vba.FeeAccountNumber
				,vba.FeeAccountType
				,vba.BankRelationshipType
				,vba.MailTo
				,vba.MailingAddressStreet
				,vba.MailingAddressCity
				,vba.MailingAddressState
				,vba.MailingAddressZip
				,vba.ShipTo
				,vba.ShippingAddressStreet
				,vba.ShippingAddressCity
				,vba.ShippingAddressState
				,vba.ShippingAddressZip
				,vba.BusinessOwnerFirstName
				,vba.BusinessOwnerLastName
				,vba.BusinessOwnerAddress
				,vba.BusinessOwnerCity
				,vba.BusinessOwnerState
				,vba.BusinessOwnerZip
				,vba.BusinessOwnerCountry
				,vba.BusinessOwnerHomePhone
				,vba.BusinessOwnerCellPhone
				,vba.BusinessOwnerDateOfBirth
				,vba.BusinessOwnerSSN
				,vba.BusinessOwnerIDNumber
				,vba.BusinessOwnerIDType
				,vba.BusinessOwnerIDExpirationDate
				,vba.BusinessOwnerIDState
				,vba.BusinessOwnerPercentOwned
				,vba.ControlPersonFirstName
				,vba.ControlPersonLastName
				,vba.ControlPersonAddress
				,vba.ControlPersonCity
				,vba.ControlPersonState
				,vba.ControlPersonZip
				,vba.ControlPersonCountry
				,vba.ControlPersonHomePhone
				,vba.ControlPersonCellPhone
				,vba.ControlPersonDateOfBirth
				,vba.ControlPersonSSN
				,vba.ControlPersonIDNumber
				,vba.ControlPersonIDType
				,vba.ControlPersonIDExpirationDate
				,vba.ControlPersonIDState
				,vba.ControlPersonTitle
				,vba.CorporationType
				,vba.CheckMailingAddressType
				,vba.NumberOfPrincipals
				,vba.NumberOfPersonnel
				,vba.RefusedForRenewal
				,vba.SharedEFIN
				,vba.FundingRatio
				,vba.YearsInBusiness
				,vba.YearsCurrentAddress
				,vba.YearsBankProducts
				,vba.YearsEFiling
				,vba.PriorYearEFIN
				,vba.PriorYearPrepFeePaid
				,vba.PriorYearBankRALs
				,vba.PriorYearBankRACs
				,vba.PriorYearBankVolumeSource
				,vba.ProjectedBankProducts
				,vba.PriorYearReturns
				,vba.PriorYearReturnsSource
				,vba.PriorYearBank
				,vba.PriorYearTransmitterUsed
				,vba.NewToTransmitter
				,vba.SecurityQuestion
				,vba.SecurityAnswer
				,vba.EPSProgram
				,vba.Checks
				,vba.Cards
				,vba.LoanIndicator
				,vba.SBFee
				,vba.PEITechFee
				,vba.PEIRALTransmitterFee
				,vba.EROTranFee
				,vba.Delivered
				,vba.Sent
				,vba.DeliveredDate
				,vba.SentDate
				,vba.AgreeBank
				,vba.AgreeDate
				,vba.UpdatedBy
				,vba.UpdatedDate
				,vba.Deleted
				,vba.Roll
				,vba.FeeAgree
				,vba.FeeAgreeDate
				,vba.PEIAgree
				,vba.PEIAgreeDate
				,vba.EFilingFee
				,vba.SystemHold
				,vba.Hidden
				,vba.NetTranFee
				,vba.PreAckLoans
				,vba.BusinessOwnerEmail
				,vba.AgreeBy
				,vba.CPTSAdminFee
				,vba.EFFee
				,vba.NetEFFee
				,vba.CPTSAdminEFFee
				,vba.IPAddress
				,vba.DeviceID
				from
                    dbo.Refund_Advantage_BankApp vba join @bapps a on vba.Refund_Advantage_BankAppID = a.BankAppID

        end

    -- Get the SBTPG apps
    if isnull(@bankId,'S') = 'S'
        begin

            insert @bapps
                select
                    a.BankAppID
                from
                    (
                        select     
                            sba.SBTPG_BankAppID BankAppID
                        ,   row_number() over ( partition by sba.EfinID order by sba.SBTPG_BankAppID desc) AS 'RowNumber' 
                        from          
                            dbo.SBTPG_BankApp sba
                        where
                            sba.Delivered = 1
                            and sba.[Sent] = 0
                    ) a 
                where
                    a.RowNumber = 1

                update sba
                    set sba.[Sent] = 1
                ,   sba.SentDate = @ts
                from
                    dbo.SBTPG_BankApp sba join @bapps a on sba.SBTPG_BankAppID = a.BankAppID


                select
                    sba.SBTPG_BankAppID
                ,   sba.EfinID
                ,   sba.UserID
                ,   sba.[Master]
                ,   sba.OfficeIDENT
                ,   sba.ProductConfiguration
                ,   sba.CompanyName
                ,   sba.ManagersFirstName
                ,   sba.ManagersLastName
                ,   sba.OfficeAddress
                ,   sba.OfficeCity
                ,   sba.OfficeState
                ,   sba.OfficeZipCode
                ,   sba.OfficePhoneNumber
                ,   sba.ShippingAddress
                ,   sba.ShippingCity
                ,   sba.ShippingState
                ,   sba.ShippingZipCode
                ,   sba.ManagersEmailAddress
                ,   sba.OwnersEIN
                ,   sba.OwnersSSN
                ,   sba.OwnersFirstName
                ,   sba.OwnersLastName
                ,   sba.OwnersAddress
                ,   sba.OwnersCity
                ,   sba.OwnersState
                ,   sba.OwnersZipCode
                ,   sba.OwnersPhoneNumber
                ,   sba.OwnersDateOfBirth
                ,   sba.ClientOfYoursLastYear
                ,   sba.LastYearRALBank
                ,   sba.PriorYearVolume
                ,   sba.PriorYearEFIN
                ,   sba.OfficeFaxNumber
                ,   sba.MinimumMasterEFinEFFee
                ,   sba.PriorYearBankProductsFunded
                ,   sba.FeeRoutingNumber
                ,   sba.FeeAccountNumber
                ,   sba.FeeAccountType
                ,   sba.Delivered
                ,   sba.[Sent]
                ,   sba.DeliveredDate
                ,   sba.SentDate
                ,   sba.AgreeBank
                ,   sba.AgreeDate
                ,   sba.UpdatedBy
                ,   sba.UpdatedDate
                ,   sba.Deleted
                ,   sba.SubmittedRecordType
                ,   sba.Roll
                ,   sba.PEITechFee
                ,   sba.PEIRALTransmitterFee
                ,   sba.SBPrepFee
                ,   sba.EROTranFee
                ,   sba.SecureStorage
                ,   sba.SecureDocumentStorage
                ,   sba.LockedWhenVacant
                ,   sba.SecureLogin
                ,   sba.AntiVirus
                ,   sba.Firewall
                ,   sba.FeeAgree
                ,   sba.FeeAgreeDate
                ,   sba.PEIAgree
                ,   sba.PEIAgreeDate
                ,	sba.DocPrepFee
				,	sba.SystemHold
				,	sba.OwnersEmailAddress
				,	sba.CheckPrint
				,	sba.SuperSBid
				,	sba.IPAddress
				,	sba.DeviceID
				,	sba.spanishMaterials
				,	sba.CheckPrintPref
				,	sba.NetTranFee
				,	sba.AgreeBy
				,	sba.CPTSAdminFee
				,	sba.EFFee
				,	sba.NetEFFee
				,	sba.CPTSAdminEFFee
				,   sba.SBFeeAll
				,   sba.EFFeeAll
				,	sba.HoldShipmentDate
                from
                    dbo.SBTPG_BankApp sba join @bapps a on sba.SBTPG_BankAppID = a.BankAppID

        end

    -- Get the World Acceptance apps
    if isnull(@bankId,'W') = 'W'
        begin

            insert @bapps
                select
                    a.BankAppID
                from
                    (
                        select     
                            wba.SBTPGW_BankAppID BankAppID
                        ,   row_number() over ( partition by wba.EfinID order by wba.SBTPGW_BankAppID desc) AS 'RowNumber' 
                        from          
                            dbo.SBTPGW_BankApp wba
                        where
                            wba.Delivered = 1
                            and wba.[Sent] = 0

                    ) a 
                where
                    a.RowNumber = 1

                update wba
                    set wba.[Sent] = 1
                ,   wba.SentDate = @ts
                from
                    dbo.SBTPGW_BankApp wba join @bapps a on wba.SBTPGW_BankAppID = a.BankAppID

                select
                    wba.SBTPGW_BankAppID
                ,   wba.EfinID
                ,   wba.UserID
                ,   wba.[Master]
                ,   wba.OfficeIDENT
                ,   wba.ProductConfiguration
                ,   wba.CompanyName
                ,   wba.ManagersFirstName
                ,   wba.ManagersLastName
                ,   wba.OfficeAddress
                ,   wba.OfficeCity
                ,   wba.OfficeState
                ,   wba.OfficeZipCode
                ,   wba.OfficePhoneNumber
                ,   wba.ShippingAddress
                ,   wba.ShippingCity
                ,   wba.ShippingState
                ,   wba.ShippingZipCode
                ,   wba.ManagersEmailAddress
                ,   wba.OwnersEIN
                ,   wba.OwnersSSN
                ,   wba.OwnersFirstName
                ,   wba.OwnersLastName
                ,   wba.OwnersAddress
                ,   wba.OwnersCity
                ,   wba.OwnersState
                ,   wba.OwnersZipCode
                ,   wba.OwnersPhoneNumber
                ,   wba.OwnersDateOfBirth
                ,   wba.ClientOfYoursLastYear
                ,   wba.LastYearRALBank
                ,   wba.PriorYearVolume
                ,   wba.PriorYearEFIN
                ,   wba.OfficeFaxNumber
                ,   wba.MinimumMasterEFinEFFee
                ,   wba.PriorYearBankProductsFunded
                ,   wba.FeeRoutingNumber
                ,   wba.FeeAccountNumber
                ,   wba.FeeAccountType
                ,   wba.Delivered
                ,   wba.[Sent]
                ,   wba.DeliveredDate
                ,   wba.SentDate
                ,   wba.AgreeBank
                ,   wba.AgreeDate
                ,   wba.UpdatedBy
                ,   wba.UpdatedDate
                ,   wba.Deleted
                ,   wba.SubmittedRecordType
                ,   wba.Roll
                ,   wba.PEITechFee
                ,   wba.PEIRALTransmitterFee
                ,   wba.SBPrepFee
                ,   wba.EROTranFee
                ,   wba.SecureStorage
                ,   wba.SecureDocumentStorage
                ,   wba.LockedWhenVacant
                ,   wba.SecureLogin
                ,   wba.AntiVirus
                ,   wba.Firewall
                ,   wba.FeeAgree
                ,   wba.FeeAgreeDate
                ,   wba.PEIAgree
                ,   wba.PEIAgreeDate
                ,	wba.DocPrepFee
				,	wba.SystemHold
				,	wba.OwnersEmailAddress
				,	wba.CheckPrint
				,	wba.SuperSBid
				,	wba.IPAddress
				,	wba.DeviceID
				,	wba.spanishMaterials
				,	wba.CheckPrintPref
				,	wba.NetTranFee
				,	wba.AgreeBy
				,	wba.CPTSAdminFee
				,	wba.EFFee
				,	wba.NetEFFee
				,	wba.CPTSAdminEFFee
				,   wba.SBFeeAll
				,   wba.EFFeeAll
				,	wba.HoldShipmentDate
				from
                    dbo.SBTPGW_BankApp wba join @bapps a on wba.SBTPGW_BankAppID = a.BankAppID

        end


    set rowcount 0






















