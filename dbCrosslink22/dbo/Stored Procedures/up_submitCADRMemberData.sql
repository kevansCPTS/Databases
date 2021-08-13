CREATE procedure [dbo].[up_submitCADRMemberData] --'https://www.enrollment123.com/gateway/member.cfm'--'http://httpbin.org/post'
    @uri    nvarchar(1000)
as 

declare @corpId                 int
declare @CADAgentId             int
declare @productCode            int
declare @productSubCode         int
declare @effectiveDate          varchar(10)
declare @expirationDate         varchar(10)
declare @uniqueId               int
declare @fName                  varchar(16)
declare @midInit                varchar(1)
declare @lName                  varchar(32)
declare @dob                    varchar(10)
declare @gender                 char(1)
declare @address1               varchar(35)
declare @address2               varchar(35)
declare @city                   varchar(22)
declare @state                  char(2)
declare @zipCode                varchar(9)
declare @email                  varchar(44)
declare @hPhone                 varchar(10)
declare @fax                    varchar(10)
declare @payProc                char(1)
declare @payType                char(2)
declare @firstBilDate           varchar(10)
declare @recurringDate          varchar(10)
declare @createDate             varchar(10)
declare @sourceDetail           varchar(50)

--declare @fufillDate             varchar(10)

declare @postData               varchar(1000)
declare @result                 nvarchar(1000)

declare @petzAgentId            int

