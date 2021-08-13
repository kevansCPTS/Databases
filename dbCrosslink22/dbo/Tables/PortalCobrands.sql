CREATE TABLE [dbo].[PortalCobrands] (
    [CobrandID]     INT          IDENTITY (1, 1) NOT NULL,
    [URLReferrer]   VARCHAR (50) NOT NULL,
    [ShortSiteName] VARCHAR (10) NULL,
    [LongSiteName]  VARCHAR (50) NULL,
    [TemplateName]  VARCHAR (20) NULL,
    [TemplatePath]  VARCHAR (50) NULL,
    [LogoName]      VARCHAR (50) NULL,
    [CSSName]       VARCHAR (50) NULL,
    [CSSPath]       VARCHAR (80) NULL,
    [HomeSiteURL]   VARCHAR (80) NULL,
    [SupportPhone]  VARCHAR (10) NULL,
    [SupportEmail]  VARCHAR (50) NULL,
    [editedBy]      VARCHAR (30) NOT NULL,
    [editDate]      DATE         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PortalCobrands] PRIMARY KEY CLUSTERED ([CobrandID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_URLReferrer]
    ON [dbo].[PortalCobrands]([URLReferrer] ASC);

