
-- =============================================
-- Author:		Steve Trautman
-- Create date: 9/6/2011
-- 01/30/2014 Insert a new outbound TextLink message
-- 01/28/2015 Suppress email sending for running out of numbers
-- 02/02/2015 Custom unsubscribe email interval on a per-userid basis
--            Suppress error when there are no more provider numbers to use
-- 09/24/2015 Bulk text indicator
-- 08/20/2019 Major overhaul for Short Code support. Unify all InsertOutbound procs into just this one.
--            (Used to have separate procs for xlive, print, and process)
-- =============================================

CREATE PROCEDURE [dbo].[spTextLinkInsertOutbound]
	@message_guid uniqueidentifier,
	@message_body varchar(160),
	@message_date datetimeoffset,
	@client_cell varchar(10),
	@client_name varchar(200),
	@return_guid char(32),
	@source_id char(1), -- see reftblTextlinkSource. Desktop = 'D', MSO = 'M', Crosslink Online = 'W'
	@source_user_id varchar(25),  --whatever the source want to use. D is user_id, M & W were supposed to be EFIN, but ALL SOURCES ARE USING user_id. CLO and MSO never made the change to use EFINs
	@login_id varchar(8),
	@carrier_name varchar(50),
	@business_return bit = 0,
	@bulk_text bit = 0,
	@process_id int,
	@print_guid char(32) = NULL,
	@xlive bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@ok_to_process int = 1, --  < 0 are errors, 0 is already inserted, 1 is ok to process
				/*
				-1 --error, invalid client cell number
				-2 --error, invalid process_id
				-3 --error, invalid source_id
				-4 --error, invalid source_user_id
				-5 --error, we don't have any more provider numbers to use!
				-6 --error, number has opted-out
				-7 --error, opted-in to a different office
				-8 --error, old year standard texts have been shut off
				*/
			@map_id int = 0,
			@provider_cell varchar(10),
			@fk_provider_cell int = NULL,
			@carrier_id int = NULL,
			@old_map_carrier_id int = NULL,
			@old_source_user_id int = NULL,
			@old_client_name varchar(200) = NULL,
			@old_return_guid char(32) = NULL,
			@old_business_return bit = 0,
			@old_print_guid char(32) = NULL,
			@old_fk_process_id int = NULL,
			@old_fk_source_id char(1) = NULL,
			@err varchar(200) = NULL,
			@err_details varchar(200) = NULL,
			@err_reply_text varchar(200) = NULL,
			@err_reply_notification varchar(500) = NULL,
			@err_reply_text_id uniqueidentifier = NULL,
			@err_reply_text_date datetimeoffset(3) = NULL,
			@map_id_found int = 0,
			@print_guid_as_unique_identifier uniqueidentifier = NULL,
			@sent bit = 0,
			@fk_provider_status_id int = NULL,
			@opt_in_dttm datetimeoffset(3) = NULL,
			@opt_out_dttm datetimeoffset(3) = NULL,
			@last_stop_msg_dttm datetimeoffset(3) = NULL,
			@opt_in_source_office_id varchar(26) = NULL,
			@opt_in_source_id char(1),
			@opt_in_source_user_id varchar(25) = NULL,
			@opt_in_season int = NULL,
			@opt_in_xlive bit = 0,
			@textlink_opt_in_out_cell_row_exists bit = 0,
			@send_opt_in_msg bit = 0,
			@text_already_exists bit = 0,
			@opt_in_msg_id uniqueidentifier = NULL,
			@opt_in_msg_date datetimeoffset(3) = NULL,
			@opt_in_msg varchar(160) = NULL,
			@user_id_for_get_company_name varchar(25),
			@efin_for_get_company_name varchar(25),
			@send_shutoff_msg bit = 0;

	--validate client cell number format
	IF @client_cell IS NULL OR LEN(@client_cell) <> 10 OR PATINDEX('%[^0-9]%', @client_cell) > 0
	BEGIN
		SET @err = 'Invalid client cell number ''' + 
			CASE WHEN @client_cell IS NULL THEN 'NULL' ELSE @client_cell END +
			'''. It must contain only digits and be exactly 10 digits long. ' + 
			@@SERVERNAME + '.' + DB_NAME();
		SET @ok_to_process = -1 --error, invalid client cell number
		
		SET @err_details = 'Invalid client cell number ''' + 
			CASE WHEN @client_cell IS NULL THEN 'NULL' ELSE @client_cell END +
			'''. It must contain only digits and be exactly 10 digits long.'

		SELECT @err_reply_text = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err'

		SET @err_reply_text = REPLACE(@err_reply_text, '{error}', @err_details);

		SELECT @err_reply_notification = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err.notification'

		SET @err_reply_notification = REPLACE(@err_reply_notification, '{error}', @err_details);
		SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);

		GOTO err_exit
	END

	IF @process_id IS NULL OR NOT EXISTS (SELECT pk_textlink_process_id FROM tblTextLinkProcess WITH (NOLOCK) WHERE pk_textlink_process_id = @process_id)
	BEGIN
		SET @err = 'Invalid process_id of ''' + 
			CASE WHEN @process_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @process_id) END +
			'''. The value must exist as a tblTextlinkProcess.pk_textlink_process_id. ' + 
			@@SERVERNAME + '.' + DB_NAME();
		SET @ok_to_process = -2 --error, invalid process_id

		SET @err_details = 'Invalid process_id of ''' + 
			CASE WHEN @process_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @process_id) END + '''.'

		SELECT @err_reply_text = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err'

		SET @err_reply_text = REPLACE(@err_reply_text, '{error}', @err_details);

		SELECT @err_reply_notification = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err.notification'

		SET @err_reply_notification = REPLACE(@err_reply_notification, '{error}', @err_details);
		SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);

		GOTO err_exit
	END

	IF @source_id IS NULL OR NOT EXISTS (SELECT pk_textlink_source_id FROM reftblTextlinkSource WITH (NOLOCK) WHERE pk_textlink_source_id = @source_id)
	BEGIN
		SET @err = 'Invalid source_id of ''' + 
			CASE WHEN @source_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @source_id) END +
			'''. The value must exist as a reftblTextlinkSource.pk_textlink_source_id. ' + 
			@@SERVERNAME + '.' + DB_NAME();
		SET @ok_to_process = -3 --error, invalid source_id

		SET @err_details = 'Invalid source_id of ''' + 
			CASE WHEN @source_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @source_id) END + '''.'

		SELECT @err_reply_text = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err'

		SET @err_reply_text = REPLACE(@err_reply_text, '{error}', @err_details);

		SELECT @err_reply_notification = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err.notification'

		SET @err_reply_notification = REPLACE(@err_reply_notification, '{error}', @err_details);
		SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);

		GOTO err_exit
	END

	IF @source_user_id IS NULL OR CONVERT(int, @source_user_id) = 0
	BEGIN
		SET @err = 'Invalid source_user_id of ''' + 
			CASE WHEN @source_user_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @source_user_id) END +
			'''. The value must not be NULL, empty, or equal to zero. ' + 
			@@SERVERNAME + '.' + DB_NAME();
		SET @ok_to_process = -4 --error, invalid source_user_id

		SET @err_details = 'Invalid source_user_id of ''' + 
			CASE WHEN @source_user_id IS NULL THEN 'NULL' ELSE CONVERT(NVARCHAR(20), @source_user_id) END +
			'''. The value must not be NULL, empty, or equal to zero.'

		SELECT @err_reply_text = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err'

		SET @err_reply_text = REPLACE(@err_reply_text, '{error}', @err_details);

		SELECT @err_reply_notification = value
		FROM tblServerAppConfiguration WITH (NOLOCK)
		WHERE pk_key = 'textlink.service.response.sproc.err.notification'

		SET @err_reply_notification = REPLACE(@err_reply_notification, '{error}', @err_details);
		SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);

		GOTO err_exit
	END
	
	SELECT @text_already_exists = CASE WHEN pk_textlink_id IS NOT NULL THEN 1 ELSE 0 END,
		   @sent = sent
	FROM tblTextLink WITH (ROWLOCK)
	WHERE pk_textlink_id = @message_guid

	IF @text_already_exists = 1
	BEGIN
		SET @ok_to_process = 0
		GOTO err_exit
	END

	--The majority of the time, a dirty read is ok, and so there is little reason for so many locking reads
	--The worst that will happen with a dirty read is our insert will fail and that be handled just fine.
	DECLARE @try_count int = 0
	WHILE NOT EXISTS (SELECT user_id FROM tblTextLinkUser tu WITH(NOLOCK) WHERE tu.user_id = @source_user_id)
	BEGIN
		BEGIN TRY
			INSERT INTO tblTextLinkUser (user_id) VALUES (@source_user_id)
		END TRY
		BEGIN CATCH
			--If another thread/process inserted this user_id, we don't care that our insert failed.
			--As long as the row exists, mission accomplished, move on.
			--But don't infinite loop. Try the insert twice, then throw -- because then something truly unexpected is going on.
			IF @try_count > 0
			BEGIN;
				THROW
			END
			SET @try_count = @try_count + 1
		END CATCH
	END

	IF @print_guid IS NOT NULL
	BEGIN
		SET @print_guid_as_unique_identifier = CAST(
			SUBSTRING(@print_guid, 1, 8) + '-' + SUBSTRING(@print_guid, 9, 4) + '-' + SUBSTRING(@print_guid, 13, 4) + '-' +
			SUBSTRING(@print_guid, 17, 4) + '-' + SUBSTRING(@print_guid, 21, 12)
			AS UNIQUEIDENTIFIER);
	END

	--do we already have a tblTextLinkMap entry for this cell
	SELECT	@map_id = m.pk_textlink_map_id,
			@provider_cell = LTRIM(RTRIM(m.fk_textlink_provider_cell)),
			@old_map_carrier_id = m.fk_textlink_carrier_id,
			@old_source_user_id = m.source_user_id,
			@old_client_name = m.client_name,
			@old_return_guid = m.return_guid,
			@old_print_guid = m.print_guid,
			@old_fk_process_id = m.fk_textlink_process_id,
			@old_fk_source_id = m.fk_textlink_source_id,
			@old_source_user_id = m.source_user_id,
			@old_business_return = m.business_return
	FROM tblTextLinkMap m WITH (ROWLOCK)
	WHERE m.client_cell = @client_cell
	--AND m.return_guid = @return_guid
	--AND m.user_id = @source_user_id;
    
	IF @map_id = 0 --no entry, create one
	BEGIN
		SELECT TOP 1 @provider_cell = LTRIM(RTRIM(pc.pk_textlink_provider_cell))
		FROM tblTextLinkProviderCell pc WITH (NOLOCK)
		WHERE pc.use_type = 'default'
		--AND pc.blacklisted = 0
		--ORDER BY pc.last_used ASC;

		--This shouldn't ever happen now that we are exclusively and always using our short code
		--But just to cover all possibilities, and as a placeholder in case we assign some numbers
		--to use long codes in the future...
		IF @@ROWCOUNT = 0
		BEGIN
			SET @err = 'No more provider numbers to use.' + @@SERVERNAME + '.' + DB_NAME();
			SET @ok_to_process = -5 --error, we don't have any more provider numbers to use!

			SET @err_details = 'No more provider numbers to use.'

			SELECT @err_reply_text = value
			FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.sproc.err'

			SET @err_reply_text = REPLACE(@err_reply_text, '{error}', @err_details);

			SELECT @err_reply_notification = value
			FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.sproc.err.notification'

			SET @err_reply_notification = REPLACE(@err_reply_notification, '{error}', @err_details);
			SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);

			GOTO err_exit
			
		END
		
		UPDATE tblTextLinkProviderCell WITH (ROWLOCK)
		SET last_used = SYSUTCDATETIME()
		WHERE pk_textlink_provider_cell = @provider_cell;
		
		SELECT @carrier_id = c.pk_textlink_carrier_id
		FROM tblTextLinkCarrier c WITH (NOLOCK)
		WHERE c.carrier_name = @carrier_name
		
		INSERT INTO tblTextLinkMap (client_cell, return_guid,
			fk_textlink_carrier_id, fk_textlink_provider_cell,
			client_name, business_return, print_guid,
			fk_textlink_process_id, fk_textlink_source_id, source_user_id)
		VALUES (@client_cell, @return_guid,
			@carrier_id, @provider_cell,
			@client_name, @business_return, @print_guid,
			@process_id, @source_id, @source_user_id)
		
		SET @map_id = SCOPE_IDENTITY();
		
		--Check to see if we just used the last available provider number 
		--for this cell number. If so, send an email to the TextLink admin
		--so he can add another Twilio number before we run out.
		--SELECT TOP 1 pc.pk_textlink_provider_cell
		--FROM tblTextLinkProviderCell pc
		--WHERE pc.pk_textlink_provider_cell NOT IN (
		--		SELECT m.fk_textlink_provider_cell
		--		FROM tblTextLinkMap m
		--		WHERE m.client_cell = @client_cell )
		--	  AND pc.use_type = 'default'
		--	  AND pc.blacklisted = 0;
		
		--IF @@ROWCOUNT = 0
		--BEGIN
		--	BEGIN TRY
		--		DECLARE @email_from_address AS NVARCHAR(MAX),
		--				@email_recipients AS NVARCHAR(MAX),
		--				@email_subject AS NVARCHAR(MAX),
		--				@email_body AS NVARCHAR(MAX),
		--				@email_importance AS NVARCHAR(MAX),
		--				@send_email_if_test_user AS NVARCHAR(5),
		--				@test_user AS BIT = 0,
		--				@send_email AS BIT = 0; -- default: never send email for this issue
			
		--		SELECT @test_user = test_user
		--		FROM tblUser
		--		WHERE user_id = @source_user_id
				
		--		SELECT @send_email_if_test_user = value
		--		FROM tblServerAppConfiguration
		--		WHERE pk_key = 'textlink.service.email.sendIfTestUser'
				
		--		--Don't send if it's a test, so need to check if it's a test user
		--		IF @send_email_if_test_user = 'false' AND @test_user = 1 
		--		BEGIN
		--			SET @send_email = 0
		--		END
				
		--		IF @send_email = 1
		--		BEGIN
		--			SET @email_subject = @@SERVERNAME + '.' + DB_NAME() + ': TextLink May Need Another Provider Number!';
		--			SET @email_body = @@SERVERNAME + '.' + DB_NAME() + ': TextLink may need another provider number! Cell number ' + @client_cell + 
		--				', user_id ' + CONVERT(NVARCHAR(20),@source_user_id) +
		--				' (which is a ' + CASE WHEN @test_user = 1 THEN 'TEST' ELSE 'PRODUCTION' END + ' user_id)' +
		--				' has now used all available provider numbers. ' +
		--				'Do not add a new provider number if the user_id is an internal test account!';
					
		--			SELECT @email_from_address = value
		--			FROM tblServerAppConfiguration
		--			WHERE pk_key = 'textlink.service.email.from'
					
		--			SELECT @email_recipients = value
		--			FROM tblServerAppConfiguration
		--			WHERE pk_key = 'textlink.service.email.to'
						
		--			IF LEFT(@@SERVERNAME, 4) = 'PROD'
		--			BEGIN
		--				SET @email_importance = 'High';
		--			END
		--			ELSE
		--			BEGIN
		--				SET @email_importance = 'Normal';
		--			END
					
		--			EXEC msdb.dbo.sp_send_dbmail
		--				@profile_name = 'Email',
		--				@from_address = @email_from_address,
		--				@recipients = @email_recipients,
		--				@subject = @email_subject,
		--				@body = @email_body,
		--				@importance = @email_importance;
		--		END
		--	END TRY
		--	BEGIN CATCH
		--		--Ignore any errors trying to send the email
		--	END CATCH
		--END
	END
	ELSE -- have entry, update it if necessary
	BEGIN
		SET @map_id_found = 1;
	END
	EXECUTE @fk_provider_cell = dbCrosslinkGlobal.dbo.up_GetPkTextlinkProviderCell @provider_cell
	
	--Is this now an old year for which standard texts have been shut off?
	IF @process_id = 2 	--This only applies to standard (conversational/bulk) texts
	BEGIN
		DECLARE @shutoff varchar(10) =
			(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.outbound.shutoff.standard');
		DECLARE @shutoff_override varchar(10) = 
			(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.outbound.shutoff.standard.override.userid=' + CONVERT(NVARCHAR(1),@source_id) + CONVERT(NVARCHAR(20),@source_user_id));
		IF @shutoff_override IS NOT NULL
		BEGIN
			SET @shutoff = @shutoff_override;
		END
		IF LOWER(@shutoff) = 'true'
		BEGIN
			SET @sent = 1; --Don't send
			SET @fk_provider_status_id = 9 -- = 'old year shutoff'

			--Only send a reply text/notification once per every specified interval (in days)

			--get the interval
			DECLARE @shutoff_reply_interval int = (SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
				WHERE pk_key = 'textlink.service.response.sproc.err.shutoff.standard.err.reply.interval')
			DECLARE @last_shutoff_msg_dttm datetimeoffset(3) = (SELECT tu.last_shutoff_msg_dttm FROM tblTextLinkUser tu WITH(NOLOCK) WHERE tu.user_id = @source_user_id)
		
		
			IF @last_shutoff_msg_dttm IS NULL OR DATEDIFF(day, @last_shutoff_msg_dttm, @message_date) >= @shutoff_reply_interval
			BEGIN
				SET @send_shutoff_msg = 1
				-- BEGIN repeated code block (see below)
				-- BEGIN repeated code block (see below)
				SELECT @err = value
				FROM tblServerAppConfiguration WITH (NOLOCK)
				WHERE pk_key = 'textlink.service.response.sproc.err.shutoff.standard'
				-- END repeated code block
				-- END repeated code block

				-- BEGIN repeated code block (see below)
				-- BEGIN repeated code block (see below)
				SELECT @err_reply_text = value
				FROM tblServerAppConfiguration WITH (NOLOCK)
				WHERE pk_key = 'textlink.service.response.sproc.err.shutoff.standard.err.reply'

				SELECT @err_reply_notification = value
				FROM tblServerAppConfiguration WITH (NOLOCK)
				WHERE pk_key = 'textlink.service.response.sproc.err.shutoff.standard.err.reply.notification'
		
				-- END repeated code block
				-- END repeated code block

				UPDATE tblTextLinkUser WITH (ROWLOCK)
				SET last_shutoff_msg_dttm = @message_date
				WHERE user_id = @source_user_id
			END

			SET @ok_to_process = -8 --error, old year standard texts have been shut off
		END
	END

	IF @sent = 0
	BEGIN
		--Is this client cell number opted out because they requested us to stop sending messages?
		SELECT @textlink_opt_in_out_cell_row_exists = CASE WHEN pk_textlink_opt_in_out_cell IS NULL THEN 0 ELSE 1 END,
				@opt_in_dttm = opt_in_dttm,
				@opt_out_dttm = opt_out_dttm,
				@last_stop_msg_dttm = last_stop_msg_dttm,
				@opt_in_source_office_id = source_office_id,
				@opt_in_source_id = SUBSTRING(source_office_id, 1, 1),
				@opt_in_source_user_id = SUBSTRING(source_office_id, 2, 25),
				@opt_in_season = season,
				@opt_in_xlive = xlive
			FROM dbCrosslinkGlobal.dbo.tblTextLinkOptInOut WITH (ROWLOCK)
			WHERE pk_textlink_opt_in_out_cell = @client_cell
			AND fk_provider_cell = @fk_provider_cell
	
		IF @opt_out_dttm IS NOT NULL
		BEGIN
			SET @sent = 1; --Don't send
			SET @fk_provider_status_id = 7 -- = 'opted out');

			-- BEGIN repeated code block (see below)
			-- BEGIN repeated code block (see below)
			SELECT @err = value
			FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin'

			SET @err = REPLACE(@err, '{source_id}', @source_id);
			SET @err = REPLACE(@err, '{source_user_id}', @source_user_id);
			SET @err = REPLACE(@err, '{provider_cell}', @provider_cell);
			-- END repeated code block
			-- END repeated code block

			-- BEGIN repeated code block (see below)
			-- BEGIN repeated code block (see below)
			SELECT @err_reply_text = value
			FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin.err.reply'

			SET @err_reply_text = REPLACE(@err_reply_text, '{source_id}', @source_id);
			SET @err_reply_text = REPLACE(@err_reply_text, '{source_user_id}', @source_user_id);
			SET @err_reply_text = REPLACE(@err_reply_text, '{provider_cell}', @provider_cell);
		
			SELECT @err_reply_notification = value
			FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin.err.reply.notification'
		
			SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);
			SET @err_reply_notification = REPLACE(@err_reply_notification, '{source_id}', @source_id);
			SET @err_reply_notification = REPLACE(@err_reply_notification, '{source_user_id}', @source_user_id);
			SET @err_reply_notification = REPLACE(@err_reply_notification, '{provider_cell}', @provider_cell);
			-- END repeated code block
			-- END repeated code block

			SET @ok_to_process = -6 --error, number has opted-out
		END
		ELSE -- opted out is null
		BEGIN
			IF @textlink_opt_in_out_cell_row_exists = 1 --we found a tblTextlinkOptInOut record for this cell
			BEGIN
				--Does the source_id and source_user_id match?
				IF @opt_in_source_office_id IS NULL OR (@opt_in_source_id = @source_id AND @opt_in_source_user_id = @source_user_id)
				BEGIN
					IF @opt_in_dttm IS NULL --opt the user in by default (this only happens once per cell number)
											--this probably shouldn't ever happen, but just in case...
					BEGIN
						SET @send_opt_in_msg = 1;
						UPDATE dbCrosslinkGlobal.dbo.tblTextLinkOptInOut WITH (ROWLOCK)
						SET opt_in_dttm = @message_date,
							season = dbo.getXlinkSeason(),
							xlive = @xlive
						WHERE pk_textlink_opt_in_out_cell = @client_cell
						AND fk_provider_cell = @fk_provider_cell
					END
					ELSE IF @opt_in_season <> dbo.getXlinkSeason() OR @opt_in_xlive <> @xlive -- already opted-in, just update the season or xlive if needed
					BEGIN
						UPDATE dbCrosslinkGlobal.dbo.tblTextLinkOptInOut WITH (ROWLOCK)
						SET season = dbo.getXlinkSeason(),
							xlive = @xlive
						WHERE pk_textlink_opt_in_out_cell = @client_cell
						AND fk_provider_cell = @fk_provider_cell
					END
				END
				ELSE IF @process_id NOT IN (1, 3) --source_id and source_user_id do NOT match, and this is not a pwd reset or remote signature
					-- in other words, if it IS a pwd reset or remote signature, do NOT require the office ID to match -- go ahead and send it.
				BEGIN
					SET @sent = 1; --Don't send
					SET @fk_provider_status_id = 8 -- = 'opted in to a different office');
				
					-- BEGIN repeated code block (see above)
					-- BEGIN repeated code block (see above)
					SELECT @err = value
					FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin'

					SET @err = REPLACE(@err, '{source_id}', @source_id);
					SET @err = REPLACE(@err, '{source_user_id}', @source_user_id);
					SET @err = REPLACE(@err, '{provider_cell}', @provider_cell);
					-- END repeated code block
					-- END repeated code block

					-- BEGIN repeated code block (see below)
					-- BEGIN repeated code block (see below)
					SELECT @err_reply_text = value
					FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin.err.reply'

					SET @err_reply_text = REPLACE(@err_reply_text, '{source_id}', @source_id);
					SET @err_reply_text = REPLACE(@err_reply_text, '{source_user_id}', @source_user_id);
					SET @err_reply_text = REPLACE(@err_reply_text, '{provider_cell}', @provider_cell);

					SELECT @err_reply_notification = value
					FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.sproc.err.how.to.optin.err.reply.notification'

					SET @err_reply_notification = REPLACE(@err_reply_notification, '{tp_name_or_cell}', @client_cell);
					SET @err_reply_notification = REPLACE(@err_reply_notification, '{source_id}', @source_id);
					SET @err_reply_notification = REPLACE(@err_reply_notification, '{source_user_id}', @source_user_id);
					SET @err_reply_notification = REPLACE(@err_reply_notification, '{provider_cell}', @provider_cell);
					-- END repeated code block
					-- END repeated code block

					SET @ok_to_process = -7 --error, opted-in to a different office
				END
			END
			ELSE -- Not opted out, no record exists for this cell. Insert new OptInOut record.
					-- Opt the user in by default (this only happens once per cell number)
			BEGIN
				SET @send_opt_in_msg = 1;
				INSERT INTO dbCrosslinkGlobal.dbo.tblTextLinkOptInOut
					(pk_textlink_opt_in_out_cell, source_office_id, opt_in_dttm, season, xlive, fk_provider_cell)
				VALUES (@client_cell, @source_id + @source_user_id, @message_date, dbo.getXlinkSeason(), @xlive, @fk_provider_cell)
			END
		END
	END

	--If we're sending this text (the number is not opted-out, opted-in to a different office, or this now old year has not been shutoff)
	IF @sent = 0
	BEGIN
		DECLARE @interval int =
			(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.text.optin.interval');
		DECLARE @userid_interval int = 
			(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
			WHERE pk_key = 'textlink.service.response.text.optin.interval.userid=' + CONVERT(NVARCHAR(1),@source_id) + CONVERT(NVARCHAR(20),@source_user_id));
		IF @userid_interval IS NOT NULL
		BEGIN
			SET @interval = @userid_interval;
		END
		
		IF @last_stop_msg_dttm IS NULL OR DATEDIFF(day, @last_stop_msg_dttm, @message_date) >= @interval
		BEGIN
			SET @send_opt_in_msg = 1;
		END
		
		IF @send_opt_in_msg = 1
		BEGIN
			SET @opt_in_msg_id = NEWID();
			SET @opt_in_msg_date = DATEADD(millisecond, -1, @message_date);
			SET @opt_in_msg = (SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
								WHERE pk_key = 'textlink.service.response.text.optin');
	
			--CLO and MSO were supposed to use EFINs, but they both ended up keeping user_id in place.
			--IF @source_id = 'D'
			--BEGIN
				SET @user_id_for_get_company_name = @source_user_id
			--END
			--ELSE --assuming 'W' or 'M'
			--BEGIN
				--SET @efin_for_get_company_name = @source_user_id
			--END

			SET @opt_in_msg = REPLACE(@opt_in_msg, '{company}', (SELECT dbo.udf_GetCompanyName(CONVERT(INT, @user_id_for_get_company_name), CONVERT(INT, @efin_for_get_company_name))));
				
			INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date,
										outbound, login_id, bulk_text, fk_textlink_source_id, source_user_id, fk_textlink_process_id,
										business_return, return_guid, print_job_id, xlive)
			VALUES (@opt_in_msg_id, @map_id, @opt_in_msg, @opt_in_msg_date,
					1, @login_id, @bulk_text, @source_id, @source_user_id, @process_id,
					@business_return, @return_guid, @print_guid_as_unique_identifier, @xlive)
			
			UPDATE dbCrosslinkGlobal.dbo.tblTextlinkOptInOut WITH (ROWLOCK)
			SET last_stop_msg_dttm = @opt_in_msg_date
			WHERE pk_textlink_opt_in_out_cell = @client_cell
			AND fk_provider_cell = @fk_provider_cell
		END
	END
	
	--Cleanup xml/html character escapes found in many messages
	--I'm not sure where they get put in, but this where they are being taken out.
	SET @message_body = REPLACE(@message_body, '&quot;', '"');
	SET @message_body = REPLACE(@message_body, '&amp;', '&');
	SET @message_body = REPLACE(@message_body, '&apos;', '''');
	SET @message_body = REPLACE(@message_body, '&lt;', '<');
	SET @message_body = REPLACE(@message_body, '&gt;', '>');
	
	-- update tblTextlinkMap with latest data if necessary
	IF @map_id_found = 1
	BEGIN
		SELECT @carrier_id = pk_textlink_carrier_id
		FROM tblTextLinkCarrier WITH (NOLOCK)
		WHERE carrier_name = @carrier_name;
		
		IF ((@carrier_id IS NOT NULL) AND ((@old_map_carrier_id IS NULL) OR (@carrier_id <> @old_map_carrier_id)))
			OR ((@client_name IS NOT NULL) AND ((@old_client_name IS NULL) OR (@client_name <> @old_client_name)))
			OR (@source_user_id <> @old_source_user_id) --source_user_id isn't allowed to be NULL, so no need to check that here
			OR ((@return_guid IS NOT NULL) AND ((@old_return_guid IS NULL) OR (@return_guid <> @old_return_guid)))
			OR (@business_return <> @old_business_return)
			OR ((@print_guid IS NOT NULL) AND ((@old_print_guid IS NULL) OR (@print_guid <> @old_print_guid)))
			OR (@process_id <> @old_fk_process_id)
			OR (@source_id <> @old_fk_source_id)

			UPDATE tblTextLinkMap WITH (ROWLOCK)
			SET fk_textlink_carrier_id = COALESCE(@carrier_id, fk_textlink_carrier_id),
				client_name = COALESCE(@client_name, client_name),
				source_user_id = @source_user_id,
				return_guid = COALESCE(@return_guid, return_guid),
				business_return = @business_return,
				print_guid = COALESCE(@print_guid, print_guid),
				fk_textlink_process_id = @process_id,
				fk_textlink_source_id = @source_id
			WHERE pk_textlink_map_id = @map_id
	END

	INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body,
								message_date, outbound, login_id, sent,
								fk_textlink_provider_status_id, bulk_text, fk_textlink_source_id, source_user_id,
								fk_textlink_process_id, business_return, return_guid, print_job_id, xlive)
	VALUES (@message_guid, @map_id, @message_body,
			@message_date, 1, @login_id, @sent,
			@fk_provider_status_id, @bulk_text, @source_id, @source_user_id,
			@process_id, @business_return, @return_guid, @print_guid_as_unique_identifier, @xlive)

