create PROCEDURE [dbo].[spIphoneGetUsers] 
	@account varchar(8)
	

AS

SELECT rtrim(addr1) + ', ' + rtrim(city) + ', ' + rtrim(state) AS address, 
user_id, company, addr1, city, state FROM tbluser 
WHERE account = @account and status = 'L'


