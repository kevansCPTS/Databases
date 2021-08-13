
CREATE procedure [dbo].[up_processProtPlusTpEnroll] --'https://web1.nbfsa.com/secure_enroll/protectionplus/process_enroll.php','https://web1.nbfsa.com/secure_enroll/protectionplus/process_maint.php','Authentication-Token','0015c5266ae9cbd60a0e9ca8e318d5ff5f0e2857'
	@url_enroll		varchar(255)
,	@url_maint		varchar(255)
,	@htName			varchar(255)
,	@htValue		varchar(255)
as

--declare @url			    varchar(255)
--declare @htName			    varchar(255)
--declare @htValue		    varchar(255)

declare @tpId               int
declare @efin               varchar(10)
declare @account_code       varchar(15)   
declare @software           varchar(20)
declare @package            varchar(50)
declare @enroll_id          varchar(32)
declare @fname              varchar(20)
declare @lname              varchar(30)
declare @address1           varchar(50)
declare @city               varchar(30)
declare @state              varchar(2)
declare @zip                varchar(5)
declare @email              varchar(255)
declare @phone				varchar(12)
declare @language           varchar(15)
declare @bill_method        varchar(15)
declare @pssn               varchar(4)
declare @fund_status        varchar(8)
declare @action             varchar(7)
declare @effective_date     varchar(10)
declare @payment_amount		money

