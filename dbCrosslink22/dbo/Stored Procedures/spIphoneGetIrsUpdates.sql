create PROCEDURE [dbo].[spIphoneGetIrsUpdates] 
	@UpdateID varchar(10)
AS

Declare @SQL varchar(max)
SELECT @SQL = 'SELECT type, issue, date, iphone FROM tblIrsUpdates WHERE Update_id = ' + @UpdateID
exec (@sql)


