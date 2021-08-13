-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertInformixEFINLog]
	@EFIN	char(6),
	@LogCd	char(2),
	@EFINNote char(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@logDate	char(10)
	DECLARE @logTime	char(5)
	DECLARE	@seqNo		integer
	DECLARE @iSQL		varchar(max)

    -- Insert statements for procedure here
	SET @iSQL = 'insert into efn_note (note) values (''' + @EFINNote + ''')'
	EXEC (@iSQL) at rh1;

	-- Retrieve the Sequence Number.
	SET @iSQL = 'select seq_no from openquery(rh1, ''select max(seq_no) seq_no from efn_note'')'

	-- Create temporary table and retrieve max sequence number.
	CREATE TABLE #tempEFINNote (SeqNo integer)
	INSERT INTO #tempEFINNote
	EXEC (@iSQL)
	
	-- Pull sequence number from temporary table.
	SELECT @seqNo = SeqNo FROM #tempEFINNote

	-- Drop temporary table.
	DROP TABLE #tempEFINNote
	
	-- Build Date and time.
	SELECT @LogDate = convert(char(10), getdate(), 101), @LogTime = convert(char(5), getdate(), 114)

	-- Build insert statement.
	SET @iSQL = 'insert into efin_log (efin, log_cd, log_dt, log_tm, log_by, seq_no) values (''' + @EFIN + ''', ''' 
		+ @LogCd + ''', ''' + @LogDate + ''', ''' + @LogTime + ''', ''portal'',' + convert(char(6), @seqNo) + ')'

	EXEC (@iSQL) at rh1;
END


