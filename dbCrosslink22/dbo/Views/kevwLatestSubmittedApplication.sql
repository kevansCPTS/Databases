


CREATE VIEW [dbo].[kevwLatestSubmittedApplication]
AS


	select        
		vba.AccountID
	,   vba.UserID
	,   vba.Efin
	,   vba.EfinID
	,   vba.Bank
	,   vba.BankID
	,   vba.BankAppID
	,   vba.Delivered
	,   vba.[Sent]
	,   vba.DeliveredDate
	,   vba.SentDate
	,   vba.Deleted
	,   vba.UpdatedDate
	,   vba.SubmittedRecordType
	,   vba.[Master]
	,   vba.EIN
	,   vba.EFINHolderSSN
	,   vba.EFINHolderFirstName
	,   vba.EFINHolderLastName
	,   vba.EFINHolderDOB
	,   vba.Company
	,   vba.[Address]
	,   vba.City
	,   vba.[State]
	,   vba.Zip
	,   vba.Phone
	,   vba.AlternatePhone
	,   vba.Fax
	,   vba.Email
	,   vba.FeeRoutingNumber
	,   vba.FeeAccountNumber
	,   vba.FeeAccountType
	,   vba.FeeAccountName
	,   vba.PEITechFee
	,   vba.PEIRALTransmitterFee
	,   vba.EROTranFee
	,   vba.EROBankFee
	,   vba.SBPrepFee
	,   vba.Roll
	,   vba.EfinStatus
	,   vba.ErrorCode
	,   vba.EfinProduct
	,   vba.ErrorDescription
	,   vba.Registered
	,   vba.RegisteredDescription
	,   vba.DistributorId
	,   vba.CompanyId
	,   vba.LocationId
	,   vba.CheckName
	,   vba.SBFeeAll
	,   vba.HoldFlag
	,   vba.RacsOnly
	,   vba.SBName
	,   vba.AllowMultipleBanks
	,   vba.LockedAtBank
	,   vba.SelectedBank
	,   vba.SelectedBankName
	,   vba.SCOStatus
	,   vba.DocPrepFee
	,   vba.EFilingFee
	,   vba.SystemHold
	,   vba.[Hidden]
	from
		(
			select        
				vba1.AccountID
			,   vba1.UserID
			,   vba1.Efin
			,   vba1.EfinID
			,   vba1.Bank
			,   vba1.BankID
			,   vba1.BankAppID
			,   vba1.Delivered
			,   vba1.[Sent]
			,   vba1.DeliveredDate
			,   vba1.SentDate
			,   vba1.Deleted
			,   vba1.UpdatedDate
			,   vba1.SubmittedRecordType
			,   vba1.[Master]
			,   vba1.EIN
			,   vba1.EFINHolderSSN
			,   vba1.EFINHolderFirstName
			,   vba1.EFINHolderLastName
			,   vba1.EFINHolderDOB
			,   vba1.Company
			,   vba1.[Address]
			,   vba1.City
			,   vba1.[State]
			,   vba1.Zip
			,   vba1.Phone
			,   vba1.AlternatePhone
			,   vba1.Fax
			,   vba1.Email
			,   vba1.FeeRoutingNumber
			,   vba1.FeeAccountNumber
			,   vba1.FeeAccountType
			,   vba1.FeeAccountName
			,   vba1.PEITechFee
			,   vba1.PEIRALTransmitterFee
			,   vba1.EROTranFee
			,   vba1.EROBankFee
			,   vba1.SBPrepFee
			,   vba1.Roll
			,   vba1.EfinStatus
			,   vba1.ErrorCode
			,   vba1.EfinProduct
			,   vba1.ErrorDescription
			,   vba1.Registered
			,   vba1.RegisteredDescription
			,   vba1.DistributorId
			,   vba1.CompanyId
			,   vba1.LocationId
			,   vba1.CheckName
			,   vba1.SBFeeAll
			,   vba1.HoldFlag
			,   vba1.RacsOnly
			,   vba1.SBName
			,   vba1.AllowMultipleBanks
			,   vba1.LockedAtBank
			,   vba1.SelectedBank
			,   vba1.SelectedBankName
			,   vba1.SCOStatus
			,   vba1.DocPrepFee
			,   vba1.EFilingFee
			,   vba1.SystemHold
			,   vba1.[Hidden]
			,	row_number() over ( partition by vba1.efin, vba1.bankId, vba1.Delivered order by vba1.BankAppId desc) AS 'RowNumber' 
			from
				dbo.vwBankApplication vba1
			where
				vba1.Delivered = 1
		) vba
	where
		vba.RowNumber = 1


