CREATE TABLE [dbo].[tblProgramGroup] (
    [groupId]         INT           NOT NULL,
    [Name]            VARCHAR (255) NULL,
    [exclusiveSelect] BIT           CONSTRAINT [DF_tblProgramGroup_exclusiveSelect] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblProgramGroup] PRIMARY KEY CLUSTERED ([groupId] ASC)
);

