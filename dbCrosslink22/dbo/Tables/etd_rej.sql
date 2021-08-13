CREATE TABLE [dbo].[etd_rej] (
    [rowID]          INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]           INT         NULL,
    [tran_key]       VARCHAR (1) NULL,
    [tran_seq]       INT         NULL,
    [error_num]      SMALLINT    NULL,
    [form_seq]       VARCHAR (4) NULL,
    [field_seq]      VARCHAR (4) NULL,
    [rej_code]       VARCHAR (4) NULL,
    [state_id]       CHAR (2)    NULL,
    [state_id2]      CHAR (2)    NULL,
    [user_id]        CHAR (6)    NULL,
    [user_dcnx]      CHAR (12)   NULL,
    [rtn_id]         CHAR (9)    NULL,
    [irs_state_only] CHAR (2)    NULL,
    [pkg_id]         CHAR (2)    NULL,
    CONSTRAINT [PK__etd_rej__22751F6C] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_etdr_bs]
    ON [dbo].[etd_rej]([pssn] ASC, [tran_key] ASC, [tran_seq] ASC, [error_num] ASC);

