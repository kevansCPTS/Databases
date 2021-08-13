CREATE TABLE [dbo].[tblServerAppConfiguration] (
    [pk_key]      VARCHAR (250)  NOT NULL,
    [value]       VARCHAR (2500) NOT NULL,
    [description] VARCHAR (250)  NULL,
    CONSTRAINT [PK_tblServerAppConfiguration] PRIMARY KEY CLUSTERED ([pk_key] ASC)
);

