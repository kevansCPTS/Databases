
CREATE PROC spMTOLoginAccount
	@account varchar(16), @password varchar(16)
AS

SELECT TOP 1 * FROM customer
where account = @account
AND web_passwd = @password


