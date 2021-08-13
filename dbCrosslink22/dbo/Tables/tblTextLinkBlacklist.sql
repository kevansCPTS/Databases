CREATE TABLE [dbo].[tblTextLinkBlacklist] (
    [pk_textlink_blacklist_cell] CHAR (10)          NOT NULL,
    [blacklist_date]             DATETIMEOFFSET (3) NULL,
    [last_stop_msg_date]         DATETIMEOFFSET (3) NULL,
    [last_stop_msg_date_bulk]    DATETIMEOFFSET (3) NULL,
    CONSTRAINT [PK_tblTextLinkBlacklist] PRIMARY KEY CLUSTERED ([pk_textlink_blacklist_cell] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date of the last time the "To unsubscribe, repy STOP" message was sent to this cell number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblTextLinkBlacklist', @level2type = N'COLUMN', @level2name = N'last_stop_msg_date';

