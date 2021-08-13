CREATE TABLE [dbo].[tblTextLinkProviderCell] (
    [pk_textlink_provider_cell] CHAR (10)     NOT NULL,
    [use_type]                  CHAR (10)     CONSTRAINT [DF_tblTextLinkProviderCell_use_type] DEFAULT ('default') NOT NULL,
    [blacklisted]               BIT           CONSTRAINT [DF_tblTextLinkProviderCell_blacklisted] DEFAULT ((0)) NOT NULL,
    [last_used]                 DATETIME2 (7) CONSTRAINT [DF_tblTextLinkProviderCell_lastused] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_tblTextLinkProviderCell] PRIMARY KEY CLUSTERED ([pk_textlink_provider_cell] ASC)
);

