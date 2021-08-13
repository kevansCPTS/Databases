

/************************************************************************************************
Name: up_RegAppCount

Purpose: Procedure to replace the count calls to the "vwRegistrationApplication" view. This procedure 
conditionally queries all the bank application tables, depending on the value of the "@bankId" parameter. 
This procedure requires the efin or efin Id and, as a result, is much more efficient than the view.  


Called By:

Parameters: 
 1 @efin int
 2 @bankId  char(1) = null
 3 @efinid  int     = null

Result Codes:
 0 success

Author: Ken Evans 09/28/2012

Changes/Update:
    
    None. 


**************************************************************************************************/
CREATE procedure [dbo].[up_RegAppCount2] --null, 'A', 5296
    @efin           int                 =   null
,   @bankId         varchar(5)          =   null
,   @efinid         int                 =   null
as

declare @bapps table (
    EfinID int
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   Deleted bit
,	SystemHold bit
)


declare @output table (
    Efin int
,   EfinID int
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   Deleted bit
,   Registered varchar(1)  
,	SystemHold	bit
)

set nocount on

    -- Get the efinId for the provided efin
    if (@efinid is null)
        select
            @efinId = e.EfinID
        from
            dbo.efin e
        where
            e.Efin = @efin

    if(@efinid is null)
        begin
            print 'You need to pass in either an EFIN or an EFIN_ID to process the bank app data.'
            return 1
        end

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

    -- Get the Refund Advantages apps
    if isnull(@bankId,'V') = 'V'
        insert @bapps
            select     
                vba.EfinID
            ,   'V' BankID
            ,   vba.Refund_Advantage_BankAppID BankAppID
            ,   vba.Delivered
            ,   vba.Deleted
            ,	vba.SystemHold
            from          
                dbo.Refund_Advantage_BankApp vba
            where
                vba.EfinID = @efinId

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

    insert @output
        select
            e.Efin
        ,   ba.EfinID
        ,   ba.BankID
        ,   ba.BankAppID
        ,   ba.Delivered
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
                        ,   er1.rowID
                        ,   er1.EfinError
                        ,   er1.EfinStatus
                        ,   row_number() over ( partition by er1.BankCode, er1.BankAppID order by er1.rowID desc) RowNumber
                        from
                            @bapps ba1 join dbo.efin e1 on ba1.EfinID = e1.EfinID
                            join dbo.efin_regr er1 on e1.Efin = er1.Efin
 
/*
                        select
                            er1.BankCode
                        ,   er1.BankAppID
                        ,   er1.rowID
                        ,   er1.EfinError
                        ,   er1.EfinStatus
                        ,   row_number() over ( partition by er1.BankCode, er1.BankAppID order by er1.rowID desc) RowNumber
                        from
                            dbo.efin_regr er1
*/

                        ) lr ON lr.BankCode = ba.BankID 
                and lr.BankAppID = ba.BankAppID
                and isnull(lr.RowNumber,1) = 1 
            --left join dbo.efin_regr er ON lr.rowID = er.rowID 
            left join dbo.ltblBankRegRejects br ON lr.EfinError = br.RejectCode 
                and lr.BankCode = br.Bank 
            left join dbo.ltblBankRegistrationStatus brs on brs.BankID = lr.BankCode 
                and brs.EFINStatus = lr.EfinStatus 
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
    count(*) C1
from 
    @output o join (
                    select
                        o1.BankID
                    ,   o1.BankAppID
                    ,   row_number() over ( partition by o1.BankID, o1.Efin order by o1.BankAppID desc) RowNumber    
                    from    
                        @output o1 join dbo.ltblRegistrationStatusDescription rsd1 on o1.Registered = rsd1.Registered
                            and rsd1.SendToEFINMaster = 1
                    ) o2 on o.BankID = o2.BankID
        and o.BankAppID = o2.BankAppID
        and o2.RowNumber = 1
        and o.Registered = 'A'
        and o.Deleted != 1
    




