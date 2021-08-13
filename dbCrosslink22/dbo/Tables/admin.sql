CREATE TABLE [dbo].[admin] (
    [req_num]   INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [delivered] CHAR (1)     CONSTRAINT [DF_admin_delivered] DEFAULT (' ') NOT NULL,
    [req_type]  VARCHAR (2)  NOT NULL,
    [param]     VARCHAR (64) NOT NULL,
    [ssn]       INT          NOT NULL,
    [dt]        DATETIME     CONSTRAINT [DF_admin_dt] DEFAULT (getdate()) NOT NULL,
    [requestor] CHAR (20)    NOT NULL,
    CONSTRAINT [PK_admin] PRIMARY KEY NONCLUSTERED ([req_num] ASC)
);


GO
CREATE CLUSTERED INDEX [_dta_index_admin_c_28_86291367__K1]
    ON [dbo].[admin]([req_num] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [delivered]
    ON [dbo].[admin]([delivered] ASC, [req_num] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_admin]
    ON [dbo].[admin]([req_type] ASC)
    INCLUDE([req_num], [param], [ssn]);


GO
CREATE NONCLUSTERED INDEX [ID2_admin]
    ON [dbo].[admin]([req_type] ASC, [ssn] ASC);

