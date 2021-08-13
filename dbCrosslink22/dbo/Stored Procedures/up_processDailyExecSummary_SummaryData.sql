

CREATE procedure [dbo].[up_processDailyExecSummary_SummaryData] --'20190101'
    @aDate  date = null
as

declare @start date
declare @end date
declare @season smallint
declare @preAckCutOff date
declare @advancesRequested int
declare @advancesFunded int 
declare @dailyInfo xml
declare @advances xml
declare @bankproduct xml
declare @global xml
declare @errstr varchar(255)
declare @sqlstr nvarchar(4000)
declare @season2 char(2)

-- Create a place holder table for advance and preAck stats
declare @stats table  (
	BankID		char(1),
	reqAdvances	int,
	reqPreAcks  int,
	fundedAdvances int,
	fundedPreAcks int
)




declare @alist table (
	account		char(8)
) 
    set nocount on


    /*
    Advance Cut-off dates

    TPG - 2/29
    RA - 2/29
    Refundo - 2/29
    Republic 2/28

    PreAck Cut-off dates
    TPG           - 1/26
    RA            - 1/26
    Refundo  - 1/26 
    Republic - 1/26
    */

    set @season2 = right(db_name(),2)
    set @season = '20' + @season2

    select 
        @end =          case when @aDate is null then getdate() else @aDate end 
    ,   @start =        convert(char(4),@season) + '0101'
    ,   @preAckCutOff = convert(char(4),@season) + '0126'


    -- Bail if the activity date for this type exists in the exec summary table 
    if exists (select aDate from dbCrosslinkGlobal.dbo.tblDailyExecutiveSummary where season = @season and aDate = @end and aType = 'S')
        begin
            set @errstr = 'The specified activity date (' + convert(varchar(10),@end,121) + ') already exists in the tblDailyExecutiveSummary table for this type.'      
            raiserror(@errstr,11,1)                   
            return
        end


    /********************************************************************************************************
									    BEGIN ADVANCE INFORMATION
    ********************************************************************************************************/

	-- Insert into temp table so we only run this query once
	insert into @stats
		select 
            bank_id, 
			sum(case when a.adv_stat in ('P','A','D') then 1 else 0 end) reqAdvances,
			sum(case when a.padv_stat in ('P','A','D') then 1 else 0 end) reqPreAcks,
			sum(case when a.adv_stat in ('A') and a.loan_amt > 0 then 1 else 0 end) fundedAdvances,
			sum(case when a.padv_stat in ('A') and a.preack_amt > 0 then 1 else 0 end) fundedPreAcks
		from 
            dbo.tblTaxmast a 
        where 
            bank_id in ('R', 'W', 'F', 'V', 'S')
		group by bank_id


    select	
        @advancesRequested = sum(s.reqAdvances) + sum(s.reqPreAcks),
		@advancesFunded = sum(s.fundedAdvances) + sum(s.fundedPreAcks)
    from 
        @stats s

    

    -- Line 38 of the 2019 Season Data.xlsx --> BANK ADVANCE BREAKDOWN  <- JD: This means nothing to me at the moment but leaving Chuck's comment in case Updated query below
    /*set @advances = (
                        select  
                            ar.BankID			
                        ,   sum(ar.advance) + sum(ar.preAck)	requestedTotal
                        ,   sum(ar.advance)						requestedAdvances
                        ,   sum(ar.preAck)						requestedPreAcks
                        ,   sum(af.advance) + sum(af.preAck)	fundedTotal
                        ,   sum(af.advance)						fundedAdvances
                        ,   sum(af.preAck)						fundedPreAcks
                        from
                            @advReq ar left join @advFund af ON ar.bankid = af.bankid 
                        group by 
                            ar.BankID
                        for
                            xml path ('advances')
                    )

	 */

	 /*  Updated for 2021 with nice clean statuses */
	 set @advances = (
		
				select  
                            s.BankID			
                        ,   sum(s.reqAdvances) + sum(s.reqPreAcks)	requestedTotal
                        ,   sum(s.reqAdvances)						requestedAdvances
                        ,   sum(s.reqPreAcks)						requestedPreAcks
                        ,   sum(s.fundedAdvances) + sum(s.fundedPreAcks)	fundedTotal
                        ,   sum(s.fundedAdvances)						fundedAdvances
                        ,   sum(s.fundedPreAcks)						fundedPreAcks
                        from
                            @stats s
                        group by 
                            s.BankID
                        for
                            xml path ('advances')

	 )

/********************************************************************************************************
									END ADVANCE INFORMATION
********************************************************************************************************/



/********************************************************************************************************
										BEGIN RT INFORMATION
********************************************************************************************************/

    set @bankproduct = (
                            select
                                tm.bank_id BankID
                            ,   sum(case when tm.irs_acc_cd = 'A' and tm.irs_ack_dt < @end then 1 else 0 end)	requested
                            ,   sum(case when tm.isFullyFunded = 1 and tm.fullyFundedDate < @end then 1 else 0 end) funded
                            from
                                dbo.tblTaxmast tm
                            where	
                                (tm.irs_ack_dt < @end
                                    or tm.fullyFundedDate < @end)
                                and tm.ral_flag = 5
                            group by
                                tm.bank_id
                            for
                                xml path ('bankproducts')
                        )

    -- Grab current year info.
    set @dailyInfo = (
                        select	
                            a.totaleFiles
                        ,   a.totalAcks
                        ,   a.totalRejects
                        ,   a.submittedBP
                        ,   a.submittedPP
                        ,   @advancesRequested			submittedAdvances
                        ,   a.fundedBP
                        ,   a.fundedPP
                        ,   @advancesFunded				fundedAdvances
                        from 
                            (
                                select
                                    sum(dfa.efiles)									totaleFiles
                                ,   sum(dfa.acks)									totalAcks
                                ,   sum(dfa.Rejects)								totalRejects
                                ,   sum(dfa.SubmittedBankProducts)					submittedBP
                                ,   sum(dfa.SubmittedProtectionPlusBankProducts)	submittedPP
                                ,   sum(dfa.FundedBankProducts)						fundedBP
                                ,   sum(dfa.FundedProtectionPlusBankProducts)		fundedPP
                                from 
                                    dbcrosslinkglobal.dbo.tblDailyFilingActivity dfa
                                where 
                                    dfa.Season = @season
                                    and dfa.[date] >= @start
                                    and dfa.[date] < @end
                            ) a
                        for
                            xml path ('summary')
                     )

/********************************************************************************************************
										END RT INFORMATION
********************************************************************************************************/


    set @global = (
                        select 
                            replace(dateadd(day, -1, convert(date, @end)), '-', '') [@activityDate]
                        ,   @dailyInfo
                        ,   @advances
                        ,   @bankproduct
                        for 
                            xml path ('FinancialData')
                  )

    insert dbCrosslinkGlobal.dbo.tblDailyExecutiveSummary
        select
            @season season
        ,   dateadd(day, -1, convert(date, @end)) [date]
        ,   'S' bankId
        ,   @global [global]
        ,   getdate() createdDate




