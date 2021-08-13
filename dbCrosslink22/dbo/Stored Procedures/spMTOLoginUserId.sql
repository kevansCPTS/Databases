
CREATE PROC spMTOLoginUserId
	@userid int, @password varchar(16)
AS

SELECT TOP 1 * FROM tblUser
WHERE user_id = @userid
AND web_passwd = @password