declare @cDate				datetime
declare @pData				varchar(max)
declare @fmtPost			varchar(max)
declare @rData				varchar(max)
declare @respCode			varchar(max)
declare @errDesc			varchar(max)
declare @lid				int
declare @masterAccount      varchar(8)



    set nocount on 

    set @software = 'Crosslink'
    set @bill_method = 'INVOICE'
    set @language = 'ENGLISH'
    set @cDate = getdate()
    set @action = 'PAYMENT'


    insert dbo.tblProtPlusTpEnrollStatus(
        [pssn]
    ,   [Account]
    ,   [EFIN]
    ,   [fdate]
    ,   [req_pplus_fee]
    ,   [pplus_pay_date]
    ,   [pplus_pay_amt]
    ,   [StatusId]
    ,   [StatusDate]
    ,   [logId]
    )
        select
            tm.pssn
        ,   isnull(e.Account,u.account) account
        ,   isnull(e.Efin,tm.efin) efin
        ,   tm.fdate
        ,   tmf.req_pp_fee
        ,   tmf.pp_pay_date 
        ,   tmf.pp_pay_amt
        --,   case tmf.ppff
        --        when 1 then 30
        --        else 10
        --    end StatusId
        ,   10 StatusId
        ,   getdate() StatusDate
        ,   null logId
        from
            dbo.tblTaxmast tm 
            join (
                    select
                        tmf1.pssn
                    ,   sum(tmf1.reqAmount) req_pp_fee
                    ,   max(tmf1.payDate) pp_pay_date
                    ,   sum(tmf1.payAmount) pp_pay_amt
                    ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag = 'AUD'
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                 ) tmf on tm.pssn = tmf.pssn
            left join dbo.efin e on tm.efin = e.efin
            left join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
            left join dbo.tblProtPlusTpEnrollStatus tpes on tm.pssn = tpes.pssn
        where
            tm.irs_acc_cd = 'A'
            and tpes.pssn is null


        /*
        select
            tm.pssn
        ,   e.Account
        ,   e.Efin
        ,   tm.fdate
        ,   tmf.req_pp_fee
        ,   tmf.pp_pay_date 
        ,   tmf.pp_pay_amt
        --,   case tmf.ppff
        --        when 1 then 30
        --        else 10
        --    end StatusId
        ,   10 StatusId
        ,   getdate() StatusDate
        ,   null logId
        from
            dbo.tblTaxmast tm join dbo.efin e on tm.efin = e.efin
                and tm.irs_acc_cd = 'A'
            join (
                    select
                        tmf1.pssn
                    ,   sum(tmf1.reqAmount) req_pp_fee
                    ,   max(tmf1.payDate) pp_pay_date
                    ,   sum(tmf1.payAmount) pp_pay_amt
                    ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag = 'AUD'
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                 ) tmf on tm.pssn = tmf.pssn
            left join dbo.tblProtPlusTpEnrollStatus tpes on tm.pssn = tpes.pssn
        where
            tpes.pssn is null
        */

	declare curPP cursor fast_forward for
        select
            ppes.tpId
        ,   tm.efin
        ,   e.Account account_code
        --,   @software software
        ,   case 
                when tm.ral_flag = '5' then 'Crosslink-TPP-Bank'
                else 'Crosslink-TPP-Non-Bank'
            end package
        ,   convert(varchar(32),ppes.tpId) enroll_id
        ,   dbo.udfGetCharacters(tm.pri_fname,'0-9 a-z') fname
        ,   dbo.udfGetCharacters(tm.pri_lname,'0-9 a-z') lname
        ,   dbo.udfGetCharacters(tm.[address],'0-9 a-z') [address]
        ,   dbo.udfGetCharacters(tm.city,'0-9 a-z') city
        ,   dbo.udfGetCharacters(tm.[state],'0-9 a-z') [state]
        ,   left(dbo.udfGetCharacters(tm.zip,'0-9 a-z'),5) zip
        ,   tm.email_address email
        ,   case 
				when rtrim(isnull(tm.home_phone,'')) ! = '' then left(tm.home_phone,3) + '-' + substring(tm.home_phone,4,3) + '-' + right(tm.home_phone,4)
				else ''
			end phone
        --,   @bill_method bill_method
        ,   right(convert(varchar(25),tm.pssn),4) pssn
        --,   case 
        --        when tmf.ppff = 1 then 'FUNDED'
        --        else 'UNFUNDED'  
        --    end fund_status
        ,   'UNFUNDED' fund_status
        from
            dbo.tblProtPlusTpEnrollStatus ppes join dbo.tblTaxmast tm on ppes.pssn = tm.pssn
                and ppes.StatusId = 10
            join dbo.efin e on tm.efin = e.efin
            join (
                    select
                        tmf1.pssn
                    ,   sum(tmf1.reqAmount) req_pp_fee
                    ,   max(tmf1.payDate) pp_pay_date
                    ,   sum(tmf1.payAmount) pp_pay_amt
                    ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag = 'AUD'
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                 ) tmf on tm.pssn = tmf.pssn



	open curPP
	fetch next from curPP into
        @tpId
    ,   @efin      
    ,   @account_code   
    ,   @package           
    ,   @enroll_id       
    ,   @fname             
    ,   @lname             
    ,   @address1           
    ,   @city              
    ,   @state              
    ,   @zip              
    ,   @email             
    ,   @phone         
    ,   @pssn             
    ,   @fund_status       

	while @@FETCH_STATUS = 0 
		begin

            set @fmtPost = null
            set @rData = null
            set @respCode = null
            set @errDesc = null

			if @fname is null or @lname is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Taxpayer Name'
			if @address1 is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Taxpayer Address'
			if @city is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Taxpayer City'
			if @state is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Taxpayer State'
			if @zip is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Taxpayer Zip'
			if @phone is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Phone Number'


			print 'Begin Processing Enroll Id: ' + @enroll_id + ' for EFIN:' + @efin + ' ...'
	
			if @errDesc is null
				begin
					set @pData = 'efin=' + rtrim(@efin) 
						+ '|account_code=' + rtrim(@account_code)
                        + '|software=' + rtrim(@software)
						+ '|package=' + rtrim(@package) 
						+ '|enroll_id=' + rtrim(@enroll_id)
                        + '|fname=' + rtrim(@fname)
						+ '|lname=' + rtrim(@lname)
						+ '|address1=' + rtrim(@address1) 
						+ '|city=' + rtrim(@city) 
						+ '|state=' + rtrim(@state) 
						+ '|zip=' + rtrim(@zip) 
						+ '|email=' + rtrim(@email)
						+ '|phone=' + rtrim(@phone)
						+ '|language=' + rtrim(@language)
						+ '|bill_method=' + rtrim(@bill_method)                    
						+ '|pssn=' + rtrim(@pssn)
						+ '|fund_status=' + rtrim(@fund_status)                   


                    --print 'URL: ' + @url
                    --print 'Post Data: ' + @pData
                    --print 'HT Name: ' + @htName
                    --print 'HT Value: ' + @htValue


					/*****************************************************************
												REMOVE ASAP
					******************************************************************/
					-- added 1 second pause to help troubleshoot an issue at Prot Plus.  
					-- WAITFOR DELAY '00:00:01';
					/*****************************************************************/
