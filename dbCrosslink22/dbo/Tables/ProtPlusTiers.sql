CREATE TABLE [dbo].[ProtPlusTiers] (
    [tierID]     INT   NOT NULL,
    [MinVolume]  INT   NOT NULL,
    [MaxVolume]  INT   NULL,
    [RebateRate] MONEY NOT NULL,
    CONSTRAINT [PK_ProtPlusTiers] PRIMARY KEY CLUSTERED ([tierID] ASC)
);

