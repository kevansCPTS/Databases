CREATE TABLE [dbo].[state_rej] (
    [rowID]     INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]      INT         NULL,
    [state_id]  VARCHAR (2) NULL,
    [rej_idx]   SMALLINT    NULL,
    [form_seq]  VARCHAR (4) NULL,
    [field_seq] VARCHAR (4) NULL,
    [rej_code]  VARCHAR (4) NULL,
    CONSTRAINT [PK__state_rej__7D78A4E7] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_strej_0]
    ON [dbo].[state_rej]([pssn] ASC, [state_id] ASC, [rej_idx] ASC);

