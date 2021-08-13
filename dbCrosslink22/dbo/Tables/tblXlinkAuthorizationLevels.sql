CREATE TABLE [dbo].[tblXlinkAuthorizationLevels] (
    [auth_id]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [auth_code]        CHAR (2)     NULL,
    [auth_description] VARCHAR (35) NULL,
    CONSTRAINT [PK_tblXlinkAuthorizationLevels] PRIMARY KEY CLUSTERED ([auth_id] ASC),
    CONSTRAINT [UN_tblXlinkAuthorizationLevels] UNIQUE NONCLUSTERED ([auth_code] ASC)
);

