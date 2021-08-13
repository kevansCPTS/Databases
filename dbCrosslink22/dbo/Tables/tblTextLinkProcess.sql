CREATE TABLE [dbo].[tblTextLinkProcess] (
    [pk_textlink_process_id] INT          IDENTITY (1, 1) NOT NULL,
    [process_name]           VARCHAR (30) NOT NULL,
    CONSTRAINT [PK_tblTextLinkProcess] PRIMARY KEY CLUSTERED ([pk_textlink_process_id] ASC)
);

