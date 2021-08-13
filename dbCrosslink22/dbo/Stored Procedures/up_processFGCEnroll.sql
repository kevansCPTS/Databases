
CREATE procedure [dbo].[up_processFGCEnroll] --'https://api.tcrosys.com/api/v1','IuoT9IdL2lgnsfoVnGJ','p751OAYqXBEgTidT2hGkN8pkY'
    @bUrl			    varchar(255)
,   @apiKey             varchar(255)             
,   @apSecret           varchar(255)
as

/*


fname
lname
saddress
city
state
zip
email
phone
broker_id (ero EFIN)
altphone(client work phone)
cellphone
birthdate (mm-dd-yyyy)

report_rec (ACK Date)
return_doc (fund date)
*/


/*
Dev - 
Key:                    tcrodev1
Secret:               Hj7Q1
API link:              https://api.tcrosys.com/api/v1/
API docs:            https://api.tcrosys.com/swagger-ui/

Prod - 
API link:              https://api.tcrosys.com/api/v1/
Key	IuoT9IdL2lgnsfoVnGJ
Secret	p751OAYqXBEgTidT2hGkN8pkY


 
*/

declare @wUrl                   varchar(max)
declare @account_code		    varchar(8)

declare @pData				    varchar(max)
declare @rData				    varchar(max)
declare @respCode			    varchar(max)
declare @fmtPost			    varchar(max)
declare @errDesc			    varchar(max)

declare @errstr                 varchar(1000)

declare @tpId                   int         --(ero EFIN)
declare @fname                  varchar(16)
declare @lname                  varchar(32)
declare @address                varchar(35)
declare @city                   varchar(22)
declare @state                  char(2)
declare @zip                    varchar(12)
declare @email                  varchar(44)
declare @phone                  varchar(10)
declare @broker_id              int         --(ero EFIN)
declare @altphone               varchar(10) --(client work phone)
declare @cellphone              varchar(10) 
declare @birthdate              date        --(mm-dd-yyyy)
declare @report_rec             date        --(ACK Date)

--declare @return_doc             date        --(fund date)

declare @authToken              varchar(255)     

declare @lid                    int
declare @cDate                  datetime

