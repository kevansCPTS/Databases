CREATE TABLE [dbo].[tblRefundStatusResponse] (
    [respId]        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [reqId]         INT            NOT NULL,
    [respDate]      DATETIME       CONSTRAINT [DF_tblRefundStatusResponse_respDate] DEFAULT (getdate()) NOT NULL,
    [respCode]      SMALLINT       NOT NULL,
    [return_status] VARCHAR (25)   NULL,
    [refundDate]    DATE           NULL,
    [respXml]       XML            NULL,
    [finalStatus]   BIT            CONSTRAINT [DF_tblRefundStatusResponse_finalStatus] DEFAULT ((0)) NOT NULL,
    [errMsg]        VARCHAR (MAX)  NULL,
    [sentJson]      VARCHAR (1000) NULL,
    [req_num]       AS             ([respId]) PERSISTED NOT NULL,
    [delivered]     CHAR (1)       NOT NULL,
    CONSTRAINT [PK_tblRefundStatusResponse] PRIMARY KEY NONCLUSTERED ([respId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblRefundStatusResponse]
    ON [dbo].[tblRefundStatusResponse]([reqId] ASC, [respId] DESC);

