-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertInformixEFINRegr]
	@EFIN	  char(6),
	@BankID   char(1),
	@RspDate  char(10),
	@AckResp  char(1),
	@EFINErr  char(5),
	@ProdStat char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Date char(4), @Time char(6), @RecType char(1), @iSQL varchar(max), @Master char(6), @EFIN2 char(6)

	-- Set Default Record Type and pull Response Date and Time apart.
	SELECT @RecType = '3', @Date = SUBSTRING(@RspDate, 1, 4), @Time = SUBSTRING(@RspDate, 5, 6)

	-- Get the Master EFIN.
	SET @iSQL = 'select master from openquery(rh1, ''select master from efin where efin = ''''' + @EFIN + ''''''')'

	PRINT @iSQL
	
	-- Create Temporary Table.
	CREATE TABLE #tempEFINRegr (Master char(6))

	-- Insert into the temporary table.
	INSERT #tempEFINRegr
	EXEC (@iSQL)

	-- Select back the master efin.
	SELECT @Master = [Master] FROM #tempEFINRegr

	-- Drop the temporary table.
	DROP TABLE #tempEFINRegr

	-- Find out whether this record exists in RH1 first.
	SET @iSQL = 'select efin from openquery(rh1, ''select * from efin_regr where efin = ''''' + @EFIN + ''''' and rsp_date = ''''' 
		+ @Date + ''''' and rsp_time = ''''' + @Time + ''''''')'

	PRINT @iSQL

	-- Create temporary table and push record in.
	CREATE TABLE #tempEFINRegr2 (efin char(6))

	INSERT #tempEFINRegr2
	EXEC (@iSQL)

	-- Select back the efin
	SELECT @EFIN2 = IsNull(EFIN, '') FROM #tempEFINRegr2

	-- Drop Temporary table.
	DROP TABLE #tempEFINRegr2

	PRINT 'EFIN: ' + IsNull(@EFIN2, '')

	IF @EFIN2 <> ''
	BEGIN
		-- Insert statements for procedure here
		SET @iSQL = 'insert into efin_regr (rec_type, master, efin, bank_id, rsp_date, rsp_time, bank_efin_stat, bank_efin_error, bank_efin_products) ' +
					'values (''' + @RecType + ''', ''' + 
					@Master + ''', ''' + 
					@EFIN + ''', ''' +
					@BankID + ''', ''' +
					@Date + ''', ''' +
					@Time + ''', ''' + 
					@AckResp + ''', ''' +
					@EFINErr + ''', ''' +
					@ProdStat + ''')'

		PRINT @iSQL

		-- Push this to the Informix side.
		EXEC (@iSQL) at rh1
	END
END