--print convert(varchar(50),getdate(),113)
					exec dbAdmin.dbo.up_postJsonHt @url_enroll, @pData, @htName, @htValue, @fmtPost output, @rData output, @respCode output, @errDesc output
--print convert(varchar(50),getdate(),113)

					--print 'Raw Data: ' + @pData
					--print 'Formatted JSON Post Data: ' + @fmtPost
					--print 'Return Data: ' + @rData
					--print 'Response Code: ' + @respCode
					--print 'Error Description: ' + @errDesc

				end
			else 
				set @rData = @errDesc

			insert dbo.tblProtPlusTpEnrollLog(
				[tpId]				
			,	[postData]
			,	[responseCode]
			,	[responseData]
			,	[submitDate]
			)
				values (
					@tpId
				,	@fmtPost
				,	@respCode
				,	@rData
				,	@cDate
				)

			set @lid = SCOPE_IDENTITY()

			update ppes
				set ppes.StatusId = case	
										when patindex('%ACCEPTED%', @rData) > 0 then 20
										else 10
									end
			,	ppes.statusDate = @cDate
			,	ppes.logId = @lid
			from
				dbo.tblProtPlusTpEnrollStatus ppes
			where
				ppes.tpId = @tpId


	        fetch next from curPP into
                @tpId
            ,   @efin      
            ,   @account_code   
            ,   @package           
            ,   @enroll_id       
            ,   @fname             
            ,   @lname             
            ,   @address1           
            ,   @city              
            ,   @state              
            ,   @zip              
            ,   @email             
            ,   @phone           
            ,   @pssn             
            ,   @fund_status   

		end

    close curPP
    deallocate curPP

    update tpes
        set tpes.StatusDate = @cDate
    ,   tpes.StatusId = 30
    ,   tpes.req_pplus_fee = tmf.req_pp_fee
    ,   tpes.pplus_pay_amt = tmf.pp_pay_amt
    ,   tpes.pplus_pay_date = tmf.pp_pay_date
    ,   tpes.fdate = tm.fdate
    from
        dbo.tblProtPlusTpEnrollStatus tpes join dbo.tblTaxmast tm  on tpes.pssn = tm.pssn
            and tpes.StatusId = 20
        join dbo.efin e on tm.efin = e.efin
        join (
                select
                    tmf1.pssn
                ,   sum(tmf1.reqAmount) req_pp_fee
                ,   max(tmf1.payDate) pp_pay_date
                ,   sum(tmf1.payAmount) pp_pay_amt
                ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
                from    
                    dbo.tblTaxmastFee tmf1
                where
                    tmf1.tag = 'AUD'
                    and tmf1.feeType = 1
                group by
                    tmf1.pssn
                ) tmf on tm.pssn = tmf.pssn
            and tmf.ppff = 1


	declare curPP cursor fast_forward for
        select
            ppes.tpId
        ,   convert(varchar(32),ppes.tpId) enroll_id
        ,   case 
                when tm.ral_flag = '5' then 'Crosslink-TPP-Bank'
                else 'Crosslink-TPP-Non-Bank'
            end package
        ,   'FUNDED' fund_status
        ,   convert(varchar(10),ppes.pplus_pay_date,101) effective_date
		,	tmf.pp_pay_amt
        from
            dbo.tblProtPlusTpEnrollStatus ppes join dbo.tblTaxmast tm on ppes.pssn = tm.pssn
                and ppes.StatusId = 30
            join dbo.efin e on tm.efin = e.efin
            join (
                    select
                        tmf1.pssn
                    ,   sum(tmf1.reqAmount) req_pp_fee
                    ,   max(tmf1.payDate) pp_pay_date
                    ,   sum(tmf1.payAmount) pp_pay_amt
                    ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag = 'AUD'
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                 ) tmf on tm.pssn = tmf.pssn

	open curPP
	fetch next from curPP into
        @tpId
    ,   @enroll_id       
    ,   @package           
    ,   @fund_status  
    ,   @effective_date  
	,	@payment_amount   

	while @@FETCH_STATUS = 0 
		begin

            set @fmtPost = null
            set @rData = null
            set @respCode = null
            set @errDesc = null

			if @effective_date is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Fund Date'

			print 'Begin Funding Processing for Enroll Id: ' + @enroll_id + ' for EFIN:' + @efin + ' ...'
	
			if @errDesc is null
				begin
					set @pData = 'action=' + @action 
						+ '|enroll_id=' + @enroll_id
                        + '|software=' + @software
						+ '|package=' + @package 
						+ '|fund_status=' + @fund_status                    
						+ '|effective_date=' + @effective_date 
						+ '|payment_amount=' + convert(varchar(20),@payment_amount) 

                    --print 'URL: ' + @url
                    --print 'Post Data: ' + @pData
                    --print 'HT Name: ' + @htName
                    --print 'HT Value: ' + @htValue

					/*****************************************************************
												REMOVE ASAP
					******************************************************************/
					-- added 1 second pause to help troubleshoot an issue at Prot Plus.  
					WAITFOR DELAY '00:00:01';
					/*****************************************************************/
