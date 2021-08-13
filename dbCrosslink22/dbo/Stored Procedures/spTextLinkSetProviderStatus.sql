

-- =============================================
-- Author:		Steve Trautman
-- Create date: 10/17/2011
-- Description:	Update the provider status for a TextLink message
-- =============================================
CREATE PROCEDURE [dbo].[spTextLinkSetProviderStatus]
	@provider_message_id uniqueidentifier,
	@provider_status varchar(20),
	@provider_status_seq int = 0,
	@provider_received_dttm datetime2(7) = NULL,
	@provider_queued_dttm datetime2(7) = NULL,
	@provider_sent_dttm datetime2(7) = NULL,
	@provider_delivery_dttm datetime2(7) = NULL,
	@provider_units int = NULL,
	@provider_total_rate decimal(18,9) = NULL,
	@provider_total_amount decimal(18,9) = NULL,
	@provider_to char(11) = NULL,
	@provider_error int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	/*
	This proc is called from a web service callback that the provider calls.
	There are typically 2 or more callbacks with status updates for the same text in quick succession.
	Because the internet, sometimes our web service receives them out of order.
	Plivo addresses this with the provider_status_seq param, so we only apply the status
	if the seq number is greater than the existing status.
	*/

	DECLARE	@return_result int = 0,
			/*
			-1 = Unknow provider message id. This is expected. Sometimes we get callbacks from Plivo
					before our sender can update the db with the message id.
					The web service will retry several times in hopes the id will get updated 
					before the next retry.
			0 = success, but no change in status
			1 = success, new status updated
			*/
			@pk_textlink_id uniqueidentifier = NULL,
			@old_fk_textlink_provider_status_id int = NULL,
			@new_fk_textlink_provider_status_id int = NULL,
			@old_provider_status_seq int = NULL,
			@old_provider_received_dttm datetime2(7) = NULL,
			@old_provider_queued_dttm datetime2(7) = NULL,
			@old_provider_sent_dttm datetime2(7) = NULL,
			@old_provider_delivery_dttm datetime2(7) = NULL,
			@old_provider_units int = NULL,
			@old_provider_total_rate decimal(18,9) = NULL,
			@old_provider_total_amount decimal(18,9) = NULL,
			@old_provider_error int = NULL,
			@do_update bit = 0,
			@email_from_address AS NVARCHAR(MAX),
			@email_recipients AS NVARCHAR(MAX),
			@email_subject AS NVARCHAR(MAX),
			@email_body AS NVARCHAR(MAX),
			@email_importance AS NVARCHAR(MAX)

	SELECT	@pk_textlink_id = pk_textlink_id,
			@old_fk_textlink_provider_status_id = fk_textlink_provider_status_id,
			@old_provider_status_seq = provider_status_seq,
			@old_provider_received_dttm = provider_received_dttm,
			@old_provider_queued_dttm = provider_queued_dttm,
			@old_provider_sent_dttm = provider_sent_dttm,
			@old_provider_delivery_dttm = provider_delivery_dttm,
			@old_provider_units = provider_units,
			@old_provider_total_rate = provider_total_rate,
			@old_provider_total_amount = provider_total_amount,
			@old_provider_error = fk_textlink_error_id
	FROM tblTextLink WITH(ROWLOCK)
	WHERE provider_id = @provider_message_id

	IF @pk_textlink_id IS NULL
	BEGIN
		--RAISERROR ('Unknown provider message id.', 12, 1);
		SET @return_result = -1;
		SELECT @return_result AS RESULT;
	END
	ELSE -- we found this provider_message_id, possibly update data
	BEGIN

		SET @new_fk_textlink_provider_status_id = (SELECT pk_textlink_provider_status_id
												  FROM reftblTextlinkProviderStatus WITH (NOLOCK)
												  WHERE status = @provider_status)
		IF @provider_error IS NOT NULL AND @provider_error > 0
		BEGIN
			IF NOT EXISTS(SELECT pk_textlink_error_id FROM reftblTextlinkError WITH (NOLOCK) WHERE pk_textlink_error_id = @provider_error)
			BEGIN
				--Provider error code not found in the database. Add it to the database and send notification email.
				INSERT INTO reftblTextlinkError (pk_textlink_error_id, reason, error_desc)
				VALUES (@provider_error, 'Unknown New Error Code', 'Support has been notified of this new error code. If you recieve this error frequently, contact support.')

				BEGIN TRY

					SET @email_subject = @@SERVERNAME + '.' + DB_NAME() + ': TextLink Unknown New Error Code';
					SET @email_body = @@SERVERNAME + '.' + DB_NAME() + CHAR(13) + CHAR(13) +
						'TextLink received an unknown new error code from the provider!' + CHAR(13) + CHAR(13) +
						'Error Code ' + CONVERT(NVARCHAR(50), @provider_error) + ' reason and error_desc need to be updated in reftblTextlinkError!' + CHAR(13) + CHAR(13) +
						'Provider Error Code = ' + CONVERT(NVARCHAR(50), @provider_error) + CHAR(13) + CHAR(13) +
						'Provider Status = ' + COALESCE(@provider_status, '') + CHAR(13) + CHAR(13) +
						'Cell number = ' + @provider_to + CHAR(13) + CHAR(13) +
						'pk_textlink_id = ' + CONVERT(NVARCHAR(50), @pk_textlink_id) + CHAR(13) + CHAR(13) +
						'provider_message_id = ' + CONVERT(NVARCHAR(50), @provider_message_id)
					
					SELECT @email_from_address = value
					FROM tblServerAppConfiguration
					WHERE pk_key = 'textlink.service.email.from'
					
					SELECT @email_recipients = value
					FROM tblServerAppConfiguration
					WHERE pk_key = 'textlink.service.email.to'
						
					IF LEFT(@@SERVERNAME, 4) = 'PROD'
					BEGIN
						SET @email_importance = 'High';
					END
					ELSE
					BEGIN
						SET @email_importance = 'Normal';
					END
					
					EXEC msdb.dbo.sp_send_dbmail
						@profile_name = 'Email',
						@from_address = @email_from_address,
						@recipients = @email_recipients,
						@subject = @email_subject,
						@body = @email_body,
						@importance = @email_importance;
				END TRY
				BEGIN CATCH
					--Ignore any errors trying to send the email
				END CATCH

			END
		END

		IF @new_fk_textlink_provider_status_id IS NULL --didn't find the status string in our reftbl
		BEGIN
			BEGIN TRY

				SET @email_subject = @@SERVERNAME + '.' + DB_NAME() + ': TextLink Unknown Provider Status';
				SET @email_body = @@SERVERNAME + '.' + DB_NAME() + CHAR(13) + CHAR(13) +
					'TextLink received an unknown status from the provider!' + CHAR(13) + CHAR(13) +
					'Provider Status = "' + COALESCE(@provider_status, '') + '"' + CHAR(13) + CHAR(13) +
					'Cell number ' + @provider_to + CHAR(13) + CHAR(13) +
					'pk_textlink_id ' + CONVERT(NVARCHAR(50), @pk_textlink_id) + CHAR(13) + CHAR(13) +
					'provider_message_id ' + CONVERT(NVARCHAR(50), @provider_message_id) + CHAR(13) + CHAR(13) +
					'Does the status "' + @provider_status + '" need to be added to reftblTextlinkProviderStatus?'
					
				SELECT @email_from_address = value
				FROM tblServerAppConfiguration
				WHERE pk_key = 'textlink.service.email.from'
					
				SELECT @email_recipients = value
				FROM tblServerAppConfiguration
				WHERE pk_key = 'textlink.service.email.to'
						
				IF LEFT(@@SERVERNAME, 4) = 'PROD'
				BEGIN
					SET @email_importance = 'High';
				END
				ELSE
				BEGIN
					SET @email_importance = 'Normal';
				END
					
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'Email',
					@from_address = @email_from_address,
					@recipients = @email_recipients,
					@subject = @email_subject,
					@body = @email_body,
					@importance = @email_importance;
			END TRY
			BEGIN CATCH
				--Ignore any errors trying to send the email
			END CATCH
		END


		--only allow updates when the new sequence is greater than or equal to the existing sequence.
		IF @provider_status_seq = @old_provider_status_seq -- sequence is the same. check for any changed data.
		BEGIN
			IF  ((@old_fk_textlink_provider_status_id IS NULL AND @new_fk_textlink_provider_status_id IS NOT NULL) OR @old_fk_textlink_provider_status_id != @new_fk_textlink_provider_status_id) OR
				((@old_provider_status_seq IS NULL AND @provider_status_seq IS NOT NULL) OR @old_provider_status_seq != @provider_status_seq) OR
				((@old_provider_received_dttm IS NULL AND @provider_received_dttm IS NOT NULL) OR @old_provider_received_dttm != @provider_received_dttm) OR
				((@old_provider_queued_dttm IS NULL AND @provider_queued_dttm IS NOT NULL) OR @old_provider_queued_dttm != @provider_queued_dttm) OR
				((@old_provider_sent_dttm IS NULL AND @provider_sent_dttm IS NOT NULL) OR @old_provider_sent_dttm != @provider_sent_dttm) OR
				((@old_provider_delivery_dttm IS NULL AND @provider_delivery_dttm IS NOT NULL) OR @old_provider_delivery_dttm != @provider_delivery_dttm) OR
				((@old_provider_units IS NULL AND @provider_units IS NOT NULL) OR @old_provider_units != @provider_units) OR
				((@old_provider_total_rate IS NULL AND @provider_total_rate IS NOT NULL) OR @old_provider_total_rate != @provider_total_rate) OR
				((@old_provider_total_amount IS NULL AND @provider_total_amount IS NOT NULL) OR @old_provider_total_amount != @provider_total_amount) OR
				((@old_provider_error IS NULL AND @provider_error IS NOT NULL) OR @old_provider_error != @provider_error)
			BEGIN
				SET @do_update = 1;
				--If the actual status is different, or the error is different, (basically the only things the clients (desktop, CLO, MSO) make visible to the users)
				--Then indicate that the status is updated for the caller
				--Otherwise, it's just internal housekeeping to the DB to make sure we have all the latest data.
				IF  ((@old_fk_textlink_provider_status_id IS NULL AND @new_fk_textlink_provider_status_id IS NOT NULL) OR @old_fk_textlink_provider_status_id != @new_fk_textlink_provider_status_id) OR
					((@old_provider_error IS NULL AND @provider_error IS NOT NULL) OR @old_provider_error != @provider_error)
				BEGIN
					SET @return_result = 1;
				END
			END
			
		END
		ELSE IF @old_provider_status_seq IS NULL OR @provider_status_seq > @old_provider_status_seq -- sequence is greater. Update the data.
		BEGIN
			SET @do_update = 1;
			SET @return_result = 1; -- Definitely has a new status
		END

		IF @do_update = 1
		BEGIN
			UPDATE tblTextLink WITH (ROWLOCK)
			SET fk_textlink_provider_status_id = COALESCE(@new_fk_textlink_provider_status_id, fk_textlink_provider_status_id),
				provider_status_seq = COALESCE(@provider_status_seq, provider_status_seq),
				provider_received_dttm = COALESCE(@provider_received_dttm, provider_received_dttm),
				provider_queued_dttm = COALESCE(@provider_queued_dttm, provider_queued_dttm),
				provider_sent_dttm = COALESCE(@provider_sent_dttm, provider_sent_dttm),
				provider_delivery_dttm = COALESCE(@provider_delivery_dttm, provider_delivery_dttm),
				provider_units = COALESCE(@provider_units, provider_units),
				provider_total_rate = COALESCE(@provider_total_rate, provider_total_rate),
				provider_total_amount = COALESCE(@provider_total_amount, provider_total_amount),
				fk_textlink_error_id = COALESCE(@provider_error, fk_textlink_error_id)
			WHERE pk_textlink_id = @pk_textlink_id
		END
		
		SELECT @return_result AS RESULT;
	END		
END


