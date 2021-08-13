CREATE TABLE [dbo].[efinsend] (
    [req_num]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [efin]      INT           NOT NULL,
    [userid]    INT           NOT NULL,
    [data]      VARCHAR (MAX) NULL,
    [queued]    DATETIME      NULL,
    [delivered] DATETIME      NULL,
    CONSTRAINT [PK_efinsend] PRIMARY KEY CLUSTERED ([req_num] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [efin_user_date]
    ON [dbo].[efinsend]([efin] ASC, [userid] ASC, [queued] ASC);

