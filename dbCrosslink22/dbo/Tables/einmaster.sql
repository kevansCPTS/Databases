CREATE TABLE [dbo].[einmaster] (
    [primid]      VARCHAR (9)   NOT NULL,
    [filingtype]  CHAR (1)      NOT NULL,
    [user_id]     VARCHAR (6)   NOT NULL,
    [user_spec]   VARCHAR (6)   NULL,
    [sb_id]       VARCHAR (6)   NULL,
    [sb_spec]     VARCHAR (6)   NULL,
    [fran_id]     CHAR (6)      NULL,
    [fran_spec]   CHAR (6)      NULL,
    [seqno]       CHAR (4)      NULL,
    [guid]        VARCHAR (32)  NULL,
    [last_action] VARCHAR (1)   NULL,
    [idtype]      VARCHAR (1)   NULL,
    [filler]      VARCHAR (31)  NULL,
    [recTS]       DATETIME2 (0) NULL,
    [csLock]      CHAR (1)      NULL,
    CONSTRAINT [PK_einmaster] PRIMARY KEY NONCLUSTERED ([user_id] ASC, [primid] ASC, [filingtype] ASC)
);

