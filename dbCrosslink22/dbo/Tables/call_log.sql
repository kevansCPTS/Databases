CREATE TABLE [dbo].[call_log] (
    [seq_no]   INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [user_id]  INT         NULL,
    [stat]     VARCHAR (1) NULL,
    [dt_mm]    VARCHAR (2) NULL,
    [dt_dd]    VARCHAR (2) NULL,
    [dt_hh]    VARCHAR (2) NULL,
    [dt_mi]    VARCHAR (2) NULL,
    [ver]      VARCHAR (6) NULL,
    [baud]     VARCHAR (1) NULL,
    [password] VARCHAR (8) NULL,
    [ser]      VARCHAR (8) NULL,
    [cps]      SMALLINT    NULL,
    [snt]      SMALLINT    NULL,
    [rcvd]     SMALLINT    NULL,
    [mgmt]     INT         NULL,
    [port_num] VARCHAR (2) NULL,
    [filler]   VARCHAR (4) NULL,
    CONSTRAINT [PK__call_log__7A672E12] PRIMARY KEY NONCLUSTERED ([seq_no] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_call_log]
    ON [dbo].[call_log]([user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [cl_uix]
    ON [dbo].[call_log]([user_id] ASC, [stat] ASC);


GO
CREATE NONCLUSTERED INDEX [cl_uix2]
    ON [dbo].[call_log]([stat] ASC);

