


CREATE  procedure [dbo].[up_getAccountMasterEfin] --'PETZ01' --'RIVEDG'
    @account    varchar(8)
as


--declare @account varchar(8)

--set @account = 'PETZ01'
--set @account = 'RIVEDG'

declare @bapps table (
    EfinID int
,   Bank varchar(50)
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   [Sent] bit
,   efinMaster int 
)

declare @efinRegrMap table(
    BankCode            char(1)
,   BankAppId           int
,   EfinError           varchar(50)
,   EFINProduct         varchar(1)
,   EfinStatus          varchar(1)
,   ErrorDescription    varchar(150)
) 

declare @bankApp table(
    AccountID varchar(8)
,   UserID int 
,   Efin int 
,   EfinID int
,   BankID varchar(1) 
,   BankAppID int 
,   Delivered bit 
,   [Sent] bit
,   Registered varchar(1)
,   efinMaster int
)

declare @efinId int

set nocount on

    -- Get the Republic apps
        insert @bapps
            select     
                rba.EfinID
            ,   'Republic' Bank
            ,   'R' BankID
            ,   rba.Republic_BankAppID BankAppID
            ,   rba.Delivered
            ,   rba.[Sent]
            ,   rba.[Master]
            from          
                dbo.Republic_BankApp rba join dbo.efin e on rba.EfinID = e.EfinID
                    and e.Account = @account 
					and e.UserID = rba.UserID

    -- Get the Refundo apps
        insert @bapps
            select     
                fba.EfinID
            ,   'Refundo' Bank
            ,   'F' BankID
            ,   fba.Refundo_BankAppID BankAppID
            ,   fba.Delivered
            ,   fba.[Sent]
            ,   fba.[Master]
            from          
                dbo.Refundo_BankApp fba join dbo.efin e on fba.EfinID = e.EfinID
                    and e.Account = @account 
					and e.UserID = fba.UserID

    -- Get the Refund Advantage apps
        insert @bapps
            select     
                vba.EfinID
            ,   'Ref Adv' Bank
            ,   'V' BankID
            ,   vba.Refund_Advantage_BankAppID BankAppID
            ,   vba.Delivered
            ,   vba.[Sent]
            ,   vba.[Master]
            from          
                dbo.Refund_Advantage_BankApp vba join dbo.efin e on vba.EfinID = e.EfinID
                    and e.Account = @account 
					and e.UserID = vba.UserID

    -- Get the SBTPG apps
        insert @bapps
            select     
                sba.EfinID
            ,   'TPG' Bank
            ,   'S' BankID
            ,   sba.SBTPG_BankAppID BankAppID
            ,   sba.Delivered
            ,   sba.[Sent]
            ,   sba.[Master]
            from          
                dbo.SBTPG_BankApp sba join dbo.efin e on sba.EfinID = e.EfinID
                    and e.Account = @account 
					and e.UserID = sba.UserID
				    and sba.WorldAcceptance = 0

    -- Get the World Acceptance apps
        insert @bapps
            select     
                wba.EfinID
            ,   'TPGW' Bank
            ,   'W' BankID
            ,   wba.SBTPGW_BankAppID BankAppID
            ,   wba.Delivered
            ,   wba.[Sent]
            ,   wba.[Master]
            from          
                dbo.SBTPGW_BankApp wba join dbo.efin e on wba.EfinID = e.EfinID
                    and e.Account = @account
                    and e.Account = @account 
					and e.UserID = wba.UserID

    -- Get the Advent apps
