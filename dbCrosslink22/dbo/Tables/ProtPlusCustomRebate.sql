CREATE TABLE [dbo].[ProtPlusCustomRebate] (
    [rowID]      INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [account]    VARCHAR (8) NOT NULL,
    [RebateRate] MONEY       NULL,
    CONSTRAINT [PK__ProtPlusCustomRebate] PRIMARY KEY CLUSTERED ([rowID] ASC)
);

