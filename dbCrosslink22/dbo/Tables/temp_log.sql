CREATE TABLE [dbo].[temp_log] (
    [reqNum]            INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]              INT          NOT NULL,
    [seqNo]             INT          NOT NULL,
    [returnType]        CHAR (1)     NOT NULL,
    [acknowledged]      BIT          NOT NULL,
    [includeAttachment] BIT          NOT NULL,
    [requestDate]       DATETIME     CONSTRAINT [DF_RequestDate] DEFAULT (getdate()) NOT NULL,
    [requester]         VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_temp_log] PRIMARY KEY NONCLUSTERED ([reqNum] ASC)
);