/*
        insert @bapps
            select 
                aba.EfinID
            ,   'Advent' Bank
            ,   'A' BankID
            ,   aba.Advent_BankAppID BankAppID
            ,   aba.Delivered
            ,   aba.[Sent]
            ,   aba.[Master]
            from         
                dbo.Advent_BankApp aba join dbo.efin e on aba.EfinID = e.EfinID
                    and e.Account = @account
                left join (select
                                row_number() over ( partition by ag1.Advent_BankAppID order by ag1.OwnershipPercent desc, ag1.Advent_GuarantorID desc) AS 'RowNumber'    
                            ,   ag1.Advent_BankAppID
                            ,   ag1.SSN 
                            ,   ag1.FirstName 
                            ,   ag1.LastName 
                            ,   ag1.DOB 
                            from
                                dbo.Advent_Guarantor ag1 join dbo.Advent_BankApp aba1 on ag1.Advent_BankAppID = aba1.Advent_BankAppID
                                    and aba1.EfinID = isnull(@efinId,aba1.EfinID)) ag on aba.Advent_BankAppID = ag.Advent_BankAppID
            where
                aba.EfinID = isnull(@efinid,aba.EfinID)
                and isnull(ag.RowNumber,1) = 1
*/        

    insert @efinRegrMap
        select
            er1.BankCode
        ,   er1.BankAppID
        ,   er1.EfinError
        ,   er1.EFINProduct
        ,   er1.EfinStatus
        ,   er1.ErrorDescription
        from
            (
                select
                    er2.BankCode
                ,   er2.BankAppID
                ,   er2.rowID
                ,   er2.EfinError
                ,   er2.EFINProduct
                ,   er2.EfinStatus
                ,   er2.ErrorDescription
                ,   row_number() over ( partition by er2.BankAppID,er2.BankCode order by er2.rowID desc) AS 'RowNumber'    
                from
                    dbo.efin_regr er2 join (
                                            select  
                                                ba1.EfinId
                                            ,   e1.efin
                                            from
                                                @bapps ba1 join dbo.efin e1 on ba1.efinID = e1.EfinID
                                            ) e2 on er2.Efin = e2.Efin
            ) er1
        where
            er1.RowNumber = 1


    insert @bankApp
        select
            e.Account AccountID
        ,   e.UserID
        ,   e.Efin
        ,   ba.EfinID
        ,   ba.BankID
        ,   ba.BankAppID
        ,   ba.Delivered
        ,   ba.[Sent]
        ,   case
                when brs.Registered is not null then brs.Registered 
                else case 
                        when ba.Delivered = 1 then 'P' 
                        else 'U' 
                     end
            end Registered
        ,   ba.efinMaster
        from
            dbo.efin e join @bapps ba on e.EfinID = ba.EfinID
            left join @efinRegrMap er on ba.BankID = er.BankCode
                and ba.BankAppID = er.BankAppID
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
        mba.AccountID
    ,   max(case 
                when mba.UserID < 996000 and mba.BankID = 'W' then mba.Efin
                else null       
            end) XLTPGWMasterEfin
    ,   max(case 
                when mba.UserID < 996000 and mba.BankID = 'V' then mba.Efin
                else null       
            end) XLRefundAdvMasterEfin
    ,   max(case 
                when mba.UserID < 996000 and mba.BankID = 'F' then mba.Efin
                else null       
            end) XLRefundoMasterEfin
    ,   max(case 
                when mba.UserID < 996000 and mba.BankID = 'R' then mba.Efin
                else null       
            end) XLRepublicMasterEfin
    ,   max(case 
                when mba.UserID < 996000 and mba.BankID = 'S' then mba.Efin
                else null       
            end) XLSBTPGMasterEfin
    ,   max(case 
                when mba.UserID >= 996000 and mba.BankID = 'W' then mba.Efin
                else null       
            end) MSOTPGWMasterEfin
    ,   max(case 
                when mba.UserID >= 996000 and mba.BankID = 'V' then mba.Efin
                else null       
            end) MSORefundAdvMasterEfin
    ,   max(case 
                when mba.UserID >= 996000 and mba.BankID = 'F' then mba.Efin
                else null       
            end) MSORefundoMasterEfin
    ,   max(case 
                when mba.UserID >= 996000 and mba.BankID = 'R' then mba.Efin
                else null       
            end) MSORepublicMasterEfin
    ,   max(case 
                when mba.UserID >= 996000 and mba.BankID = 'S' then mba.Efin
                else null       
            end) MSOSBTPGMasterEfin
    --,   mba.Efin
    --,   mba.UserID
    --,   mba.BankAppID
    --,   mba.BankID
    from
        (
            select distinct 
                ba.BankAppID
            ,   ba.AccountID
            ,   ba.BankID
            ,   ba.Delivered
            ,   ba.Efin
            ,   ba.EfinID
            ,   ba.Registered
            ,   ba.[Sent]
            ,   ba.UserID
            ,   ba.efinMaster
            from 
                @bankApp ba join (
                                    select
                                        'F' BankId
                                    ,   fba.Efin
                                    ,   max(fba.BankAppID) BankAppID
                                    from    
                                        @bankApp fba
                                    where
                                        fba.BankID = 'F'
                                        and fba.Delivered = 1
                                    group by
                                        fba.Efin
                                    union select
                                        'R' BankId
                                    ,   rba.Efin
                                    ,   max(rba.BankAppID) BankAppID
                                    from    
                                        @bankApp rba
                                    where
                                        rba.BankID = 'R'
                                        and rba.Delivered = 1
                                    group by
                                        rba.Efin
                                    union select
                                        'A' BankId
                                    ,   aba.Efin
                                    ,   max(aba.BankAppID) BankAppID
                                    from    
                                        @bankApp aba
                                    where
                                        aba.BankID = 'A'
                                        and aba.Delivered = 1
                                    group by
                                        aba.Efin
                                    union select
                                        'S' BankId
                                    ,   sba.Efin
                                    ,   max(sba.BankAppID) BankAppID
                                    from    
                                        @bankApp sba
                                    where
                                        sba.BankID = 'S'
                                        and sba.Delivered = 1
                                    group by
                                        sba.Efin
                                    union select
                                        'W' BankId
                                    ,   wba.Efin
                                    ,   max(wba.BankAppID) BankAppID
                                    from    
                                        @bankApp wba
                                    where
                                        wba.BankID = 'W'
                                        and wba.Delivered = 1
                                    group by
                                        wba.Efin
                                    union select
                                        'V' BankId
                                    ,   raba.Efin
                                    ,   max(raba.BankAppID) BankAppID
                                    from    
                                        @bankApp raba
                                    where
                                        raba.BankID = 'V'
                                        and raba.Delivered = 1
                                    group by
                                        raba.Efin
                                  ) lsba on ba.BankAppID = lsba.BankAppID
                    and ba.BankID = lsba.BankId
                    and ba.Efin = lsba.Efin
                    and ba.Registered in('A', 'C', 'P')
        ) mba
    where
        mba.Efin = mba.efinMaster
    group by
        mba.AccountID













