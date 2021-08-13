CREATE TABLE [dbo].[userxfr] (
    [req_num]      INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [delivered]    CHAR (1) CONSTRAINT [DF_userxfr_delivered] DEFAULT (' ') NULL,
    [user_id]      CHAR (6) NULL,
    [sb_id]        CHAR (6) NULL,
    [fran_id]      CHAR (6) NULL,
    [passwd]       CHAR (8) NULL,
    [feeder_only]  CHAR (1) NULL,
    [copy_flag]    CHAR (4) NULL,
    [info_flag]    CHAR (1) NULL,
    [chk_userid]   CHAR (6) NULL,
    [rej_flag]     CHAR (1) NULL,
    [sta_flag]     CHAR (1) NULL,
    [lock_flag]    CHAR (1) NULL,
    [request_date] DATETIME CONSTRAINT [DF_userxfr_request_date] DEFAULT (getdate()) NOT NULL,
    [doc_flag]     CHAR (1) NULL,
    CONSTRAINT [PK_userxfr] PRIMARY KEY CLUSTERED ([req_num] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [delivered]
    ON [dbo].[userxfr]([delivered] ASC, [req_num] ASC);