declare @fgcid                  int
declare @fundDate               datetime
declare @jsonMod                varchar(max)
declare @returndoc              date
        


	set nocount on

    -- get a current auth token
    --set @bUrl = 'https://api.tcrosys.com/api/v1'
    set @cdate = getdate()



	set @pData = 'api_key=' + @apiKey
		+ '|api_secret=' + @apSecret 
    set @wUrl = @bUrl + '/login'

    exec dbAdmin.dbo.up_postJson @wUrl, @pData, @fmtPost output, @rData output, @respCode output, @errDesc output

    /*
	print 'Raw Data: ' + @pData
	print 'Formatted JSON Post Data: ' + @fmtPost
	print 'Return Data: ' + @rData
	print 'Response Code: ' + @respCode
	print 'Error Description: ' + @errDesc
    */

    if @respCode = 200
        select 
            @authToken = 'api_token=' + stringValue 
        from 
            dbo.tvudf_parseJSON( @rData)
        where
            [NAME] = 'token'

    -- Bail if no token is generated.    
    if @authToken is null
        begin
            set @errstr = 'Failed to generate an authentication token.'      
            raiserror(@errstr,11,1)                   
            return
        end
    
    select @authToken Token

    return

    -- add new enrollees to the status table
    insert dbo.tblFGCEnrollStatus(
        [pssn]
    ,   [Account]
    ,   [userId]
    ,   [EFIN]
    ,   [fdate]
    ,   [StatusId]
    ,   [StatusDate]
    )
        select
            tf.pssn
        ,   u.account
        ,   tm.[user_id]
        ,   tm.efin
        ,   tm.fdate
        ,   10 statusId
        ,   @cdate statusDate
        from
            dbo.tblTaxmastFee tf join dbo.tblAncillaryProduct ap on tf.aprodId = ap.aprodId
                and tf.feeType = 1
                and ap.tag = 'CDE'
            join dbo.tblTaxmast tm on tf.pssn = tm.pssn
            join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
            left join dbo.tblFGCEnrollStatus fes on tf.pssn = fes.pssn
        where
            fes.pssn is null


    -- process pending new enrollees submissions
    declare curEnroll cursor fast_forward
    for
        select top 1
            fes.tpId
        ,   rtrim(tm.pri_fname)
        ,   rtrim(tm.pri_lname)
        ,   rtrim(tm.[address])
        ,   rtrim(tm.city)
        ,   tm.[state]
        ,   tm.zip
        ,   rtrim(tm.email_address)
        ,   rtrim(tm.home_phone)
        ,   fes.EFIN
        ,   rtrim(tm.work_phone)
        ,   rtrim(rm.PrimaryCell)
        ,   rtrim(rm.TaxpayerDOB)
        ,   rtrim(tm.irs_ack_dt)
        from
            dbo.tblFGCEnrollStatus fes join dbo.tblTaxmast tm on fes.pssn = tm.pssn
                and fes.StatusId = 10
            join dbo.tblReturnMaster rm on fes.pssn = rm.PrimarySSN
                and tm.[user_id] = rm.[UserID]
                and rm.FilingStatus = 1
            join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
        

    open curEnroll
    fetch next from curEnroll into
        @tpId   
    ,   @fname
    ,   @lname
    ,   @address
    ,   @city
    ,   @state
    ,   @zip
    ,   @email
    ,   @phone
    ,   @broker_id
    ,   @altphone
    ,   @cellphone
    ,   @birthdate
    ,   @report_rec

    while @@fetch_status = 0
        begin 

            set @rData = null
            set @pData = null
            set @fmtPost = null
            set @respCode = null
            set @errDesc = null

            /*
			if @ero_name is null
				set @errDesc = isnull(@errDesc,'') + '|' + 'Missing ERO Name'
            */

			print 'Begin Processing tpId: ' + convert(varchar(25),@tpId) + ' ...'
	
			set @pData = '&name=' + rtrim(isnull(@fname,'')) + ' ' + rtrim(isnull(@lname,''))
				+ '&address=' + rtrim(isnull(@address,'')) 
				+ '&city=' + rtrim(isnull(@city,''))  
				+ '&state=' + @state 
				+ '&zip=' + left(rtrim(isnull(@zip,'')),9)  
				+ '&email=' + rtrim(isnull(@email,'')) 
				+ '&phone=' + rtrim(isnull(@phone,''))  
				+ '&broker_id=' + convert(varchar(25),isnull(@broker_id,''))
				+ '&altphone=' + rtrim(isnull(@altphone,''))  
				+ '&cellphone=5555555555' -- + rtrim(isnull(@cellphone,'5555555555'))  
				+ '&birthdate=' + isnull(convert(varchar(10),@birthdate),'') 
				+ '&reportreceived=' + isnull(convert(varchar(10),@report_rec),'') 

            set @wUrl = @bUrl + '/client'
            set @fmtPost = @authToken + @pData

            set @rData = [dbAdmin].[dbo].[udf_httpPost](@wUrl,@fmtPost,'','')

            print 'URL: ' + @wUrl
            print 'Post Data: ' + @pData
			print 'Return Data: ' + @rData
			print 'Response Code: ' + @respCode

			insert dbo.tblFGCEnrollLog(
				[tpId]				
			,	[postData]
			,	[responseData]
			,	[submitDate]
			)
				values (
					@tpId
				,	@pData
				,	@rData
				,	@cdate
				)

			set @lid = SCOPE_IDENTITY()

            -- get the response to determine success and update the status 
            set @jsonMod = replace(@rData,'}',',"endVal":"0"}')
            
            select 
                @fgcid = a.stringvalue
            from 
                dbo.tvudf_parseJSON(@jsonMod) a
            where
                a.[NAME] = 'id'


			update fes
				set fes.StatusId = case	
										when @fgcid is not null then 20 
                                        else 10
									end
			,	fes.StatusDate = @cdate
			,	fes.logId = @lid
            ,   fes.fgcId = @fgcid
			from
				dbo.tblFGCEnrollStatus fes
			where
				fes.tpId = @tpId


            fetch next from curEnroll into
                @tpId   
            ,   @fname
            ,   @lname
            ,   @address
            ,   @city
            ,   @state
            ,   @zip
            ,   @email
            ,   @phone
            ,   @broker_id
            ,   @altphone
            ,   @cellphone
            ,   @birthdate
            ,   @report_rec
        end

    close curEnroll
    deallocate curEnroll
    


    -- get the funded information 
    update fes  
        set fes.fundDate = tm.fullyFundedDate
    ,   fes.StatusId = 30
    ,   fes.StatusDate = @cDate
    from
        dbo.tblFGCEnrollStatus fes join dbo.tblTaxmast tm on fes.pssn = tm.pssn 
            and tm.isFullyFunded = 1
            and fes.StatusId = 20


    -- update FGC client record with funding data
    declare curFund cursor fast_forward for
        select
            fes.tpId
        ,   fes.fgcId
        ,   fes.fundDate
        from
            dbo.tblFGCEnrollStatus fes
        where
            fes.StatusId = 30
            and fes.fundDate is not null
            and fes.fgcId is not null

    open curFund
    fetch next from curFund into
        @tpId   
    ,   @fgcid
    ,   @fundDate


    while @@fetch_status = 0
        begin 

			set @pData = '&returndoc=' + convert(char(10),@fundDate,121)

            set @wUrl = @bUrl + '/client/' + convert(varchar(25),@fgcid)
            set @fmtPost = @authToken + @pData

            set @rData = [dbAdmin].[dbo].[udf_httpPut](@wUrl,@fmtPost,'','')

            print 'URL: ' + @wUrl
            print 'Post Data: ' + @pData
			print 'Return Data: ' + @rData
			print 'Response Code: ' + @respCode

			insert dbo.tblFGCEnrollLog(
				[tpId]				
			,	[postData]
			,	[responseData]
			,	[submitDate]
			)
				values (
					@tpId
				,	@pData
				,	@rData
				,	@cdate
				)

			set @lid = SCOPE_IDENTITY()

            -- get the response to determine success and update the status 
            set @returndoc = null
            select 
                @returndoc = a.stringvalue
            from 
                dbo.tvudf_parseJSON(@rData) a
            where
                a.[NAME] = 'returndoc'

			update fes
				set fes.StatusId = case 
                                        when convert(date,@fundDate) = @returndoc then 40 
                                        else 30
                                   end         
			,	fes.StatusDate = @cdate
			,	fes.logId = @lid
			from
				dbo.tblFGCEnrollStatus fes
			where
				fes.tpId = @tpId


            fetch next from curFund into
                @tpId   
            ,   @fgcid
            ,   @fundDate
        end

    close curFund
    deallocate curFund




