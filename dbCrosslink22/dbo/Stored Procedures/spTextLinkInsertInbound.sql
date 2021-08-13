

-- =============================================
-- Author:		Steve Trautman
-- Create date: 9/6/2011
-- 2/12/2014	Insert a new inbound (to preparer) TextLink message
-- 9/23/2015	xlive updates
-- =============================================
CREATE PROCEDURE [dbo].[spTextLinkInsertInbound]
	@message_body varchar(160),
	@client_cell varchar(11),
	@provider_cell varchar(11),
	@provider_message_id uniqueidentifier = NULL,
	@is_queue bit = 0, --no longer used. ALL inbound texts (except MSO/CLO) send xlive queue messages now.
	@provider_units int = NULL,
	@provider_total_rate decimal(18,9) = NULL,
	@provider_total_amount decimal(18,9) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ok_to_process int = 1, -- -1 is error, 0 is do not process, 1 is ok to process
			@xlive bit = 1, -- For taxpayer replies, actually ALL inbound texts no matter the source,
							-- we'll always send xlive queue messages, except for MSO/CLO (they don't use xlive)
							-- Sometimes we insert inbound texts while processing outbound texts, see textlink windows service app.
			@office_id varchar(26) = NULL,
			@source_id char(1) = NULL,
			@source_user_id varchar(25) = NULL,
			@pk_textlink_id uniqueidentifier = NULL,
			@message_date datetimeoffset(3) = sysdatetimeoffset(),
			@received_msg varchar(160),
			@send_opt_out_confirmation bit = 0,
			@send_opt_in_confirmation bit = 0,
			@send_unknown_office_msg bit = 0,
			@send_office_response bit = 0,
			@send_office_not_subscribed_response bit = 0,
			@send_help_response bit = 0,
			@response_msg varchar(160) = NULL,
			@pk_textlink_id_response uniqueidentifier = NULL,
			@response_msg_dttm datetimeoffset(3) = NULL,
			@business_return bit = 0,
			@login_id varchar(8) = NULL,
			@process_id int = 2, --default to standard text
			@return_guid varchar(32) = NULL,
			@client_name varchar(200) = NULL,
			@start_msg varchar(160) = NULL,
			@parsed_source_id char(1) = NULL,
			@parsed_source_user_id varchar(160) = NULL, -- userid for desktop, was supposed to be efin for MSO/CLO, but they both ended up keeping userid in place
			@parsed_office_id varchar(160) = NULL,
			@parsed_user_id varchar(160) = NULL,
			@parsed_efin varchar(160) = NULL,
			@map_id int = 0,
			@tblTextlinkOptInOutRowExists bit = 0,
			@opt_in_dttm datetimeoffset(3) = NULL,
			@opt_out_dttm datetimeoffset(3) = NULL,
			@fk_provider_cell int = NULL;
	
	IF EXISTS (SELECT pk_textlink_id FROM tblTextLink WITH (ROWLOCK) WHERE provider_id = @provider_message_id)
	BEGIN
		SET @ok_to_process = 0;
		-- we are done, exiting after final select at end
	END
	ELSE
	BEGIN
		SET @received_msg = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(@message_body),
				'.',''),
				',',''),
				'!',''),
				'''',''),
				'"',''),
				'PLEASE',''),
				'PLS','')));
		SET @received_msg = REPLACE(@received_msg,'STP','STOP');
		SET @received_msg = REPLACE(@received_msg,'TXT','TEXT');
		SET @received_msg = REPLACE(@received_msg,'TEXTS','TEXT');
		SET @received_msg = REPLACE(@received_msg,'TXTNG','TEXTING');
		SET @received_msg = REPLACE(@received_msg,'SNDNG','SENDING');
		SET @received_msg = REPLACE(@received_msg,'SNDG','SENDING');
		SET @received_msg = REPLACE(@received_msg,'SND','SEND');
		SET @received_msg = REPLACE(@received_msg,'DNT','DONT');
		SET @received_msg = REPLACE(@received_msg,'MSG','MESSAGE');
		SET @received_msg = REPLACE(@received_msg,'MESSAGES','MESSAGE');
		SET @received_msg = REPLACE(@received_msg,'#','NUMBER');
		SET @received_msg = REPLACE(@received_msg,'NO','NUMBER');
		SET @received_msg = REPLACE(@received_msg,'NUM','NUMBER');
		SET @received_msg = REPLACE(@received_msg,'NMBR','NUMBER');
		SET @received_msg = REPLACE(@received_msg,'REMV','REMOVE');
		SET @received_msg = REPLACE(@received_msg,'RMV','REMOVE');
		
		EXECUTE @fk_provider_cell = dbCrosslinkGlobal.dbo.up_GetPkTextlinkProviderCell @provider_cell

		SELECT @office_id = source_office_id,
			   @source_id = SUBSTRING(source_office_id, 1, 1),
			   @source_user_id = SUBSTRING(source_office_id, 2, LEN(source_office_id) - 1),
			   @tblTextlinkOptInOutRowExists = 1,
			   @opt_in_dttm = opt_in_dttm,
			   @opt_out_dttm = opt_out_dttm
		FROM dbCrosslinkGlobal.dbo.tblTextLinkOptInOut WITH (ROWLOCK)
		WHERE pk_textlink_opt_in_out_cell = @client_cell
		AND fk_provider_cell = @fk_provider_cell

		IF @tblTextlinkOptInOutRowExists = 0 -- no row exists for this cell, so create one.
		BEGIN
			INSERT INTO dbCrosslinkGlobal.dbo.tblTextLinkOptInOut (pk_textlink_opt_in_out_cell, fk_provider_cell)
			VALUES (@client_cell, @fk_provider_cell)
		END

		IF	@received_msg = 'BLOCKED AT DESTINATION' OR
			LEFT(@received_msg, 4) = 'STOP' OR
			LEFT(@received_msg, 3) = 'END' OR
			LEFT(@received_msg, 4) = 'QUIT' OR
			LEFT(@received_msg, 6) = 'CANCEL' OR
			LEFT(@received_msg, 11) = 'UNSUBSCRIBE' OR
			LEFT(@received_msg, 9) = 'DONT TEXT' OR
			LEFT(@received_msg, 12) = 'WRONG NUMBER' OR
			@received_msg = 'REMOVE' OR
			@received_msg = 'REMOVE FROM LIST' OR
			@received_msg = 'REMOVE NUMBER' OR
			@received_msg = 'REMOVE FROM YOUR LIST' OR
			@received_msg = 'REMOVE ME' OR
			@received_msg = 'REMOVE ME FROM LIST' OR
			@received_msg = 'REMOVE MY NUMBER' OR
			@received_msg = 'REMOVE ME FROM YOUR LIST'
		BEGIN
			--Opt-out this number
			UPDATE dbCrosslinkGlobal.dbo.tblTextLinkOptInOut
			SET opt_out_dttm = @message_date,
				opt_in_dttm = NULL
			WHERE pk_textlink_opt_in_out_cell = @client_cell
			AND opt_out_dttm IS NULL
			AND fk_provider_cell = @fk_provider_cell

			IF @received_msg != 'BLOCKED AT DESTINATION'
				SET @send_opt_out_confirmation = 1;
		END
		ELSE
		IF LEFT(@received_msg, 5) = 'START'
		BEGIN
			SET @start_msg = SUBSTRING(@received_msg, 6, LEN(@received_msg))
			--find first space-delimited "word", or just the rest of the string if no spaces
			SET @parsed_office_id = dbo.udfGetFirstWord(@start_msg)
			SET @parsed_source_id = SUBSTRING(@parsed_office_id, 1, 1)
			SET @parsed_source_user_id = SUBSTRING(@parsed_office_id, 2, LEN(@parsed_office_id) - 1)
			IF @parsed_source_user_id like '%[^0-9]%' or @parsed_source_user_id = ''
				SET @parsed_source_user_id = NULL

			IF NOT EXISTS (SELECT pk_textlink_source_id FROM reftblTextlinkSource WITH (NOLOCK) WHERE pk_textlink_source_id = @parsed_source_id)
			BEGIN
				SET @send_unknown_office_msg = 1
			END
			ELSE
			BEGIN
				--verify userid/EFIN is valid
				-- userid for desktop, was supposed to be efin for MSO/CLO, but they both ended up keeping userid in place
				--IF @parsed_source_id = 'D'
				--BEGIN
					--All use user_id
					IF EXISTS (SELECT user_id FROM tblUser WITH (NOLOCK) WHERE user_id = CONVERT(INT, @parsed_source_user_id))
					BEGIN
						SET @send_opt_in_confirmation = 1
					END
					ELSE
					BEGIN
						SET @send_unknown_office_msg = 1
					END
				/*END
				ELSE --assuming 'W' or 'M'
				BEGIN
					--MSO or Crosslink Online. Uses EFIN
					IF EXISTS (SELECT efin FROM efin WITH (NOLOCK) WHERE efin = CONVERT(INT, @parsed_source_user_id))
					BEGIN
						SET @send_opt_in_confirmation = 1
					END
					ELSE
					BEGIN
						SET @send_unknown_office_msg = 1
					END
				END*/

				IF @send_opt_in_confirmation = 1
				BEGIN
					UPDATE dbCrosslinkGlobal.dbo.tblTextLinkOptInOut
					SET opt_out_dttm = NULL,
						opt_in_dttm = @message_date,
						source_office_id = @parsed_office_id
					WHERE pk_textlink_opt_in_out_cell = @client_cell
					AND fk_provider_cell = @fk_provider_cell

					SET @source_id = @parsed_source_id;
				END			
			END
		END
		ELSE
		IF @received_msg = 'OFFICE'
		BEGIN
			/*SELECT @parsed_office_id = source_office_id
			FROM dbCrosslinkGlobal.dbo.tblTextLinkOptInOut WITH (ROWLOCK)
			WHERE pk_textlink_opt_in_out_cell = @client_cell
				  AND opt_in_dttm IS NOT NULL
				  AND opt_out_dttm IS NULL*/

			IF @opt_in_dttm IS NULL OR @opt_out_dttm IS NOT NULL
			BEGIN
				SET @send_office_not_subscribed_response = 1
			END
			ELSE
			BEGIN
				SET @parsed_office_id = @office_id
				SET @parsed_source_id = @source_id
				SET @parsed_source_user_id = @source_user_id

				SET @send_office_response = 1
			END
		END
		ELSE
		IF @received_msg = 'HELP'
		BEGIN
			SET @send_help_response = 1
		END

		--do we already have a tblTextLinkMap entry for this cell/ssn/user_id combo?
		SELECT	@map_id = m.pk_textlink_map_id,
				@source_id = CASE WHEN @source_id IS NULL THEN m.fk_textlink_source_id ELSE @source_id END, -- keep value from optInOut table if it is there
				@source_user_id =  CASE WHEN @source_user_id IS NULL THEN m.source_user_id ELSE @source_user_id END, -- keep value from optInOut table if it is there
				@business_return = m.business_return,
				@return_guid = m.return_guid,
				@client_name = m.client_name
		FROM tblTextLinkMap m WITH (ROWLOCK)
		WHERE m.client_cell = @client_cell
		AND m.fk_textlink_provider_cell = @provider_cell;
	    
		--If this is for MSO/CLO, don't send xlive messages.
		IF @source_id IN ('M', 'W')
		BEGIN
			SET @xlive = 0
		END

		IF @map_id = 0 --no entry
		BEGIN
			IF EXISTS (SELECT pk_textlink_provider_cell FROM tblTextLinkProviderCell WITH (NOLOCK) WHERE pk_textlink_provider_cell = @provider_cell)
			BEGIN
				INSERT INTO tblTextLinkMap (client_cell, fk_textlink_provider_cell, fk_textlink_process_id)
				VALUES (@client_cell, @provider_cell, @process_id)
				SET @map_id = SCOPE_IDENTITY();
			END
			ELSE
			BEGIN
				SET @ok_to_process = -1;
			END
		END
		
		IF @ok_to_process <> -1
		BEGIN
			IF @provider_message_id IS NULL
			BEGIN
				SET @pk_textlink_id = NEWID();
			END
			ELSE
			BEGIN
				SET @pk_textlink_id = @provider_message_id;
			END

			SELECT TOP 1 @login_id = t.login_id,
						 @process_id = t.fk_textlink_process_id
			FROM tblTextLink t WITH (NOLOCK)
			WHERE t.outbound = 1
			AND t.fk_textlink_map_id = @map_id
			ORDER BY t.inserted_date DESC

			INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, outbound,
									 provider_id, message_date, login_id, xlive, provider_units,
									 provider_total_rate, provider_total_amount, fk_textlink_process_id,
									 fk_textlink_source_id, source_user_id, return_guid, business_return)
			VALUES (@pk_textlink_id, @map_id, @message_body, 0,
					@provider_message_id, @message_date, @login_id, @xlive, @provider_units,
					@provider_total_rate, @provider_total_amount, @process_id, @source_id, @source_user_id,
					@return_guid, @business_return);
			
			IF @parsed_source_id IS NULL
			BEGIN
				SET @parsed_source_id = @source_id
				SET @parsed_source_user_id = @source_user_id
			END
			--CLO and MSO were supposed to use EFINs, but they both ended up keeping user_id in place.
			--IF @parsed_source_id = 'D'
			--BEGIN
				SET @parsed_user_id = @parsed_source_user_id
			--END
			--ELSE --assuming 'W' or 'M'. If it's NULL, no office ID was found in either optInOut table or Map table, so everything will be NULL, and this is OK (GetCompanyName will return '')
			--BEGIN
				--SET @parsed_efin = @parsed_source_user_id
			--END

			IF @send_opt_out_confirmation = 1
			BEGIN		
				--Send the unsubscribed confirmation text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.optout');

				SET @response_msg = REPLACE(@response_msg, '{company}', (SELECT dbo.udf_GetCompanyName(CONVERT(INT, @parsed_user_id), CONVERT(INT, @parsed_efin))));
				
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
			ELSE
			IF @send_opt_in_confirmation = 1
			BEGIN		
				--Send the unsubscribed confirmation text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.optin');

				SET @response_msg = REPLACE(@response_msg, '{company}', (SELECT dbo.udf_GetCompanyName(CONVERT(INT, @parsed_user_id), CONVERT(INT, @parsed_efin))));
				
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
			ELSE
			IF @send_unknown_office_msg = 1
			BEGIN		
				--Send the unknown office id text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.start.invalid');
			
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
			ELSE
			IF @send_office_response = 1
			BEGIN		
				--Send the office response text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.office');

				SET @response_msg = REPLACE(@response_msg, '{company}', (SELECT dbo.udf_GetCompanyName(CONVERT(INT, @parsed_user_id), CONVERT(INT, @parsed_efin))));
				SET @response_msg = REPLACE(@response_msg, '{officeid}', @parsed_office_id);
			
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
			ELSE
			IF @send_office_not_subscribed_response = 1
			BEGIN		
				--Send the unknown office id text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.office.not.subscribed');
			
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
			ELSE
			IF @send_help_response = 1
			BEGIN		
				--Send the help response text
				SET @response_msg_dttm = DATEADD(SECOND, 1, @message_date);
				SET @response_msg =
					(SELECT value FROM tblServerAppConfiguration WITH (NOLOCK)
					WHERE pk_key = 'textlink.service.response.text.help');
			
				SET @pk_textlink_id_response = NEWID();
				
				--This text will be sent via the legacy dbPoller (not xlive). If xlive=1, the legacy dbPoller 
				--WILL send the text EVENTUALLY, but there is a significant delay. The dbPoller only picks up unsent xlive texts after a delay
				--because it gives the xlive queue processor lots of time 
				--to send it before jumping in to send it, assuming xlive processor failed to send it and won't ever be able to send it.
				--That can happen if the xlive processor inserts the text into the DB, but then has an exception while sending the text and can't recover.
				--So here xlive=0 to avoid that failsafe-workaround. We know we're sending it via dbPoller up front.
				INSERT INTO tblTextLink (pk_textlink_id, fk_textlink_map_id, message_body, message_date, outbound, xlive, login_id, fk_textlink_source_id, source_user_id, return_guid, business_return)
				VALUES (@pk_textlink_id_response, @map_id, @response_msg, @response_msg_dttm, 1, 0, @login_id, @source_id, @source_user_id, @return_guid, @business_return)
			END
		END
	END

	SELECT	@ok_to_process AS OkToProcess, @parsed_source_user_id AS SourceUserId, @pk_textlink_id AS pkTextlinkId,
			@pk_textlink_id_response AS pkTextlinkIdResponse, @response_msg AS ResponseMsg,
			@response_msg_dttm AS ResponseMsgDate, @return_guid AS ReturnGuid,
			@message_date AS MessageDate, @business_return AS BusinessReturn, @login_id AS LoginId,
			@client_name AS ClientName, @xlive AS Xlive;
END


