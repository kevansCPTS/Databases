CREATE TABLE [dbo].[day_msg] (
    [rowID]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [location]   VARCHAR (7)  NULL,
    [filler1]    VARCHAR (2)  NULL,
    [datetime]   VARCHAR (11) NULL,
    [filler2]    VARCHAR (2)  NULL,
    [user_id]    INT          NULL,
    [filler3]    VARCHAR (2)  NULL,
    [efin]       VARCHAR (6)  NULL,
    [filler4]    VARCHAR (1)  NULL,
    [dcn]        VARCHAR (5)  NULL,
    [filler5]    VARCHAR (2)  NULL,
    [pssn]       VARCHAR (11) NULL,
    [filler6]    VARCHAR (2)  NULL,
    [stat1]      VARCHAR (10) NULL,
    [stat2]      VARCHAR (9)  NULL,
    [filler7]    VARCHAR (1)  NULL,
    [TypeId]     CHAR (1)     NULL,
    [PrimId]     INT          NULL,
    [FilingType] CHAR (1)     NULL,
    [StateId]    CHAR (2)     NULL,
    [RecSubType] CHAR (2)     NULL,
    [MsgField]   VARCHAR (20) NULL,
    [ModName]    VARCHAR (7)  NULL,
    CONSTRAINT [PK__day_msg__7F2BE32F] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [dm_idx]
    ON [dbo].[day_msg]([user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_day_msg]
    ON [dbo].[day_msg]([pssn] ASC);

