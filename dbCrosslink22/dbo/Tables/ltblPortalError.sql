CREATE TABLE [dbo].[ltblPortalError] (
    [PortalErrorCode] INT          NOT NULL,
    [Description]     VARCHAR (80) CONSTRAINT [DF_ltlbPortalError_Description] DEFAULT ('') NOT NULL,
    [EditBy]          VARCHAR (50) NOT NULL,
    [EditDate]        DATETIME     CONSTRAINT [DF_ltlbPortalError_EditDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ltlbPortalError] PRIMARY KEY CLUSTERED ([PortalErrorCode] ASC)
);

