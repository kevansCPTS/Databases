
/************************************************************************************************
Name: up_getRegAppCount

Purpose: Procedure to replace the below inline SQL that calls "some nested bank app views. This procedure conditionally queries all the bank application 
tables, depending on the value of the "@bankId" parameter. This procedure requires the efinId (Crosslink) and, as a result, is 
much more efficient than the views by themselves.  

        exec sp_executesql N'SELECT 
        [GroupBy1].[A1] AS [C1]
        FROM ( SELECT 
	        COUNT(1) AS [A1]
	        FROM (SELECT 
              [vwRegistrationApplication].[AccountID] AS [AccountID], 
              [vwRegistrationApplication].[UserID] AS [UserID], 
              [vwRegistrationApplication].[Efin] AS [Efin], 
              [vwRegistrationApplication].[EfinID] AS [EfinID], 
              [vwRegistrationApplication].[Bank] AS [Bank], 
              [vwRegistrationApplication].[BankID] AS [BankID], 
              [vwRegistrationApplication].[BankAppID] AS [BankAppID], 
              [vwRegistrationApplication].[Delivered] AS [Delivered], 
              [vwRegistrationApplication].[Sent] AS [Sent], 
              [vwRegistrationApplication].[DeliveredDate] AS [DeliveredDate], 
              [vwRegistrationApplication].[SentDate] AS [SentDate], 
              [vwRegistrationApplication].[Deleted] AS [Deleted], 
              [vwRegistrationApplication].[UpdatedDate] AS [UpdatedDate], 
              [vwRegistrationApplication].[SubmittedRecordType] AS [SubmittedRecordType], 
              [vwRegistrationApplication].[Master] AS [Master], 
              [vwRegistrationApplication].[EIN] AS [EIN], 
              [vwRegistrationApplication].[EFINHolderSSN] AS [EFINHolderSSN], 
              [vwRegistrationApplication].[EFINHolderFirstName] AS [EFINHolderFirstName], 
              [vwRegistrationApplication].[EFINHolderLastName] AS [EFINHolderLastName], 
              [vwRegistrationApplication].[EFINHolderDOB] AS [EFINHolderDOB], 
              [vwRegistrationApplication].[Company] AS [Company], 
              [vwRegistrationApplication].[Address] AS [Address], 
              [vwRegistrationApplication].[City] AS [City], 
              [vwRegistrationApplication].[State] AS [State], 
              [vwRegistrationApplication].[Zip] AS [Zip], 
              [vwRegistrationApplication].[Phone] AS [Phone], 
              [vwRegistrationApplication].[AlternatePhone] AS [AlternatePhone], 
              [vwRegistrationApplication].[Fax] AS [Fax], 
              [vwRegistrationApplication].[Email] AS [Email], 
              [vwRegistrationApplication].[MultiOffice] AS [MultiOffice], 
              [vwRegistrationApplication].[FeeRoutingNumber] AS [FeeRoutingNumber], 
              [vwRegistrationApplication].[FeeAccountNumber] AS [FeeAccountNumber], 
              [vwRegistrationApplication].[FeeAccountType] AS [FeeAccountType], 
              [vwRegistrationApplication].[PEITechFee] AS [PEITechFee], 
              [vwRegistrationApplication].[PEIRALTransmitterFee] AS [PEIRALTransmitterFee], 
              [vwRegistrationApplication].[EROTranFee] AS [EROTranFee], 
              [vwRegistrationApplication].[EROBankFee] AS [EROBankFee], 
              [vwRegistrationApplication].[SBPrepFee] AS [SBPrepFee], 
              [vwRegistrationApplication].[Roll] AS [Roll], 
              [vwRegistrationApplication].[EfinStatus] AS [EfinStatus], 
              [vwRegistrationApplication].[ErrorCode] AS [ErrorCode], 
              [vwRegistrationApplication].[EfinProduct] AS [EfinProduct], 
              [vwRegistrationApplication].[ErrorDescription] AS [ErrorDescription], 
              [vwRegistrationApplication].[Registered] AS [Registered], 
              [vwRegistrationApplication].[RegisteredDescription] AS [RegisteredDescription], 
              [vwRegistrationApplication].[DistributorId] AS [DistributorId], 
              [vwRegistrationApplication].[CompanyId] AS [CompanyId], 
              [vwRegistrationApplication].[LocationId] AS [LocationId], 
              [vwRegistrationApplication].[CheckName] AS [CheckName], 
              [vwRegistrationApplication].[SBFeeAll] AS [SBFeeAll], 
              [vwRegistrationApplication].[HoldFlag] AS [HoldFlag], 
              [vwRegistrationApplication].[RacsOnly] AS [RacsOnly], 
              [vwRegistrationApplication].[SBName] AS [SBName], 
              [vwRegistrationApplication].[AllowMultipleBanks] AS [AllowMultipleBanks], 
              [vwRegistrationApplication].[LockedAtBank] AS [LockedAtBank], 
              [vwRegistrationApplication].[SelectedBank] AS [SelectedBank], 
              [vwRegistrationApplication].[SelectedBankName] AS [SelectedBankName]
              FROM [dbo].[vwRegistrationApplication] AS [vwRegistrationApplication]) AS [Extent1]
	        WHERE ([Extent1].[EfinID] = @p__linq__0) AND (''A'' = [Extent1].[Registered]) AND (cast(1 as bit) <> [Extent1].[Deleted])
        )  AS [GroupBy1]',N'@p__linq__0 int',@p__linq__0=12615

    
    The optional @bankId parameter allows for filtering by specific bank, or the inclusion of all banks. The optional @reg 
    parameter allows for more than the default 'A' to be included.


Called By:

Parameters: 
 1 @efinid  int    
 2 @bankId  char(1) = null
 3 @reg varchar(10) = null

Result Codes:
 0 success

Author: Ken Evans 10/16/2012

Changes/Update:
	08/19/2013 KJE
		Added the Refund Advantage bank app type to the output. BankId = 'V'  


**************************************************************************************************/
CREATE procedure [dbo].[up_getRegAppCount] --1284, 'S'
    @efinId     int
