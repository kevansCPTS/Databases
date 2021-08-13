

CREATE procedure [dbo].[up_rptAdvances]
	@LoginID	varchar(8), --can be for account, franchise, or user
	@sDate		date = null
as

	SET NOCOUNT ON

	declare @ShowWorldFunded bit = case when @LoginID like '%[^0-9]%' AND 
			((select count(*) from dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch 
			where ch.childAccount = @LoginID and ch.parentAccount = 'SPEMIC00' and ch.season = dbo.getXlinkSeason()) > 0  
			OR @LoginID = 'SPEMIC00')
			then cast(1 as bit) else cast(0 as bit) end

	declare @uList table (userId int not null)
	
    insert into @uList
        select gu.[user_id]
        from dbo.udf_GetUserIDs(@loginId) gu

    if @sDate is null or @sDate = '1900-01-01'  
		set @sDate = getdate()

    if @ShowWorldFunded = 0
        begin
            select 
                isnull(sum(case when tm.bank_id = 'V' then 1 else 0 end), 0) [RA Requested]
            ,   isnull(sum(case when isnull(d.chk_amt, 0) in (50000, 80000, 120000) and tm.bank_id = 'V' then 1 else 0 end), 0) [RA Funded]
            ,   isnull(sum(case when tm.bank_id = 'R' then 1 else 0 end), 0) [Republic Requested]
            ,   isnull(sum(case when isnull(d.chk_amt, 0) in (80000, 125000) and tm.bank_id = 'R' then 1 else 0 end), 0) [Republic Funded]
            ,   isnull(sum(case when tm.bank_id = 'F' then 1 else 0 end), 0) [Refundo Requested]
            ,   isnull(sum(case when isnull(d.chk_amt, 0) in (50000, 100000) and tm.bank_id = 'F' then 1 else 0 end), 0) [Refundo Funded]
            ,   isnull(sum(case when tm.bank_id = 'S' then 1 else 0 end), 0) [TPG Requested]
            ,   isnull(sum(case when isnull(d.chk_amt, 0) in (50000, 75000, 100000) and tm.bank_id = 'S' then 1 else 0 end), 0) [TPG Funded]
            ,   0 [World Funded]
            ,   @ShowWorldFunded as ShowWorldFunded
            from 
                dbo.tbltaxmast tm join @uList ul on tm.[user_id] = ul.userid
                    and tm.irs_ack_dt <= @sDate
                    and tm.irs_acc_cd = 'A'
                inner join dbo.tblLoanApp la on tm.pssn = la.pssn
                    and la.req_loan_amt <> 0
                left join dbo.tbldisburse d on tm.pssn = d.pssn
        end 
    else
        begin
            -- World Advances for SPEMIC00
            select 
                0 [RA Requested]
            ,   0 [RA Funded]
            ,   0 [Republic Requested]
            ,   0 [Republic Funded]
            ,   0 [Refundo Requested]
            ,   0 [Refundo Funded]
            ,   0 [TPG Requested]
            ,   0 [TPG Funded]
            ,   isnull(sum(case when tm.bank_id = 'W' then 1 else 0 end), 0) [World Funded]
			,   @ShowWorldFunded as ShowWorldFunded
            from   
                dbo.tbltaxmast tm join @uList ul on tm.[user_id] = ul.userid
                    and tm.irs_ack_dt <= @sDate
                    and tm.irs_acc_cd = 'A'
                    and tm.split_disb_amt > 0
                join dbo.tblLoanApp la on tm.pssn = la.pssn 
        end

	/* Hanging onto this in case it's needed for Enity Framework later
	DECLARE @up_rptAdvancesResult TABLE(
		[RA Requested] int
		,[RA Funded] int
		,[Republic Requested] int
		,[Republic Funded] int
		,[Refundo Requested] int
		,[Refundo Funded] int
		,[TPG Requested] int
		,[TPG Funded] int
		,[World Funded] int
		,[ShowWorldFunded] bit
		);*/


