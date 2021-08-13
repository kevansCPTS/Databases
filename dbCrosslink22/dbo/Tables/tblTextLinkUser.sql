CREATE TABLE [dbo].[tblTextLinkUser] (
    [user_id]               INT                NOT NULL,
    [last_shutoff_msg_dttm] DATETIMEOFFSET (3) NULL,
    CONSTRAINT [PK_tblTextLinkUser] PRIMARY KEY NONCLUSTERED ([user_id] ASC)
);

