

-- =============================================
-- Author:		Steve Trautman
-- Create date: 12/20/2016
-- Description:	Check to see if Texlink outbound texts have aged beyond acceptable limits
-- =============================================
CREATE PROCEDURE [dbo].[spTextLinkOutboundAging]
	@IntervalMultiplierFraction as decimal(9, 8) = 1, -- set < 1 to reduce limit when calling from WinSvcRestart service, triggering before the sql job would
	@OldCount int OUTPUT, @Interval int OUTPUT, @IntervalMultiplier int OUTPUT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@CurTime datetime2(7) = SYSUTCDATETIME(),
			@OldLastSent uniqueidentifier,
			@LastSent uniqueidentifier,
			@LastSentDate datetime2(7),
			@KeyForLastSent varchar(100) = 'textlink.sqljob.outbound.aging.lastsent';
			
	/*
		If there are texts to send (beyond the acceptable interval), and the last sent text didn't change, then error,
			so send email and set error condition exists flag.
		Else --everything is ok
			Update last sent text id.
			if error condition exists flag is set, send resolved email and clear the flag
	*/
	/*
		Check for texts that maybe should have been sent by now.
		But because Twilio throttles us to 1 message per second,
		we may just have lots of texts to send.
		If there are no texts waiting to be sent, all is well.
		If there are texts waiting to be sent,
		check to see if the current last sent text id
		is the same as the last text sent id on the prior job run.
		If the id is the same, texts are NOT being sent, and we have a problem.
		If the id is different, all is well, texts are still being sent.

		It is important to remember here that we have legacy texts being inserted in the db
		as the start of their process. But we also have beanstalk queue texts being inserted
		as they go -- their process starts in the queue. Legacy piles up in the db, queue piles up in the queue.
		So it possible for bulk legacy texts to languish in the db while texts from the queue keep
		showing up. The count of unsent here doesn't include the unsent in the queue. The
		unsent count here can remain unchanged and even grow (bulk are lower priority),
		while texts are still being processed from the queue. So you can't just go by unsent counts,
		thus this process just focuses on making sure texts are being sent/processed.
	*/
	SET DEADLOCK_PRIORITY LOW; --If deadlock occurs, this update can most definitely wait until the next time this sproc is run
	SET @OldCount = 0;
	SELECT @Interval = value FROM tblServerAppConfiguration WITH(NOLOCK) WHERE pk_key = 'textlink.service.outbound.interval.dbpoller'
	SELECT @IntervalMultiplier = value FROM tblServerAppConfiguration WITH(NOLOCK) WHERE pk_key = 'textlink.service.outbound.interval.multiplier'
	SELECT @OldLastSent = value FROM tblServerAppConfiguration WITH(NOLOCK) WHERE pk_key = @KeyForLastSent

	--Getting garbage texts from MSO where userid=0. Cleaning these up until they fix their bug.
	/*UPDATE t
	SET t.sent = 1, t.provider_status = 'userid 0 not exist'
	FROM tblTextLink t
	JOIN tblTextLinkMap m ON t.fk_textlink_map_id = m.pk_textlink_map_id
	WHERE t.outbound = 1 AND t.sent = 0 AND m.user_id = 0
	*/

	SELECT TOP 1 @LastSent = pk_textlink_id, @LastSentDate = sent_date
	FROM tblTextLink
	WHERE outbound = 1
	AND sent = 1
	ORDER BY sent_date DESC, inserted_date DESC, message_date DESC, pk_textlink_id

	IF @LastSent = @OldLastSent
	BEGIN

		SELECT @OldCount = COUNT(*)
		FROM tblTextLink
		WHERE outbound = 1
		AND sent = 0
		AND inserted_date < @CurTime
		AND DATEDIFF(millisecond, inserted_date, @CurTime) > (@IntervalMultiplierFraction * @IntervalMultiplier * @Interval * 1000);
	
	END
	ELSE
	BEGIN
		IF @LastSent IS NOT NULL --if tblTextlink table is not empty
		BEGIN
			UPDATE tblServerAppConfiguration
			SET value = @LastSent
			WHERE pk_key = @KeyForLastSent
		END
	END
	
	SELECT @OldCount AS OldCount, @Interval AS Interval, @IntervalMultiplier AS IntervalMultiplier; -- return zero for OldCount for acceptable aging conditions

	SET DEADLOCK_PRIORITY NORMAL;
END