,   @bankId     char(1) = null
,   @reg        varchar(10) = 'A'
as


declare @bapps table (
    EfinID int
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   Deleted bit
,	SystemHold bit
)

declare @bankapp table (
    EfinID int
,   BankID varchar(1)
,   BankAppID int
,   Deleted bit
,   Registered varchar(1)
,	SystemHold bit
)


set nocount on

    --if(@reg is null)
    --    set @reg = 'A'


    -- Get the SBTPG apps
    if isnull(@bankId,'S') = 'S'
        insert @bapps
            select     
                sba.EfinID
            ,   'S' BankID
            ,   sba.SBTPG_BankAppID BankAppID
            ,   sba.Delivered
            ,   sba.Deleted
            ,	sba.SystemHold
            from          
                dbo.SBTPG_BankApp sba
            where
                sba.EfinID = @efinId
			and sba.WorldAcceptance = 0

    -- Get the World Acceptance apps
    if isnull(@bankId,'W') = 'W'
        insert @bapps
            select     
                wba.EfinID
            ,   'W' BankID
            ,   wba.SBTPGW_BankAppID BankAppID
            ,   wba.Delivered
            ,   wba.Deleted
            ,	wba.SystemHold
            from          
                dbo.SBTPGW_BankApp wba
            where
                wba.EfinID = @efinId

    -- Get the Refundo apps
    if isnull(@bankId,'F') = 'F'
        insert @bapps
            select     
                fba.EfinID
            ,   'F' BankID
            ,   fba.Refundo_BankAppID BankAppID
            ,   fba.Delivered
            ,   fba.Deleted
            ,	fba.SystemHold
            from          
                dbo.Refundo_BankApp fba
            where
                fba.EfinID = @efinId

    -- Get the Republic apps
    if isnull(@bankId,'R') = 'R'
        insert @bapps
            select     
                rba.EfinID
            ,   'R' BankID
            ,   rba.Republic_BankAppID BankAppID
            ,   rba.Delivered
            ,   rba.Deleted
            ,	rba.SystemHold
            from          
                dbo.Republic_BankApp rba
            where
                rba.EfinID = @efinId

    -- Get the Refund Advantage apps
    if isnull(@bankId,'V') = 'V'
        insert @bapps
            select     
                adv.EfinID
            ,   'V' BankID
            ,   adv.Refund_Advantage_BankAppID BankAppID
            ,   adv.Delivered
            ,   adv.Deleted
            ,	adv.SystemHold
            from         
                dbo.Refund_Advantage_BankApp adv
            where
                adv.EfinID = @efinId
    

    insert @bankapp
        select
            ba.EfinID
        ,   ba.BankID
        ,   ba.BankAppID
        ,   ba.Deleted
        ,   case
                when brs.Registered is not null then brs.Registered 
                else case 
                        when ba.Delivered = 1 then 'P' 
                        else 'U' 
                     end
            end Registered
         ,	ba.SystemHold
        from
            dbo.efin e join @bapps ba on e.EfinID = ba.EfinID
            left join (
                    select
                        er1.BankCode
                    ,   er1.BankAppID
                    ,   MAX(er1.rowID) RegrRowID
                    from
                        @bapps ba1 join dbo.efin_regr er1 on ba1.BankAppID = er1.BankAppID
                    group by
                        er1.BankCode
                    ,   er1.BankAppID) lr ON lr.BankCode = ba.BankID 
                and lr.BankAppID = ba.BankAppID 
            left join dbo.efin_regr er ON lr.RegrRowID = er.rowID 
            left join dbo.ltblBankRegRejects br ON er.EfinError = br.RejectCode 
                and er.BankCode = br.Bank 
            left join dbo.ltblBankRegistrationStatus brs on brs.BankID = er.BankCode 
                and brs.EFINStatus = er.EfinStatus 
            left join dbo.ltblRegistrationStatusDescription rsd on rsd.Registered = case 
                                                                                        when brs.Registered is not null then brs.Registered 
                                                                                        else case 
                                                                                                when ba.Delivered = 1 then 'P' 
                                                                                                else 'U' 
                                                                                             end
                                                                                    end 
            left join dbCrosslinkGlobal.dbo.customer c ON c.account = e.Account 
            left join dbo.EFINBank eb on eb.EFINBankID = e.SelectedBank



    select
        count(ba.EfinId) C1    
    from    
        @bankapp ba join (
                            select  
                                ba1.EfinID
                            ,   ba1.BankAppID
                            ,   ba1.BankID
                            ,   row_number() over ( partition by ba1.BankId, ba1.EfinId order by ba1.BankAppId desc) AS 'RowNumber'    
                               
                            from
                               @bankapp ba1
                          ) ba2 on ba.BankAppID = ba2.BankAppID
            and ba.BankID = ba2.BankID
            and ba2.RowNumber = 1
            and patindex(ba.Registered,@reg) > 0
            --and ba.Registered = 'A'
            and ba.Deleted != 1


