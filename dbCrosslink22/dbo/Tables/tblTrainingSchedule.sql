CREATE TABLE [dbo].[tblTrainingSchedule] (
    [id]        INT          NOT NULL,
    [startdate] DATETIME     NULL,
    [printdate] VARCHAR (20) NULL,
    [printtime] VARCHAR (14) NULL,
    [location]  VARCHAR (30) NULL,
    CONSTRAINT [PK_tblTrainingSchedule] PRIMARY KEY CLUSTERED ([id] ASC)
);

