CREATE TABLE [dbo].[reftblTextlinkError] (
    [pk_textlink_error_id] INT           NOT NULL,
    [reason]               VARCHAR (200) NULL,
    [error_desc]           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_reftblTextlinkError] PRIMARY KEY CLUSTERED ([pk_textlink_error_id] ASC)
);