set nocount on 

    -- Set the Petz agent Id
    set @petzAgentId = 103062


    -- Submit new member data
    declare curNewMember cursor fast_forward
    for
        select
	        1187 CORP_ID
        ,	@petzAgentId AGENT_ID
        ,	10882 PRODUCT_CODE
        ,	21 PRODUCT_SUBCODE
        ,	convert(varchar(10),tm.fdate,101) EFFECTIVE_DATE												
        ,	convert(varchar(10),dateadd(day,-1,dateadd(month,1,tm.fdate)),101) EXPIRATION_DATE		
        ,	tm.pssn UNIQUE_ID
        ,	tm.pri_fname FIRST_NAME
        ,	tm.pri_init MIDDLE_INITIAL
        ,	tm.pri_lname LAST_NAME
        ,	substring(la.pri_dob,5,2) + '/' + right(la.pri_dob,2) + '/' + left(la.pri_dob,4) DOB
        ,	tm.gender GENDER																		
        ,	tm.[address] ADDRESS_1
        ,	'' ADDRESS_2
        ,	tm.city CITY
        ,	tm.[state] [STATE]
        ,	left(tm.zip,5) ZIP_CODE
        ,	tm.email_address EMAIL
        ,	tm.home_phone EVEPHONE
        ,	'' FAX
        ,	'N' PAYMENT_PROCESS
        ,	'LB' PAYMENT_TYPE
        ,	convert(varchar(10),tm.fdate,101) FIRSTBILLING_DATE		
        ,	convert(varchar(10),tm.fdate,101) RECURRING_DATE		
        ,	convert(varchar(10),tm.fdate,101) CREATED_DATE 
        ,   cmd.AgentId SOURCE_DETAIL   
        from
            [dbo].[tblCADMemberData] cmd join [dbo].[tblTaxmast] tm on cmd.pssn = tm.pssn
                and cmd.StatusId = 1
	        left join dbCrosslink16.dbo.tblLoanApp la on tm.pssn = la.pssn

    open curNewMember
    fetch next from curNewMember into
        @corpId
    ,   @CADAgentId     
    ,   @productCode           
    ,   @productSubCode      
    ,   @effectiveDate        
    ,   @expirationDate         
    ,   @uniqueId              
    ,   @fName                  
    ,   @midInit            
    ,   @lName                 
    ,   @dob                   
    ,   @gender                 
    ,   @address1              
    ,   @address2               
    ,   @city                   
    ,   @state                  
    ,   @zipCode                
    ,   @email                  
    ,   @hPhone
    ,   @fax
    ,   @payProc                
    ,   @payType                
    ,   @firstBilDate           
    ,   @recurringDate          
    ,   @createDate 
    ,   @sourceDetail
            

    while @@fetch_status = 0
        begin 
            set @postData = 'CORP_ID=' + isnull(convert(varchar(25),@corpId),'')
                + '&AGENT_ID=' + isnull(convert(varchar(25),@CADAgentId),'')     
                + '&PRODUCT_CODE=' + isnull(convert(varchar(25),@productCode),'')           
                + '&PRODUCT_SUBCODE=' + isnull(convert(varchar(25),@productSubCode),'')      
                + '&EFFECTIVE_DATE=' + isnull(@effectiveDate,'')        
                + '&EXPIRATION_DATE=' + isnull(@expirationDate,'')         
                + '&UNIQUE_ID=' + isnull(convert(varchar(9),@uniqueId),'')              
                + '&FIRST_NAME=' + isnull(@fName,'')                  
                + '&MIDDLE_INITIAL=' + isnull(@midInit,'')            
                + '&LAST_NAME=' + isnull(@lName,'')                 
                + '&DOB=' + isnull(@dob,'')                   
                + '&GENDER=' + isnull(@gender,'')                 
                + '&ADDRESS_1=' + isnull(@address1,'')              
                + '&ADDRESS_2=' + isnull(@address2,'')               
                + '&CITY=' + isnull(@city,'')                   
                + '&STATE=' + isnull(@state,'')                  
                + '&ZIP_CODE=' + isnull(@zipCode,'')                
                + '&EMAIL=' + isnull(@email,'')                  
                + '&DAYPHONE=' + isnull(@hPhone,'')   
                + '&FAX=' + isnull(@fax,'')               
                + '&PAYMENT_PROCESS=' + isnull(@payProc,'')                
                + '&PAYMENT_TYPE=' + isnull(@payType,'')                
                + '&FIRSTBILLING_DATE=' + isnull(@firstBilDate,'')           
                + '&RECURRING_DATE=' + isnull(@recurringDate,'')          
                + '&CREATED_DATE=' + isnull(@createDate,'') 
                + '&SOURCE_DETAIL=' + isnull(@sourceDetail,'')

 
            print @postData

            -- Log the post data
            insert dbo.tblCADMemberSubmitLog([logData],[logDate])
                select
                    'SSN=' + convert(varchar(9),@uniqueId) + ';PostData=' + @postData
                ,   getdate()
            
            set @result = null
            set @result = [dbAdmin].[dbo].[udf_httpPost](@uri,@postData,'','')

            -- Log the result data
            insert dbo.tblCADMemberSubmitLog([logData],[logDate])
                select
                    'SSN=' + convert(varchar(9),@uniqueId)  + ';Result=' + @result
                ,   getdate()
        
            update cmd
                set cmd.StatusId = case when left(@result,1) = 1 then 2 else 1 end
            ,   cmd.StatusDate = getdate()
            ,   cmd.CADMemberId = case when left(@result,1) = 1 then replace(right(@result,len(@result)-2),'|','') else null end
            ,   cmd.CADRResult = convert(varchar(1000),@result)
            from
                [dbo].[tblCADMemberData] cmd
            where
                cmd.pssn = @uniqueId
                --and left(@result,1) = 1
  
            print @result

            fetch next from curNewMember into
                @corpId
            ,   @CADAgentId     
            ,   @productCode           
            ,   @productSubCode      
            ,   @effectiveDate        
            ,   @expirationDate         
            ,   @uniqueId              
            ,   @fName                  
            ,   @midInit            
            ,   @lName                 
            ,   @dob                   
            ,   @gender                 
            ,   @address1              
            ,   @address2               
            ,   @city                   
            ,   @state                  
            ,   @zipCode                
            ,   @email                  
            ,   @hPhone
            ,   @fax
            ,   @payProc                
            ,   @payType                
            ,   @firstBilDate           
            ,   @recurringDate          
            ,   @createDate 
            ,   @sourceDetail
                     
        end

    close curNewMember
    deallocate curNewMember


    -- Submit new fully-funded member data
    declare curFundedMember cursor fast_forward
    for
        select
	        '1187' CORP_ID
        ,	@petzAgentId AGENT_ID
        ,	10882 PRODUCT_CODE
        ,	'21' PRODUCT_SUBCODE
        ,	convert(varchar(10),dateadd(day,-1,dateadd(year,1,tm.fdate)),101) EXPIRATION_DATE
        ,	tm.pssn UNIQUE_ID
--        ,	convert(varchar(10),tm.cadr_pay_date,101) FULFILLMENT_DATE
        ,   'Y' PAYMENT_PROCESS
        ,   'LB' PAYMENT_TYPE

        from
            [dbo].[tblCADMemberData] cmd join [dbo].[tblTaxmast] tm on cmd.pssn = tm.pssn
                and cmd.StatusId = 3


    open curFundedMember
    fetch next from curFundedMember into
        @corpId
    ,   @CADAgentId     
    ,   @productCode           
    ,   @productSubCode      
    ,   @expirationDate         
    ,   @uniqueId              
