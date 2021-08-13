CREATE TABLE [dbo].[WebserviceClient] (
    [ClientId]            VARCHAR (200) NOT NULL,
    [ClientName]          VARCHAR (200) NOT NULL,
    [Active]              BIT           CONSTRAINT [DF_Table_1_ProviderActive] DEFAULT ((1)) NOT NULL,
    [LastFetch]           DATETIME      CONSTRAINT [DF_WebserviceClient_LastFetch] DEFAULT (getdate()) NOT NULL,
    [IncludePrintAndMail] BIT           DEFAULT ((0)) NOT NULL,
    [CanFetchByAccount]   BIT           CONSTRAINT [CanFetchByAccountDefault] DEFAULT ((0)) NOT NULL,
    [Account]             VARCHAR (200) CONSTRAINT [AccountDefault] DEFAULT ((0)) NOT NULL,
    [Change_ID]           INT           NULL,
    CONSTRAINT [PK_WebserviceClient] PRIMARY KEY CLUSTERED ([ClientId] ASC)
);

