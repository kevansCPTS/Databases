
CREATE procedure [dbo].[up_efFeeLoad]
as

/*
tblEfFee StatusId:
    10 = New (unprocessed) Fee
    20 = Processing Transaction
    30 = Complete
    40 = Failed
    ## = Future Expansion


tblEfFee fType:
    10 = EF Admin Fee
    ## = Future Expansion

*/

declare @aDate                  date                =  convert(date,dateadd(day,-1,getdate()))
declare @season                 smallint

    set nocount on 

    set @season = '20' + right(db_name(),2)

    insert dbCrosslinkGlobal.dbo.tblEfFee (
        season
    ,   account
    ,   userId
    ,   efin
    ,   aDate
    ,   fType
    ,   unitPrice
    ,   amount
    ,   statusId
    ,   parentAccount
    )
        select
            @season season 
        ,   c.account
        ,   tm.[user_id] userId
        ,   tm.efin
        ,   tm.irs_ack_dt aDate
        ,   10 fType 
        ,   tm.admin_ef_fee / 100.00 unitPrice
        ,   sum(tm.admin_ef_fee / 100.00) amount
        ,   10 statusId
        ,   ch.parentAccount
        from
            dbo.tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
                and tm.ral_flag != '5'
                and tm.irs_ack_dt is not null
                and tm.irs_acc_cd = 'A'
                and tm.irs_ack_dt <= @aDate
                and tm.[state] not in('AR', 'CT', 'IL', 'ME', 'MD', 'NY')
            --left join (
            --                select  
            --                    rm1.PrimarySSN
            --                ,   rm1.FilingStatus
            --                ,   rm1.UserID
            --                from 
            --                    dbo.tblReturnMaster rm1 
            --                where 
            --                    rm1.eip = 'X'
            --          ) rm on tm.pssn = rm.PrimarySSN
                --and tm.[user_id] = rm.UserID
                --and tm.filing_stat = rm.FilingStatus
            join dbo.efin e on tm.efin = e.efin
                and e.EFFeeAll = 'X'
            join dbCrosslinkGlobal.dbo.customer c on u.account = c.account
                and c.testCustomer = 1
            join dbo.CustomerAgreements ca on c.account = ca.Account
                and ca.AgreeToEFTerms = 0
            left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on u.account = ch.childAccount
                and ch.season = @season
            left join dbCrosslinkGlobal.dbo.tblEfFee ef on u.account = ef.account
                    and ef.season = @season
                    and u.[user_id] = ef.userId
                    and tm.efin = ef.efin
                    and tm.irs_ack_dt <= @aDate
                    and tm.irs_ack_dt = ef.aDate
                    and ef.fType = 10           
			left join (
				select distinct 
                    sm1.pssn
				from	
                    dbo.tblStamast sm1
				where	
                    sm1.state_ralf = 3 
			) sm on tm.pssn = sm.pssn
		where
            ef.aDate is null
		    and	sm.pssn is null
            --and rm.PrimarySSN is null
        group by
            c.account
        ,   tm.[user_id] 
        ,   tm.efin
        ,   tm.irs_ack_dt
        ,   ch.parentAccount 
        ,   tm.admin_ef_fee
        having 
            sum(tm.admin_ef_fee) > 0


        /*
        select
            @season season 
        ,   c.account
        ,   tm.[user_id] userId
        ,   tm.efin
        ,   tm.irs_ack_dt aDate
        ,   10 fType 
        ,   tm.admin_ef_fee / 100.00 unitPrice
        ,   sum(tm.admin_ef_fee / 100.00) amount
        ,   10 statusId
        ,   ch.parentAccount
        from
            dbo.tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
                and tm.ral_flag != 5
                and tm.irs_ack_dt is not null
            join dbCrosslinkGlobal.dbo.customer c on u.account = c.account
            left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on u.account = ch.childAccount
                and ch.season = @season
            left join dbCrosslinkGlobal.dbo.tblEfFee ef on u.account = ef.account
                    and ef.season = @season
                    and u.[user_id] = ef.userId
                    and tm.efin = ef.efin
                    and tm.irs_ack_dt <= @aDate
                    and ef.fType = 10           
        where
            ef.aDate is null
        group by
            c.account
        ,   tm.[user_id] 
        ,   tm.efin
        ,   tm.irs_ack_dt
        ,   ch.parentAccount 
        ,   tm.admin_ef_fee
        having 
            sum(tm.admin_ef_fee) > 0
        */
    
