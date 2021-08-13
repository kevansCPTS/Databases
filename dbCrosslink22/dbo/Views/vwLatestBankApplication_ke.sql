


CREATE VIEW [dbo].[vwLatestBankApplication_ke]
AS

    select
        ba.AccountID
    ,   ba.UserID
    ,   ba.Efin
    ,   ba.EfinID
    ,   ba.Bank
    ,   ba.BankID
    ,   ba.BankAppID
    ,   ba.Delivered
    ,   ba.[Sent]
    ,   ba.DeliveredDate
    ,   ba.SentDate
    ,   ba.Deleted
    ,   ba.UpdatedDate
    ,   ba.SubmittedRecordType
    ,   ba.[Master]
    ,   ba.EIN
    ,   ba.EFINHolderSSN 
    ,   ba.EFINHolderFirstName
    ,   ba.EFINHolderLastName
    ,   ba.EFINHolderDOB
    ,   ba.Company
    ,   ba.[Address]
    ,   ba.City
    ,   ba.[State]
    ,   ba.Zip 
    ,   ba.Phone
    ,   ba.AlternatePhone
    ,   ba.Fax
    ,   ba.Email
    ,   ba.FeeRoutingNumber
    ,   ba.FeeAccountNumber
    ,   ba.FeeAccountType
    ,   ba.FeeAccountName 
    ,   ba.PEITechFee
    ,   ba.PEIRALTransmitterFee
    ,   ba.EROTranFee
    ,   ba.EROBankFee 
    ,   ba.SBPrepFee
    ,   ba.Roll
    ,   ba.EfinStatus
    ,   ba.ErrorCode
    ,   ba.EfinProduct 
    ,   ba.ErrorDescription 
    ,   ba.Registered
    ,   ba.RegisteredDescription
    ,   ba.DistributorId
    ,   ba.CompanyId
    ,   ba.LocationId
    ,   ba.CheckName 
    ,   ba.SBFeeAll
    ,   ba.HoldFlag
    ,   ba.RacsOnly
    ,   ba.SBName
    ,   ba.AllowMultipleBanks
    ,   ba.LockedAtBank
    ,   ba.SelectedBank 
    ,   ba.SelectedBankName
    ,   ba.SCOStatus
    ,   ba.DocPrepFee
    ,   ba.EFilingFee
    ,   ba.SystemHold
    ,   ba.EfinBankFee
    ,   ba.EfinCompliance
    ,   ba.EfinCard
    ,   ba.EfinPrint
    ,   ba.EfinProduct2
    ,   ba.[Hidden]
    from
        (
            select
                ba1.AccountID
            ,   ba1.UserID
            ,   ba1.Efin
            ,   ba1.EfinID
            ,   ba1.Bank
            ,   ba1.BankID
            ,   ba1.BankAppID
            ,   ba1.Delivered
            ,   ba1.[Sent]
            ,   ba1.DeliveredDate
            ,   ba1.SentDate
            ,   ba1.Deleted
            ,   ba1.UpdatedDate
            ,   ba1.SubmittedRecordType
            ,   ba1.[Master]
            ,   ba1.EIN
            ,   ba1.EFINHolderSSN 
            ,   ba1.EFINHolderFirstName
            ,   ba1.EFINHolderLastName
            ,   ba1.EFINHolderDOB
            ,   ba1.Company
            ,   ba1.[Address]
            ,   ba1.City
            ,   ba1.[State]
            ,   ba1.Zip 
            ,   ba1.Phone
            ,   ba1.AlternatePhone
            ,   ba1.Fax
            ,   ba1.Email
            ,   ba1.FeeRoutingNumber
            ,   ba1.FeeAccountNumber
            ,   ba1.FeeAccountType
            ,   ba1.FeeAccountName 
            ,   ba1.PEITechFee
            ,   ba1.PEIRALTransmitterFee
            ,   ba1.EROTranFee
            ,   ba1.EROBankFee 
            ,   ba1.SBPrepFee
            ,   ba1.Roll
            ,   ba1.EfinStatus
            ,   ba1.ErrorCode
            ,   ba1.EfinProduct 
            ,   ba1.ErrorDescription 
            ,   ba1.Registered
            ,   ba1.RegisteredDescription
            ,   ba1.DistributorId
            ,   ba1.CompanyId
            ,   ba1.LocationId
            ,   ba1.CheckName 
            ,   ba1.SBFeeAll
            ,   ba1.HoldFlag
            ,   ba1.RacsOnly
            ,   ba1.SBName
            ,   ba1.AllowMultipleBanks
            ,   ba1.LockedAtBank
            ,   ba1.SelectedBank 
            ,   ba1.SelectedBankName
            ,   ba1.SCOStatus
            ,   ba1.DocPrepFee
            ,   ba1.EFilingFee
            ,   ba1.SystemHold
            ,   ba1.EfinBankFee
            ,   ba1.EfinCompliance
            ,   ba1.EfinCard
            ,   ba1.EfinPrint
            ,   ba1.EfinProduct2
            ,   ba1.[Hidden]
            ,   row_number() over ( partition by ba1.EfinID,ba1.BankID order by ba1.BankAppID desc) AS RowNumber
            from 
                dbo.vwBankApplication ba1
        ) ba
    where
        ba.RowNumber = 1



