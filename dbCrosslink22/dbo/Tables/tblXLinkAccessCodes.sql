CREATE TABLE [dbo].[tblXLinkAccessCodes] (
    [ac_id]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ac_code]        CHAR (2)     NOT NULL,
    [ac_description] VARCHAR (35) NOT NULL,
    CONSTRAINT [PK_tblXLinkAccessCodes] PRIMARY KEY CLUSTERED ([ac_id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UN_ac_code]
    ON [dbo].[tblXLinkAccessCodes]([ac_code] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);