--    ,   @fufillDate  
    ,   @payProc  
    ,   @payType       

    while @@fetch_status = 0
        begin 
            set @postData = 'CORP_ID=' + convert(varchar(25),@corpId)
                + '&AGENT_ID=' + convert(varchar(25),@CADAgentId)     
                + '&PRODUCT_CODE=' + convert(varchar(25),@productCode)           
                + '&PRODUCT_SUBCODE=' + convert(varchar(25),@productSubCode)      
                + '&EXPIRATION_DATE=' + isnull(@expirationDate,'')             
                + '&UNIQUE_ID=' + isnull(convert(varchar(9),@uniqueId),'')              
--                + '&FULFILLMENT_DATE=' + isnull(@fufillDate,'')                  
                + '&PAYMENT_PROCESS=' + @payProc                
                + '&PAYMENT_TYPE=' + @payType                


            -- Log the post data
            insert dbo.tblCADMemberSubmitLog([logData],[logDate])
                select
                    'SSN=' + convert(varchar(9),@uniqueId)  + ';PostData=' + @postData
                ,   getdate()
            
            print @postdata

            set @result = null
            set @result = [dbAdmin].[dbo].[udf_httpPost](@uri,@postData,'','')

            -- Log the result data
            insert dbo.tblCADMemberSubmitLog([logData],[logDate])
                select
                    'SSN=' + convert(varchar(9),@uniqueId)  + ';Result=' + @result
                ,   getdate()

        
            update cmd
                set cmd.StatusId = case when left(@result,1) = 1 then 4 else 3 end
            ,   cmd.StatusDate = getdate()
            ,   cmd.CADRResult = convert(varchar(1000),@result)
            from
                [dbo].[tblCADMemberData] cmd
            where
                cmd.pssn = @uniqueId
                --and left(@result,1) = 1
 
            print @result

            fetch next from curFundedMember into
                @corpId
            ,   @CADAgentId     
            ,   @productCode           
            ,   @productSubCode      
            ,   @expirationDate         
            ,   @uniqueId              
--            ,   @fufillDate          
            ,   @payProc  
            ,   @payType       
       end

    close curFundedMember
    deallocate curFundedMember





















/*
select
	'1187' CORP_ID
,	ce.CADAgentId AGENT_ID
,	'9295' PRODUCT_CODE
,	'21' PRODUCT_SUBCODE
,	convert(varchar(10),tm.fdate,101) EFFECTIVE_DATE												
,	convert(varchar(10),dateadd(day,-1,dateadd(month,1,tm.fdate)),101) EXPIRATION_DATE		
,	convert(varchar(9),tm.pssn) UNIQUE_ID
,	tm.pri_fname FIRST_NAME
,	tm.pri_init MIDDLE_INITIAL
,	tm.pri_lname LAST_NAME
,	substring(la.pri_dob,5,2) + '/' + right(la.pri_dob,2) + '/' + left(la.pri_dob,4) DOB
,	tm.gender GENDER																		
,	tm.[address] ADDRESS_1
,	'' ADDRESS_2
,	tm.city CITY
,	tm.[state] [STATE]
,	tm.zip ZIP_CODE
,	tm.email_address EMAIL
,	tm.home_phone EVEPHONE
,	'' FAX
,	'N' PAYMENT_PROCESS
,	'LB' PAYMENT_TYPE
,	convert(varchar(10),tm.fdate,101) FIRSTBILLING_DATE		
,	convert(varchar(10),tm.fdate,101) RECURRING_DATE		
,	convert(varchar(10),tm.fdate,101) CREATED_DATE

/*
,	tm.*
,	'***************************'
,	la.*
*/

from
	dbCrosslink14.dbo.tblTaxmast tm join dbCrosslink14.dbo.tblCADEnrollment ce on tm.efin = ce.EFIN
		and tm.[user_id] = ce.UserId
		AND CE.StatusId in(1,2)
	left join dbCrosslink14.dbo.tblLoanApp la on tm.pssn = la.pssn









select
	'1187' CORP_ID
,	ce.AgentId AGENT_ID
,	'9295' PRODUCT_CODE
,	'21' PRODUCT_SUBCODE
,	convert(varchar(10),dateadd(day,-1,dateadd(year,1,tm.fdate)),101) EXPIRATION_DATE
,	convert(varchar(9),tm.pssn) UNIQUE_ID
,	convert(varchar(10),tm.cadr_pay_date,101) FULFILLMENT_DATE

from
	dbCrosslink14.dbo.tblTaxmast tm join dbCrosslink14.dbo.tblCADEnrollment ce on tm.efin = ce.EFIN
		and tm.[user_id] = ce.UserId
		AND CE.StatusId in(1,2)
	left join dbCrosslink14.dbo.tblLoanApp la on tm.pssn = la.pssn

*/




