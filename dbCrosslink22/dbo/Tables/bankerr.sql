CREATE TABLE [dbo].[bankerr] (
    [rowID]        INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [rec_type]     VARCHAR (1) NULL,
    [rec_sub]      VARCHAR (1) NULL,
    [pssn]         INT         NULL,
    [sssn]         INT         NULL,
    [master_efin]  INT         NULL,
    [efin]         INT         NULL,
    [trans]        VARCHAR (4) NULL,
    [batch]        VARCHAR (5) NULL,
    [rej_rec_type] VARCHAR (1) NULL,
    [rej_sub_type] VARCHAR (1) NULL,
    [err_ind]      VARCHAR (1) NULL,
    [field_code]   VARCHAR (5) NULL,
    CONSTRAINT [PK__bankerr__07C12930] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_ber]
    ON [dbo].[bankerr]([pssn] ASC, [batch] ASC);

