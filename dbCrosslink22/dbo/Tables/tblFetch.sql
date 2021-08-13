CREATE TABLE [dbo].[tblFetch] (
    [idtype]      CHAR (1)  NOT NULL,
    [prim_id]     INT       NOT NULL,
    [seq_no]      INT       NOT NULL,
    [user_id]     INT       NULL,
    [sender_id]   INT       NULL,
    [arc_dt]      CHAR (10) NULL,
    [user_spec]   INT       NULL,
    [filing_stat] CHAR (1)  NULL,
    [xmitflag]    CHAR (1)  NULL,
    CONSTRAINT [PK_tblFetch] PRIMARY KEY CLUSTERED ([idtype] ASC, [prim_id] ASC, [seq_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblFetch]
    ON [dbo].[tblFetch]([prim_id] ASC, [user_id] ASC);

