CREATE PROCEDURE [dbo].[up_submitBankSelect] 
	-- Add the parameters for the stored procedure here
	@efin int,
	@bankcode varchar(1),
	@accountid varchar(10)

AS
BEGIN

	declare @efinid int
	declare @eroAdvance char(1)
	declare @rData varchar(max)
	declare @payload varchar(max)
	declare @uri varchar(max)

	set @uri = case when @@SERVERNAME like 'DEV%' then 'https://devws.petzent.com/crosslinkws/WS/webservice21.asmx'
                    when @@SERVERNAME like 'QA%' then 'https://qaws.petzent.com/crosslinkws/WS/webservice21.asmx'
					when @@SERVERNAME like 'PROD%' then 'https://ws.petzent.com/crosslinkws/WS/webservice21.asmx'
					end

	select @efinid = efinid from efin where efin = @efin

		set @payload = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
			<Body>
				<updateBankSelection xmlns="http://www.crosslinktax.com/">
				  <efinid>' + cast(@efinid as varchar(10)) + '</efinid>
				  <bankcode>' + @bankcode + '</bankcode>
				  <accountid>' + @accountid + '</accountid>
				  <franchiseuserid>0</franchiseuserid>
				</updateBankSelection>    
			</Body>
		</Envelope>'
		set @rData = [dbAdmin].[dbo].[udf_httpPostType](@uri,@payload,'text/xml','','')
		select @rData

End
