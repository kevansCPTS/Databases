CREATE TABLE [dbo].[tblRefundStatusRequest] (
    [reqId]         INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]          CHAR (9)     NOT NULL,
    [userId]        INT          NOT NULL,
    [filingStatus]  TINYINT      NULL,
    [refundAmount]  MONEY        NULL,
    [pin]           INT          NULL,
    [reqDate]       DATETIME     CONSTRAINT [DF_tblRefundStatusRequest_reqDate] DEFAULT (getdate()) NOT NULL,
    [return_status] VARCHAR (25) NULL,
    [statusDate]    DATETIME     NULL,
    [refundDate]    DATE         NULL,
    [finalStatus]   BIT          CONSTRAINT [DF_tblRefundStatusRequest_finalStatus] DEFAULT ((0)) NOT NULL,
    [respId]        INT          NULL,
    CONSTRAINT [PK_tblRefundStatusRequest] PRIMARY KEY NONCLUSTERED ([reqId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblRefundStatusRequest]
    ON [dbo].[tblRefundStatusRequest]([pssn] ASC, [userId] ASC, [reqId] ASC, [respId] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_tblRefundStatusRequest]
    ON [dbo].[tblRefundStatusRequest]([respId] ASC);


GO
CREATE NONCLUSTERED INDEX [ID2_tblRefundStatusRequest]
    ON [dbo].[tblRefundStatusRequest]([finalStatus] ASC);

