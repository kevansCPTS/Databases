CREATE TABLE [dbo].[admin2] (
    [req_num]   INT       IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [delivered] CHAR (1)  CONSTRAINT [DF_admin2_delivered] DEFAULT (' ') NOT NULL,
    [req_type]  CHAR (1)  NOT NULL,
    [param]     CHAR (10) NOT NULL,
    [ssn]       INT       NOT NULL,
    [dt]        DATETIME  CONSTRAINT [DF_admin2_dt] DEFAULT (getdate()) NOT NULL,
    [requestor] CHAR (10) NOT NULL,
    CONSTRAINT [PK_admin2] PRIMARY KEY NONCLUSTERED ([req_num] ASC)
);


GO
CREATE CLUSTERED INDEX [_dta_index_admin2_c_28_86291367__K1]
    ON [dbo].[admin2]([req_num] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [delivered2]
    ON [dbo].[admin2]([delivered] ASC, [req_num] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_admin2_req_type_param_ssn_dt]
    ON [dbo].[admin2]([req_type] ASC, [param] ASC, [ssn] ASC)
    INCLUDE([dt]);


GO
CREATE NONCLUSTERED INDEX [IX_admin2_req_type_ssn]
    ON [dbo].[admin2]([req_type] ASC, [ssn] ASC);

