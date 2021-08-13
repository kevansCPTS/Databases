CREATE TABLE [dbo].[tblProgramHold] (
    [account]    VARCHAR (8)   NOT NULL,
    [userId]     INT           CONSTRAINT [DF_tblProgramHold_userId] DEFAULT ((0)) NOT NULL,
    [efin]       INT           CONSTRAINT [DF_tblProgramHold_efin] DEFAULT ((0)) NOT NULL,
    [programTag] VARCHAR (4)   NOT NULL,
    [holdStat]   BIT           NULL,
    [createDate] DATETIME2 (7) NULL,
    [updateDate] DATETIME2 (7) NULL,
    CONSTRAINT [PK_tblProgramHold] PRIMARY KEY CLUSTERED ([account] ASC, [userId] ASC, [efin] ASC)
);

