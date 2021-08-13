
CREATE PROC spMobileCustomerLogin
  @username varchar(8),
  @password varchar(16)
AS

SELECT TOP 1 * FROM customer
WHERE account = @username
AND web_passwd = @password
