CREATE TABLE [dbo].[tblCustomerReports] (
    [account]    VARCHAR (8)   NOT NULL,
    [reportName] VARCHAR (150) NOT NULL,
    [createDate] DATETIME      CONSTRAINT [DF_tblCustomerReports_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]   VARCHAR (50)  CONSTRAINT [DF_tblCustomerReports_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate] DATETIME      CONSTRAINT [DF_tblCustomerReports_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]   VARCHAR (50)  CONSTRAINT [DF_tblCustomerReports_modifyBy] DEFAULT (original_login()) NOT NULL,
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_tblCustomerReports] PRIMARY KEY CLUSTERED ([account] ASC, [reportName] ASC)
);

