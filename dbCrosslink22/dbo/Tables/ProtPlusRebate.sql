CREATE TABLE [dbo].[ProtPlusRebate] (
    [rowID]        INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [account]      VARCHAR (8) NOT NULL,
    [RebateAmount] MONEY       NULL,
    [RebateCount]  INT         NULL,
    [UpdateDate]   DATETIME    CONSTRAINT [DF_ProtPlusRebate_UpdatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__ProtPlusRebate] PRIMARY KEY CLUSTERED ([rowID] ASC)
);

