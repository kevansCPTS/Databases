CREATE TABLE [dbo].[tblMgmt] (
    [req_num]     INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [delivered]   CHAR (1) CONSTRAINT [DF_tblMgmt_delivered] DEFAULT (' ') NOT NULL,
    [userid]      INT      NOT NULL,
    [seqno]       INT      NOT NULL,
    [xmldata]     XML      NOT NULL,
    [datecreated] DATETIME CONSTRAINT [DF_tblMgmt_createdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblMgmt] PRIMARY KEY CLUSTERED ([userid] ASC, [seqno] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [delivered]
    ON [dbo].[tblMgmt]([delivered] ASC, [req_num] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblMgmt]
    ON [dbo].[tblMgmt]([req_num] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [user_seq]
    ON [dbo].[tblMgmt]([userid] ASC, [seqno] ASC);

