CREATE TABLE [dbo].[rejdescr] (
    [reject] VARCHAR (6)   NOT NULL,
    [descr]  VARCHAR (500) NOT NULL,
    CONSTRAINT [PK__rejdescr] PRIMARY KEY CLUSTERED ([reject] ASC)
);