--print convert(varchar(50),getdate(),113)
					exec dbAdmin.dbo.up_postJsonHt @url_maint, @pData, @htName, @htValue, @fmtPost output, @rData output, @respCode output, @errDesc output
--print convert(varchar(50),getdate(),113)

					--print 'Raw Data: ' + @pData
					--print 'Formatted JSON Post Data: ' + @fmtPost
					--print 'Return Data: ' + @rData
					print 'Response Code: ' + @respCode
					--print 'Error Description: ' + @errDesc

				end
			else 
				set @rData = @errDesc

			insert dbo.tblProtPlusTpEnrollLog(
				[tpId]				
			,	[postData]
			,	[responseCode]
			,	[responseData]
			,	[submitDate]
			)
				values (
					@tpId
				,	@fmtPost
				,	@respCode
				,	@rData
				,	@cDate
				)

			set @lid = SCOPE_IDENTITY()

			update ppes
				set ppes.StatusId = case	
										when patindex('%ACCEPTED%', @rData) > 0 then 40
										else 30
									end
			,	ppes.statusDate = @cDate
			,	ppes.logId = @lid
			from
				dbo.tblProtPlusTpEnrollStatus ppes
			where
				ppes.tpId = @tpId


	        fetch next from curPP into
                @tpId
            ,   @enroll_id       
            ,   @package           
            ,   @fund_status  
            ,   @effective_date 
			,	@payment_amount

		end

    close curPP
    deallocate curPP










































            










/*
select
    tm.efin
,   e.Account account_code
,   'Crosslink' software
,   case 
        when tm.ral_flag = '5' then 'Crosslink-TPP-Bank'
        else 'Crosslink-TPP-Non-Bank'
    end package
,   null enroll_id
,   dbo.udfGetCharacters(tm.pri_fname,'0-9 a-z') fname
,   dbo.udfGetCharacters(tm.pri_lname,'0-9 a-z') lname
,   dbo.udfGetCharacters(tm.[address],'0-9 a-z') [address]
,   dbo.udfGetCharacters(tm.city,'0-9 a-z') city
,   dbo.udfGetCharacters(tm.[state],'0-9 a-z') [state]
,   dbo.udfGetCharacters(tm.zip,'0-9 a-z') zip
,   tm.email_address email
,   left(tm.home_phone,3) phone1
,   substring(tm.home_phone,4,3) phone12
,   right(tm.home_phone,4) phone3
,   'INVOICE' bill_method
,   right(convert(varchar(25),tm.pssn),4) pssn
,   case 
        when tmf.ppff = 1 then 'FUNDED'
        else 'UNFUNDED'  
    end fund_status
from
    dbo.tblTaxmast tm join dbo.efin e on tm.efin = e.efin
    join (
            select
                tmf1.pssn
            ,   sum(tmf1.reqAmount) req_pp_fee
            ,   max(tmf1.payDate) pp_pay_date
            ,   sum(tmf1.payAmount) pp_pay_amt
            ,   case when sum(tmf1.reqAmount) > 0 and sum(tmf1.payAmount) >= sum(tmf1.reqAmount) then 1 else 0 end ppff
            from    
                dbo.tblTaxmastFee tmf1
            where
                tmf1.tag = 'AUD'
                and tmf1.feeType = 1
            group by
                tmf1.pssn
         ) tmf on tm.pssn = tmf.pssn
*/

