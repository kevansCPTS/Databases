CREATE TABLE [dbo].[tblUpcomingEvents] (
    [id]         INT          NOT NULL,
    [title]      VARCHAR (30) NOT NULL,
    [startdate]  DATETIME     NOT NULL,
    [expiredate] DATETIME     NOT NULL,
    [location]   VARCHAR (30) NOT NULL,
    [hotel]      VARCHAR (30) NOT NULL,
    [printdate]  VARCHAR (30) NOT NULL,
    [printtime]  VARCHAR (15) NOT NULL,
    CONSTRAINT [PK_tblUpcomingEvents] PRIMARY KEY CLUSTERED ([id] ASC)
);

