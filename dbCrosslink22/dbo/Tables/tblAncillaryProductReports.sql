CREATE TABLE [dbo].[tblAncillaryProductReports] (
    [account]    VARCHAR (8)   NOT NULL,
    [aprodId]    INT           NOT NULL,
    [reportName] VARCHAR (150) NOT NULL,
    [tag]        CHAR (3)      NOT NULL,
    [createDate] DATETIME      CONSTRAINT [DF_tblAncillaryProductReports_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]   VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductReports_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate] DATETIME      CONSTRAINT [DF_tblAncillaryProductReports_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]   VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductReports_modifyBy] DEFAULT (original_login()) NOT NULL,
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_tblAncillaryProductReports] PRIMARY KEY CLUSTERED ([account] ASC, [aprodId] ASC, [reportName] ASC)
);

