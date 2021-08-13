CREATE PROCEDURE [dbo].[spAuthCustomer] 
	@account varchar(8),
	@password varchar(20)
	

AS

Declare @informixSQL varchar(max)
SELECT @informixSQL = 'SELECT count(*) AS authenticated FROM openquery (rh1, ''SELECT * FROM customer WHERE account = ''''' + @account + ''''' and web_passwd = ''''' + @password + ''''''')'
exec (@informixSQL)


