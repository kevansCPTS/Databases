CREATE TABLE [dbo].[tblTextLink] (
    [pk_textlink_id]                 UNIQUEIDENTIFIER   CONSTRAINT [DF_tblTextLink_pk_textlink_id] DEFAULT (newid()) NOT NULL,
    [fk_textlink_map_id]             INT                NOT NULL,
    [message_date]                   DATETIMEOFFSET (3) CONSTRAINT [DF_tblTextLink_message_date] DEFAULT (sysdatetimeoffset()) NULL,
    [message_body]                   VARCHAR (160)      NOT NULL,
    [outbound]                       BIT                CONSTRAINT [DF_tblTextLink_outbound] DEFAULT ((1)) NOT NULL,
    [sent]                           BIT                CONSTRAINT [DF_tblTextLink_sent] DEFAULT ((0)) NOT NULL,
    [login_id]                       VARCHAR (8)        NULL,
    [inserted_date]                  DATETIME2 (7)      CONSTRAINT [DF_tblTextLink_inserted_date] DEFAULT (sysutcdatetime()) NOT NULL,
    [bulk_text]                      BIT                CONSTRAINT [DF_tblTextLink_bulk_text] DEFAULT ((0)) NOT NULL,
    [xlive]                          BIT                CONSTRAINT [DF_tblTextLink_xlive] DEFAULT ((0)) NOT NULL,
    [print_job_id]                   UNIQUEIDENTIFIER   NULL,
    [sent_date]                      DATETIME2 (7)      NULL,
    [provider_id]                    UNIQUEIDENTIFIER   CONSTRAINT [DF_tblTextlink_provider_id] DEFAULT (NULL) NULL,
    [provider_status_seq]            INT                NULL,
    [provider_received_dttm]         DATETIME2 (7)      NULL,
    [provider_queued_dttm]           DATETIME2 (7)      NULL,
    [provider_sent_dttm]             DATETIME2 (7)      NULL,
    [provider_delivery_dttm]         DATETIME2 (7)      NULL,
    [provider_units]                 INT                NULL,
    [provider_total_rate]            DECIMAL (18, 9)    NULL,
    [provider_total_amount]          DECIMAL (18, 9)    NULL,
    [fk_textlink_error_id]           INT                NULL,
    [fk_textlink_process_id]         INT                NULL,
    [return_guid]                    CHAR (32)          NULL,
    [business_return]                BIT                CONSTRAINT [DF_tblTextLink_business_return] DEFAULT ((0)) NOT NULL,
    [fk_textlink_provider_status_id] INT                NULL,
    [fk_textlink_source_id]          CHAR (1)           NULL,
    [source_user_id]                 VARCHAR (25)       NULL,
    [provider_status_sent_to_client] BIT                CONSTRAINT [DF_tblTextlink_provider_status_sent_to_client] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTextLink] PRIMARY KEY NONCLUSTERED ([pk_textlink_id] ASC),
    CONSTRAINT [FK_tblTextLink_reftblTextlinkError] FOREIGN KEY ([fk_textlink_error_id]) REFERENCES [dbo].[reftblTextlinkError] ([pk_textlink_error_id]),
    CONSTRAINT [FK_tblTextLink_reftblTextLinkProviderStatus] FOREIGN KEY ([fk_textlink_provider_status_id]) REFERENCES [dbo].[reftblTextlinkProviderStatus] ([pk_textlink_provider_status_id]),
    CONSTRAINT [FK_tblTextLink_reftblTextlinkSource] FOREIGN KEY ([fk_textlink_source_id]) REFERENCES [dbo].[reftblTextlinkSource] ([pk_textlink_source_id]),
    CONSTRAINT [FK_tblTextLink_tblTextLinkMap] FOREIGN KEY ([fk_textlink_map_id]) REFERENCES [dbo].[tblTextLinkMap] ([pk_textlink_map_id]),
    CONSTRAINT [FK_tblTextLink_tblTextlinkProcess] FOREIGN KEY ([fk_textlink_process_id]) REFERENCES [dbo].[tblTextLinkProcess] ([pk_textlink_process_id])
);


GO
CREATE NONCLUSTERED INDEX [IX_provider_id]
    ON [dbo].[tblTextLink]([provider_id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_msgDate_where_unsent_inbound_tblTextLink]
    ON [dbo].[tblTextLink]([message_date] ASC) WHERE ([sent]=(0) AND [outbound]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_insertedDate_where_outbound_tblTextLink]
    ON [dbo].[tblTextLink]([inserted_date] ASC) WHERE ([outbound]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_bulk_insertedDate_where_unsent_outbound_notxlive_tblTextLink]
    ON [dbo].[tblTextLink]([bulk_text] ASC, [inserted_date] ASC) WHERE ([sent]=(0) AND [outbound]=(1) AND [xlive]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_insertedDate_where_outbound_unsent_tblTextLink]
    ON [dbo].[tblTextLink]([inserted_date] ASC) WHERE ([outbound]=(1) AND [sent]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_sentdate_where_outbound_sent_tblTextLink]
    ON [dbo].[tblTextLink]([sent_date] DESC) WHERE ([outbound]=(1) AND [sent]=(1));


GO

CREATE TRIGGER [dbo].tblTextink_update_insert ON [dbo].[tblTextLink] AFTER UPDATE, INSERT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Only update set sent_date when sent is changed to 1, or is inserted with sent = 1
	UPDATE tblTextlink
	SET sent_date =
		CASE WHEN (d.pk_textlink_id IS NULL) --insert
			THEN i.inserted_date -- no reason to have a discrepancy between sent_date and inserted_date in this case
		ELSE 
			SYSUTCDATETIME() -- update
		END
	FROM tblTextlink t
	INNER JOIN Inserted i ON t.pk_textlink_id = i.pk_textlink_id
	LEFT JOIN Deleted d ON t.pk_textlink_id = d.pk_textlink_id
	WHERE i.sent = 1 AND (
		(d.pk_textlink_id IS NOT NULL AND i.sent != d.sent) -- updated/changed to 1 from 0
		 OR d.pk_textlink_id IS NULL -- inserted as 1
	) 

	--Only update provider_status_sent_to_client when fk_textlink_provider_status_id changed from it's prior value, or is inserted with a non-null vaulue
	UPDATE tblTextlink
	SET provider_status_sent_to_client = 0
	FROM tblTextlink t
	INNER JOIN Inserted i ON t.pk_textlink_id = i.pk_textlink_id
	LEFT JOIN Deleted d ON t.pk_textlink_id = d.pk_textlink_id
	WHERE i.fk_textlink_provider_status_id IS NOT NULL AND (
		(d.pk_textlink_id IS NOT NULL AND (d.fk_textlink_provider_status_id IS NULL OR i.fk_textlink_provider_status_id != d.fk_textlink_provider_status_id)) -- updated/changed from it's prior value
		 OR d.pk_textlink_id IS NULL -- inserted as NOT NULL
	) 

END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The xlink preparer login id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblTextLink', @level2type = N'COLUMN', @level2name = N'login_id';

