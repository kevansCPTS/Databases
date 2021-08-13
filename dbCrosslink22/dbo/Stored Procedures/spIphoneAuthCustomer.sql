CREATE PROCEDURE [dbo].[spIphoneAuthCustomer] 
	@account varchar(8),
	@password varchar(20)
	

AS

SELECT count(*) AS authenticated FROM dbcrosslinkglobal..customer WHERE account = @account AND web_passwd = @password


