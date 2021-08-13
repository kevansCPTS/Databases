CREATE TABLE [dbo].[tblCorpmast] (
    [primid]            CHAR (9)      NOT NULL,
    [stateid]           CHAR (2)      NOT NULL,
    [subType]           CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [corp]              TINYINT       NULL,
    [userid]            INT           NULL,
    [userspec]          INT           NULL,
    [seqno]             SMALLINT      NULL,
    [archive_no]        INT           NULL,
    [sb_id]             INT           NULL,
    [sb_spec]           INT           NULL,
    [fran_id]           INT           NULL,
    [fran_spec]         INT           NULL,
    [efin]              INT           NULL,
    [site_id]           CHAR (7)      NULL,
    [prim_ctrl]         CHAR (4)      NULL,
    [pri_fname]         CHAR (50)     NULL,
    [pri_bname]         CHAR (50)     NULL,
    [address]           CHAR (35)     NULL,
    [city]              CHAR (22)     NULL,
    [state]             CHAR (2)      NULL,
    [zip]               CHAR (12)     NULL,
    [contact_fname]     CHAR (20)     NULL,
    [contact_lname]     CHAR (20)     NULL,
    [contact_phone]     CHAR (10)     NULL,
    [email_address]     NCHAR (255)   NULL,
    [site_rej]          CHAR (1)      NULL,
    [stat_cnt]          SMALLINT      NULL,
    [old_stat]          CHAR (1)      NULL,
    [ret_stat]          CHAR (1)      NULL,
    [txn_code]          CHAR (1)      NULL,
    [fdate]             DATETIME      NULL,
    [ldate]             DATETIME      NULL,
    [postmark]          CHAR (25)     NULL,
    [submissionid]      CHAR (20)     NULL,
    [irs_ack_dt]        DATE          NULL,
    [irs_acc_cd]        CHAR (1)      NULL,
    [rej_cnt]           SMALLINT      NULL,
    [irs_refund]        INT           NULL,
    [verify_level]      SMALLINT      NULL,
    [prep_id]           CHAR (8)      NULL,
    [user_dcnx]         VARCHAR (12)  NULL,
    [xmit_date]         DATETIME      NULL,
    [xmit_arcv_no]      INT           NULL,
    [xmit_refund]       INT           NULL,
    [irs_pin_ind]       CHAR (1)      NULL,
    [irs_payment_ind]   CHAR (1)      NULL,
    [guid]              CHAR (32)     NULL,
    [rsrvd_ip_addr]     CHAR (1)      NULL,
    [pref_contact]      CHAR (1)      NULL,
    [time_stamp]        CHAR (19)     NULL,
    [mef_errcnt]        INT           NULL,
    [schema_version]    VARCHAR (50)  NULL,
    [ip_address]        CHAR (15)     NULL,
    [fedcopy]           TINYINT       NULL,
    [refund]            BIGINT        NULL,
    [bal_due]           BIGINT        NULL,
    [tot_inc]           BIGINT        NULL,
    [formus99]          CHAR (6)      NULL,
    [state_submit_type] CHAR (25)     NULL,
    [tax_begin]         DATE          NULL,
    [tax_end]           DATE          NULL,
    [schemaloadver]     CHAR (20)     NULL,
    [recTS]             DATETIME2 (0) NULL,
    [goveCode]          CHAR (4)      NULL,
    [taxyear]           CHAR (4)      NULL,
    [port_num]          VARCHAR (5)   NULL,
    [ptin]              CHAR (9)      NULL,
    [online_type]       CHAR (1)      NULL,
    CONSTRAINT [PK_tblCorpmast] PRIMARY KEY CLUSTERED ([primid] ASC, [stateid] ASC, [subType] ASC)
);


GO

CREATE TRIGGER [dbo].[trg_tblcorpMast_ChangeOccurred]
   ON  [dbo].[tblCorpMast]
   AFTER
	INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    --insert change tracking row
	insert into tblFetchSvcBusRtnStatus
	select primid, StateID, SubType, UserID, GETDATE() from inserted

END
