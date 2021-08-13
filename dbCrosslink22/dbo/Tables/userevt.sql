CREATE TABLE [dbo].[userevt] (
    [evtguid]  CHAR (32) NOT NULL,
    [pssn]     CHAR (9)  NOT NULL,
    [flst]     CHAR (1)  NOT NULL,
    [type]     INT       NULL,
    [evtdate]  CHAR (8)  NULL,
    [evttime]  CHAR (6)  NULL,
    [operator] CHAR (8)  NULL,
    [site]     CHAR (7)  NULL,
    [userid]   CHAR (8)  NULL,
    [rtnguid]  CHAR (32) NULL,
    [details]  CHAR (60) NULL,
    [usertype] CHAR (10) NULL,
    [evtcorp]  CHAR (1)  NULL,
    CONSTRAINT [PK_userevt] PRIMARY KEY CLUSTERED ([evtguid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_userev]
    ON [dbo].[userevt]([pssn] ASC);


GO
CREATE NONCLUSTERED INDEX [userevt_rtn_guid]
    ON [dbo].[userevt]([rtnguid] ASC);


GO
CREATE NONCLUSTERED INDEX [userevt_rtnguid_index]
    ON [dbo].[userevt]([rtnguid] ASC, [evtdate] ASC, [evttime] ASC);

