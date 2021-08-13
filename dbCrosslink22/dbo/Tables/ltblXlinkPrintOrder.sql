CREATE TABLE [dbo].[ltblXlinkPrintOrder] (
    [XMLTag]   VARCHAR (10) NOT NULL,
    [PageName] VARCHAR (50) NOT NULL,
    [PageType] VARCHAR (3)  NOT NULL,
    CONSTRAINT [PK_ltblXlinkPrintOrder] PRIMARY KEY CLUSTERED ([XMLTag] ASC)
);

