﻿CREATE TABLE [dbo].[tblFeePay] (
    [ID]                  INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ReturnID]            INT             NULL,
    [ReturnGUID]          VARCHAR (50)    NULL,
    [Status]              VARCHAR (20)    NULL,
    [BankID]              CHAR (1)        NOT NULL,
    [RequestType]         VARCHAR (20)    NOT NULL,
    [PrimarySSN]          INT             NOT NULL,
    [Efin]                INT             NOT NULL,
    [Master]              INT             NOT NULL,
    [FLST]                INT             NULL,
    [PrimaryFirstName]    VARCHAR (35)    NOT NULL,
    [PrimaryMiddleName]   VARCHAR (35)    NULL,
    [PrimaryLastName]     VARCHAR (35)    NOT NULL,
    [SecondarySSN]        INT             NULL,
    [SecondaryFirstName]  VARCHAR (35)    NULL,
    [SecondaryMiddleName] VARCHAR (35)    NULL,
    [SecondaryLastName]   VARCHAR (35)    NULL,
    [MailingAddress]      VARCHAR (35)    NULL,
    [MailingCity]         VARCHAR (22)    NULL,
    [MailingState]        VARCHAR (2)     NULL,
    [MailingZip]          VARCHAR (9)     NULL,
    [HomePhone]           VARCHAR (10)    NULL,
    [WorkPhone]           VARCHAR (10)    NULL,
    [RTN]                 INT             NULL,
    [DAN]                 VARCHAR (17)    NULL,
    [LastFourCard]        VARCHAR (4)     NULL,
    [CardNumber]          VARBINARY (256) NULL,
    [CCV]                 VARBINARY (256) NULL,
    [BillingZipCode]      VARCHAR (9)     NULL,
    [CardExpirationDate]  VARCHAR (6)     NULL,
    [PreAuthorization]    VARCHAR (20)    NULL,
    [CellNumber]          VARCHAR (10)    NULL,
    [StateRefundAmount]   INT             NULL,
    [StateFiled]          VARCHAR (2)     NULL,
    [RefundAmount]        INT             NULL,
    [ChargeAmount]        INT             NULL,
    [TranFee]             INT             NULL,
    [SBFee]               INT             NULL,
    [PrepFee]             INT             NULL,
    [ProtPlusFee]         INT             NULL,
    [Error01]             VARCHAR (20)    NULL,
    [Error02]             VARCHAR (20)    NULL,
    [Error03]             VARCHAR (20)    NULL,
    [Error04]             VARCHAR (20)    NULL,
    [Error05]             VARCHAR (20)    NULL,
    [SoftwareVersion]     VARCHAR (8)     NULL,
    [batchId]             VARCHAR (50)    NULL,
    [batchSent]           BIT             CONSTRAINT [DF_tblFeePay_batchSent] DEFAULT ((0)) NOT NULL,
    [batchSentDate]       DATETIME        NULL,
    [lastUpdated]         DATETIME        CONSTRAINT [DF_tblFeePay_lastUpdated] DEFAULT (getdate()) NULL,
    [RAW]                 VARCHAR (200)   NULL,
    CONSTRAINT [PK_FeePay] PRIMARY KEY CLUSTERED ([ID] ASC)
);

