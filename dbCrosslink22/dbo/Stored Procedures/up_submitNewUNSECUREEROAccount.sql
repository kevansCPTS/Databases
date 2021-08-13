Create PROCEDURE [dbo].[up_submitNewUNSECUREEROAccount] 
	-- Add the parameters for the stored procedure here
	@userid int

AS
BEGIN

	declare @efinid int
	declare @password varchar(20)
	declare @rData varchar(max)
	declare @payload varchar(max)
	declare @uri varchar(max)

	set @uri = case when @@SERVERNAME like 'DEV%' then 'https://devws.petzent.com/AppServices2019/User/User_New_UNSECURE_EROAccount'
                    when @@SERVERNAME like 'QA%' then 'https://qaws.petzent.com/AppServices2019/User/User_New_UNSECURE_EROAccount'
					when @@SERVERNAME like 'PRODDB%' then 'https://ws.petzent.com/AppServices2019/User/User_New_UNSECURE_EROAccount'
					end

	select @password = passwd from tblUser where user_id = @userid

		set @payload = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
			<Body>
			<?xml version="1.0"?>
			<CreateUserRequest>
			  <Username>' + cast(@userid as varchar(10)) + '</Username>
			  <Password>' + @password + '</Password>
			  <AuthLoginType>5</AuthLoginType>
			  <GroupID>1</GroupID>
			  <eroID></eroID>
			</CreateUserRequest>
			</Body>
		</Envelope>'
		set @rData = [dbAdmin].[dbo].[udf_httpPostType](@uri,@payload,'text/xml','','')
		select @rData

End
