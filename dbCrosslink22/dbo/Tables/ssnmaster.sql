CREATE TABLE [dbo].[ssnmaster] (
    [pssn]        VARCHAR (9)   NOT NULL,
    [seqno]       CHAR (4)      NULL,
    [user_id]     VARCHAR (6)   NOT NULL,
    [user_spec]   VARCHAR (6)   NULL,
    [sb_id]       VARCHAR (6)   NULL,
    [sb_spec]     VARCHAR (6)   NULL,
    [fran_id]     CHAR (6)      NULL,
    [fran_spec]   CHAR (6)      NULL,
    [guid]        VARCHAR (32)  NULL,
    [bank_id]     VARCHAR (1)   NULL,
    [ws_lock]     VARCHAR (1)   NULL,
    [last_action] VARCHAR (1)   NULL,
    [filler]      VARCHAR (31)  NULL,
    [flst]        CHAR (1)      NOT NULL,
    [recTS]       DATETIME2 (0) NULL,
    [csLock]      CHAR (1)      NULL,
    CONSTRAINT [PK_ssnmaster] PRIMARY KEY NONCLUSTERED ([user_id] ASC, [pssn] ASC, [flst] ASC)
);

