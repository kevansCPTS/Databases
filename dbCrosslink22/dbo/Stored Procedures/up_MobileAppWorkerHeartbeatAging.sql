
-- =============================================
-- Author:		Steve Trautman
-- Create date: 04/21/2021
-- Description:	Make sure that the MobileAPpWorker windows service is functioning and responsive by monitoring a heartbeat indicator.
-- =============================================
CREATE PROCEDURE [dbo].[up_MobileAppWorkerHeartbeatAging]
	@IntervalMultiplierFraction as decimal(9, 8) = 1, -- set < 1 to reduce limit when calling from WinSvcRestart service, triggering before the sql job would
	@InErrorCondition int OUTPUT, @EmailBody NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @FailThreshold bigint = 0,
			@FailThresholdLapseConfig bigint = 0,
			@HeartbeatConfig datetime2(7),
			@HeartbeatQueue datetime2(7),
			@HeartbeatPoll datetime2(7),
			@LapseConfig bigint = 0,
			@LapseQueue bigint = 0,
			@LapsePoll bigint = 0,
			@CurTime datetime2(7) = SYSUTCDATETIME();
					
	SET @InErrorCondition = 0;
	SET @EmailBody = 'The following MobileAppWorker windows service app thread''s heartbeats are flatlining: ';
	SELECT @FailThreshold = value FROM tblServerAppConfiguration WHERE pk_key = 'mobileappworker.service.heartbeat.failure.threshold' --IN MINUTES, maximum heartbeat lag before an error email is sent
	SET @FailThresholdLapseConfig = @FailThreshold * (@IntervalMultiplierFraction  + ((1 - @IntervalMultiplierFraction) / 2)) * 60000 -- convert to milliseconds, give this one more headroom, it only runs every 2.5 minutes
	SET @FailThreshold = @FailThreshold * @IntervalMultiplierFraction * 60000 -- convert to milliseconds
	--SELECT @HeartbeatConfig = value FROM tblServerAppConfiguration WHERE pk_key = 'textlink.service.heartbeat.configretriever'
	SELECT @HeartbeatQueue = value FROM tblServerAppConfiguration WHERE pk_key = 'mobileappworker.service.heartbeat'
	--SELECT @HeartbeatPoll = value FROM tblServerAppConfiguration WHERE pk_key = 'textlink.service.heartbeat.poller'

	--SELECT @LapseConfig = CONVERT(bigint, DATEDIFF(SECOND, @HeartbeatConfig, @CurTime)) * CONVERT(bigint, 1000);
	SELECT @LapseQueue = CONVERT(bigint, DATEDIFF(SECOND, @HeartbeatQueue, @CurTime)) * CONVERT(bigint, 1000);
	--SELECT @LapsePoll = CONVERT(bigint, DATEDIFF(SECOND, @HeartbeatPoll, @CurTime)) * CONVERT(bigint, 1000);

	/*IF @LapseConfig >= @FailThresholdLapseConfig
	BEGIN
		SET @InErrorCondition = 1;
		SET @EmailBody = @EmailBody + CHAR(13) + 'Config Retriever, ' + CONVERT(varchar(10), CONVERT(decimal(18,2), CONVERT(decimal(18,0), @LapseConfig) / 60000)) + ' minutes lapsed since last heartbeat.';
	END*/

	IF @LapseQueue >= @FailThreshold
	BEGIN
		SET @InErrorCondition = 1;
		SET @EmailBody = @EmailBody + CHAR(13) + 'Queue Worker, ' + CONVERT(varchar(10), CONVERT(decimal(18,2), CONVERT(decimal(18,0), @LapseQueue) / 60000)) + ' minutes lapsed since last heartbeat.';
	END

	/*IF @LapsePoll >= @FailThreshold
	BEGIN
		SET @InErrorCondition = 1;
		SET @EmailBody = @EmailBody + CHAR(13) + 'Database Poller, ' + CONVERT(varchar(10), CONVERT(decimal(18,2), CONVERT(decimal(18,0), @LapsePoll) / 60000)) + ' minutes lapsed since last heartbeat.';
	END*/

	SELECT @InErrorCondition AS InErrorCondition, @EmailBody as EmailBody
END


