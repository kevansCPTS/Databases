
-- =============================================
-- Author:		Steve Trautman
-- Create date: 12/29/2016
-- Description:	Make sure that MyTaxOffice windows service is functioning and responsive by monitoring a heartbeat indicator. MyTaxOffice is supported for two years, current year and prior year.
-- =============================================
CREATE PROCEDURE [dbo].[spMyTaxOfficeHeartbeatAging]
	@IntervalMultiplierFraction as decimal(9, 8) = 1, -- set < 1 to reduce limit when calling from WinSvcRestart service, triggering before the sql job would
	@InErrorCondition int OUTPUT, @EmailBody NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @FailThreshold int = 0,
			@FailThresholdLapseConfig int = 0,
			@HeartbeatConfig datetime2(7),
			@HeartbeatQueue datetime2(7),
			@LapseConfig int = 0,
			@LapseQueue int = 0,
			@CurTime datetime2(7) = SYSUTCDATETIME(),
			@KeyForErrorCondition varchar(100) = 'mytaxoffice.sqljob.heartbeat.errorcondition';
		
	SET @InErrorCondition = 0;
	SET @EmailBody = 'The following MyTaxOffice windows service app thread''s heartbeats are flatlining: ';
	SELECT @FailThreshold = value FROM tblServerAppConfiguration WHERE pk_key = 'mytaxoffice.service.heartbeat.failure.threshold' --IN MINUTES, maximum heartbeat lag before an error email is sent
	SET @FailThresholdLapseConfig = @FailThreshold * (@IntervalMultiplierFraction  + ((1 - @IntervalMultiplierFraction) / 2)) * 60000 -- convert to milliseconds, give this one more headroom, it only runs every 2.5 minutes
	SET @FailThreshold = @FailThreshold * @IntervalMultiplierFraction * 60000 -- convert to milliseconds
	SELECT @HeartbeatConfig = value FROM tblServerAppConfiguration WHERE pk_key = 'mytaxoffice.service.heartbeat.configretriever'
	SELECT @HeartbeatQueue = value FROM tblServerAppConfiguration WHERE pk_key = 'mytaxoffice.service.heartbeat.queueworker'

	SELECT @LapseConfig = DATEDIFF(MILLISECOND, @HeartbeatConfig, @CurTime);
	SELECT @LapseQueue = DATEDIFF(MILLISECOND, @HeartbeatQueue, @CurTime);

	IF @LapseConfig >= @FailThresholdLapseConfig
	BEGIN
		SET @InErrorCondition = 1;
		SET @EmailBody = @EmailBody + CHAR(13) + 'Config Retriever, ' + CONVERT(varchar(10), CONVERT(decimal(18,2), CONVERT(decimal(18,0), @LapseConfig) / 60000)) + ' minutes lapsed since last heartbeat.';
	END

	IF @LapseQueue >= @FailThreshold
	BEGIN
		SET @InErrorCondition = 1;
		SET @EmailBody = @EmailBody + CHAR(13) + 'Queue Worker, ' + CONVERT(varchar(10), CONVERT(decimal(18,2), CONVERT(decimal(18,0), @LapseQueue) / 60000)) + ' minutes lapsed since last heartbeat.';
	END

	SELECT @InErrorCondition AS InErrorCondition, @EmailBody as EmailBody

END

