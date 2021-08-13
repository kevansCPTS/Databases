CREATE TABLE [dbo].[tblRemoteSignatureFee] (
    [rsId]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [returnGuid]       CHAR (32)     NOT NULL,
    [lName]            VARCHAR (255) NOT NULL,
    [pssnLast4]        CHAR (4)      NOT NULL,
    [userId]           INT           NOT NULL,
    [efin]             INT           CONSTRAINT [DF_tblRemoteSignatureFee_efin] DEFAULT ((0)) NOT NULL,
    [signatureType]    TINYINT       NOT NULL,
    [deliveredDate]    DATETIME2 (7) NOT NULL,
    [signaturePk]      INT           NOT NULL,
    [documentPk]       INT           NOT NULL,
    [basePrice]        MONEY         CONSTRAINT [DF_tblRemoteSignatureFee_basePrice] DEFAULT ((0)) NULL,
    [eroAddonFee]      MONEY         CONSTRAINT [DF_tblRemoteSignatureFee_eroAddonFee] DEFAULT ((0)) NULL,
    [billableAddOnFee] BIT           CONSTRAINT [DF_tblRemoteSignatureFee_billableAddOnFee] DEFAULT ((0)) NOT NULL,
    [processDate]      DATETIME2 (7) NULL,
    [effId]            BIGINT        NULL,
    CONSTRAINT [PK_tblRemoteSignatureFee] PRIMARY KEY CLUSTERED ([rsId] ASC),
    CONSTRAINT [UC_tblRemoteSignatureFee] UNIQUE NONCLUSTERED ([returnGuid] ASC, [signatureType] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblRemoteSignatureFee_returnGuid]
    ON [dbo].[tblRemoteSignatureFee]([returnGuid] ASC)
    INCLUDE([userId], [efin], [basePrice], [eroAddonFee]);

