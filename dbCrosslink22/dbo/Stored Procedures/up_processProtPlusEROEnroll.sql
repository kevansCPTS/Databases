CREATE procedure [dbo].[up_processProtPlusEROEnroll] --'https://myprotectionplus.com/testapi/agent_enrollment','Authentication-Token','0015c5266ae9cbd60a0e9ca8e318d5ff5f0e2857'
	@url			varchar(255)
,	@htName			varchar(255)
,	@htValue		varchar(255)
as

declare @cDate				datetime
declare @ero_name			varchar(35)
declare @account_code		varchar(8)
declare @company			varchar(35)
declare @efin				int
declare @reports_to         varchar(10)
declare @contact_name		varchar(35)
declare	@phone				varchar(10)
declare @addr1				varchar(35)
declare @city				varchar(22)
declare @state				varchar(2)
declare @zip				varchar(9)
declare	@efin_email			varchar(50)
declare @enrollId			int
declare @pData				varchar(max)
declare @fmtPost			varchar(max)
declare @rData				varchar(max)
declare @respCode			varchar(max)
declare @errDesc			varchar(max)
declare @lid				int
declare @masterAccount      varchar(8)
declare @season             smallint

	set nocount on

	set @cDate = getdate()
    set @season = convert(smallint,'20' + right( DB_NAME(),2))

	--set @url = 
	--set @htName = 'Authentication-Token'
	--set @htValue = '0015c5266ae9cbd60a0e9ca8e318d5ff5f0e2857'


	-- Add any new participating EROs
	insert dbo.tblProtPlusEROEnrollStatus(
		account
	,	efin
	,	eStatus
	,	statusDate
	,	createDate
	)
		select 
			aap.account
		,	e.Efin
		,	0 sStatus
		,	@cDate
		,	@cDate	
		from
			dbo.tblAccountAncillaryProduct aap join dbo.efin e on aap.account = e.Account
				and aap.tag = 'AUD'	
				and aap.agreeToParticipate = 1 
				and aap.agreeToTerms = 1
				and aap.account not in('PETZ01','WHIKIM')
                and aap.account = 'SBNR01'
            /*
            join dbo.vwLatestBankApplication lba on aap.account = lba.AccountID
                and e.Efin = lba.Efin
                and lba.Registered != 'U'
            */
            join (
                    select distinct
                        lba1.AccountID
                    ,   lba1.Efin
                    --,   lba1.BankID
                    --,   lba1.Registered
                    from
                        dbo.vwLatestBankApplication lba1
                    where
                        lba1.Registered != 'U'  
                    --order by
                    --    lba1.AccountID
                    --,   lba1.Efin
                    --,   lba1.BankID     
                    ) lba on aap.account = lba.AccountID
            and e.Efin = lba.Efin
			join dbCrosslinkglobal.dbo.tblUser u on e.UserID = u.[user_id]
			left join dbo.tblProtPlusEROEnrollStatus ppes on aap.account = ppes.account
				and e.Efin = ppes.efin
		where
			ppes.account is null
		

	declare curPP cursor fast_forward for
		select
			ppees.erollId
		,	isnull(e.FirstName,'') + ' ' + isnull(e.LastName,'') ero_name
		,	case 
                when rtrim(isnull(e.Company,'')) = '' then null
                else e.Company
            end Company  
		,	ppees.account account_code
		,	e.Efin
		--,	'Crosslink' software
		,	case 
                when rtrim(isnull(u.fname,'') + ' ' + isnull(u.lname,'')) = '' then null 
                else isnull(u.fname,'') + ' ' + isnull(u.lname,'')
            end contact_name
		,	case 
                when rtrim(isnull(e.Phone,'')) = '' then null
                else e.Phone
            end Phone  
		,	case 
                when rtrim(isnull(e.[Address],'')) = '' then null
                else e.[Address]
            end addr1   
		,	case 
                when rtrim(isnull(e.City,'')) = '' then null
                else e.City
            end City 
		,	case 
                when rtrim(isnull(e.[State],'')) = '' then null
                else e.[State]
            end [State]
		,	case 
                when rtrim(isnull(e.Zip,'')) = '' then null
                else e.Zip
            end Zip
		,	case 
                when rtrim(isnull(e.email,'')) = '' then null
                else e.email
            end efin_email
        ,   isnull(rt.parentAccount,ppees.account)  master_account_code  
        ,   rt.Efin reports_to
		from
			dbo.tblProtPlusEROEnrollStatus ppees join dbo.efin e on ppees.account = e.Account
				and ppees.efin = e.Efin
				and ppees.eStatus = 0
			join dbCrosslinkglobal.dbo.tblUser u on e.UserID = u.[user_id]
            left join (
                        select distinct
                            ch.parentAccount
                        ,   ch.childAccount
                        ,   lba.Efin
                        from
                            dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch join dbo.tblProtPlusEROEnrollStatus ppes on ch.parentAccount = ppes.account
                                and ch.season = @season
                                and ppes.eStatus = 1
                            join (
                                    select
                                        lba1.AccountID
                                    ,   lba1.Efin
                                    from
                                        (
                                            select distinct
                                                lba2.AccountID
                                            ,   lba2.Efin
                                            ,   lba2.UpdatedDate
                                            ,   row_number() over ( partition by lba2.AccountID order by lba2.UpdatedDate desc) rowNum
                                            from
                                                dbo.vwLatestBankApplication lba2
                                            where
                                                lba2.Registered != 'U'  
                                        ) lba1 
                                    where
                                        lba1.rowNum = 1
                                  ) lba on ch.parentAccount = lba.AccountID   
                      ) rt on ppees.account = rt.childAccount



	open curPP
	fetch next from curPP into
		@enrollId 
	,	@ero_name
	,	@company
	,	@account_code
	,	@efin
	,	@contact_name
	,	@phone
	,	@addr1
	,	@city
	,	@state				
	,	@zip				
	,	@efin_email			
    ,   @masterAccount	
    ,   @reports_to
	while @@FETCH_STATUS = 0 
		begin

            set @fmtPost = null
            set @rData = null
            set @respCode = null
            set @errDesc = null

			if @ero_name is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing ERO Name'
			if @company is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Company'
			if @contact_name is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Contact Name'
			if @phone is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Phone'
			if @addr1 is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Address'
			if @city is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing City'
			if @state is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing State'
			if @zip is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Zip'
			if @efin_email is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing Email'

			print 'Begin Processing: ' + @account_code + ' ' + convert(varchar(25),@efin) + ' ...'
	
			if @errDesc is null
				begin
					set @pData = 'ero_name=' + @ero_name 
						+ '|company=' + @company
						+ '|account_code=' + @account_code
						+ '|efin=' + convert(varchar(25),@efin) 
						+ '|reports_to=' + convert(varchar(25),isnull(@reports_to,'')) 
                        + '|master_account_code=' + isnull(@masterAccount,'')
						+ '|software=Crosslink'
						+ '|contact_name=' + @contact_name
						+ '|phone=' + @phone 
						+ '|addr1=' + @addr1 
						--+ '|addr2= '
						+ '|city=' + @city 
						+ '|state=' + @state 
						+ '|zip=' + @zip 
						+ '|efin_email=' + @efin_email

                    print 'URL: ' + @url
                    print 'Post Data: ' + @pData
                    print 'HT Name: ' + @htName
                    print 'HT Value: ' + @htValue


					exec dbAdmin.dbo.up_postJsonHt @url, @pData, @htName, @htValue, @fmtPost output, @rData output, @respCode output, @errDesc output

					--print 'Raw Data: ' + @pData
					--print 'Formatted JSON Post Data: ' + @fmtPost
					--print 'Return Data: ' + @rData
					--print 'Response Code: ' + @respCode
					--print 'Error Description: ' + @errDesc

				end
			else 
				set @rData = @errDesc

			insert dbo.tblProtPlusEROEnrollLog(
				[account]				
			,	[efin]
			,	[postData]
			,	[responseCode]
			,	[responseData]
			,	[submitDate]
			)
				values (
					@account_code
				,	@efin
				,	@fmtPost
				,	@respCode
				,	@rData
				,	@cDate
				)

			set @lid = SCOPE_IDENTITY()

			update ppees
				set ppees.eStatus = case	
										when patindex('%ACCEPTED%', @rData) > 0 then 1
										else 0
									end
			,	ppees.statusDate = @cDate
			,	ppees.logId = @lid
			
			from
				dbo.tblProtPlusEROEnrollStatus ppees
			where
				ppees.erollId = @enrollId


			fetch next from curPP into 
				@enrollId 
			,	@ero_name
			,	@company
			,	@account_code
			,	@efin
			,	@contact_name
			,	@phone
			,	@addr1
			,	@city
			,	@state				
			,	@zip				
			,	@efin_email				
            ,   @masterAccount	
            ,   @reports_to
		end

close curPP
deallocate curPP
























