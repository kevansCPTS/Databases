CREATE TABLE [dbo].[ltblWorldAccEFINBranch] (
    [efin]   INT           NOT NULL,
    [branch] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_ltblWorldAccEFINBranch] PRIMARY KEY CLUSTERED ([efin] ASC, [branch] ASC)
);