err_exit:

	--if @ok_to_process < 0, we have an error
	--send a reply text with appropriate info
	IF @ok_to_process = -6 OR @ok_to_process = -7 OR (@ok_to_process = -8 AND @send_shutoff_msg = 1) -- opted out, opted in to a diff office, old year standard texts are shutoff
	BEGIN
		SET @err_reply_text_id = NEWID();
		SET @err_reply_text_date = DATEADD(millisecond, 1, @message_date);
		INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, outbound,
									provider_id, message_date, login_id, xlive,
									provider_units,	provider_total_rate, provider_total_amount,
									fk_textlink_process_id, fk_textlink_source_id, source_user_id,
									return_guid, business_return)
		VALUES (@err_reply_text_id, @map_id, @err_reply_text, 0,
				NULL, @err_reply_text_date, @login_id, @xlive,
				0, 0, 0,
				@process_id, @source_id, @source_user_id,
				@return_guid, @business_return);
	END

	SELECT @ok_to_process AS OkToProcess, @sent AS Sent, @provider_cell AS ProviderCell,
		@opt_in_msg_id AS OptInMsgID, @opt_in_msg AS OptInMsgBody, @err AS ErrorMsg,
		@fk_provider_status_id AS ProviderStatusID,
		@err_reply_text_id AS ErrorReplyTextID, @err_reply_text AS ErrorReplyText,
		@err_reply_notification AS ErrorReplyNotification

END

