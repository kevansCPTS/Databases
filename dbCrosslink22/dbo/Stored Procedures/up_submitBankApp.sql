CREATE PROCEDURE [dbo].[up_submitBankApp] 
	-- Add the parameters for the stored procedure here
	@efin int,
	@bankcode varchar(1),
	@accountid varchar(10),
	@updatedby varchar(20)

AS
BEGIN

	declare @bankappid int
	declare @efinid int
	declare @ipaddr varchar(16)
	declare @rData varchar(max)
	declare @payload varchar(max)
	declare @uri varchar(max)

	set @uri = case when @@SERVERNAME like 'DEV%' then 'https://devws.petzent.com/crosslinkws/WS/webservice21.asmx'
                    when @@SERVERNAME like 'QA%' then 'https://qaws.petzent.com/crosslinkws/WS/webservice21.asmx'
					when @@SERVERNAME like 'PRODDB%' then 'https://ws.petzent.com/crosslinkws/WS/webservice21.asmx'
					end

	select @bankappid = BankAppID, @efinid = efinid, @ipaddr = IPAddress from vwlatestbankapplication where BankID = @bankcode and AccountID = @accountid and Registered = 'A' and efin = @efin

	if (@bankappid is not null) 
	BEGIN
		set @payload = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
			<Body>
				<submitBankApplication xmlns="http://www.crosslinktax.com/">
					<bankappid>' + cast(@bankappid as varchar(10)) + '</bankappid>
					<efinid>' + cast(@efinid as varchar(10)) + '</efinid>
					<accountid>' + @accountid + '</accountid>
					<bankcode>' + @bankcode + '</bankcode>
					<updatedby>' + @updatedby + '</updatedby>
					<IPaddr>' + @ipaddr + '</IPaddr>
				</submitBankApplication>
			</Body>
		</Envelope>'
		set @rData = [dbAdmin].[dbo].[udf_httpPostType](@uri,@payload,'text/xml','','')
		select @rData
	End

	select @bankappid = BankAppID, @efinid = efinid, @ipaddr = IPAddress from vwlatestbankapplication where BankID = @bankcode and AccountID = @accountid and Registered = 'U' and efin = @efin

	if (@bankappid is not null) 
	Begin
		set @payload = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
			<Body>
				<submitBankApplication xmlns="http://www.crosslinktax.com/">
					<bankappid>' + cast(@bankappid as varchar(10)) + '</bankappid>
					<efinid>' + cast(@efinid as varchar(10)) + '</efinid>
					<accountid>' + @accountid + '</accountid>
					<bankcode>' + @bankcode + '</bankcode>
					<updatedby>' + @updatedby + '</updatedby>
					<IPaddr>' + @ipaddr + '</IPaddr>
				</submitBankApplication>
			</Body>
		</Envelope>'
		set @rData = [dbAdmin].[dbo].[udf_httpPostType](@uri,@payload,'text/xml','','')
		select @rData
	End
End
