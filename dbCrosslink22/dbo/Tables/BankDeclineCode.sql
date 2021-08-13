CREATE TABLE [dbo].[BankDeclineCode] (
    [BankDeclineCodeID] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BankID]            CHAR (1)      NOT NULL,
    [DeclineCode]       VARCHAR (50)  NOT NULL,
    [Description]       VARCHAR (500) NULL,
    [EditDate]          DATETIME      CONSTRAINT [DF_BankDeclineCode_EditDate] DEFAULT (getdate()) NOT NULL,
    [EditBy]            VARCHAR (50)  CONSTRAINT [DF_BankDeclineCode_EditBy] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_BankDeclineCode] PRIMARY KEY CLUSTERED ([BankDeclineCodeID] ASC)
);

