CREATE TABLE [dbo].[tblTaxmast] (
    [pssn]                INT           NOT NULL,
    [stateid]             CHAR (2)      NULL,
    [subtype]             CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [user_id]             INT           NULL,
    [user_spec]           INT           NULL,
    [archive_no]          INT           NULL,
    [sb_id]               INT           NULL,
    [sb_spec]             INT           NULL,
    [fran_id]             INT           NULL,
    [fran_spec]           INT           NULL,
    [efin]                INT           NULL,
    [master]              INT           NULL,
    [site_id]             CHAR (7)      NULL,
    [prim_ctrl]           CHAR (4)      NULL,
    [pri_fname]           CHAR (16)     NULL,
    [pri_init]            CHAR (1)      NULL,
    [pri_lname]           CHAR (32)     NULL,
    [sec_ssn]             INT           NULL,
    [sec_ctrl]            CHAR (4)      NULL,
    [sec_fname]           CHAR (16)     NULL,
    [sec_init]            CHAR (1)      NULL,
    [sec_lname]           CHAR (32)     NULL,
    [address]             CHAR (35)     NULL,
    [city]                CHAR (22)     NULL,
    [state]               CHAR (2)      NULL,
    [zip]                 CHAR (12)     NULL,
    [ral_flag]            CHAR (1)      NULL,
    [refund]              INT           NULL,
    [bal_due]             INT           NULL,
    [tot_income]          INT           NULL,
    [tot_tax]             INT           NULL,
    [tot_itw]             INT           NULL,
    [tot_agi]             INT           NULL,
    [tot_eic]             SMALLINT      NULL,
    [tot_dep]             SMALLINT      NULL,
    [site_rej]            CHAR (1)      NULL,
    [stat_cnt]            CHAR (2)      NULL,
    [old_stat]            CHAR (1)      NULL,
    [ret_stat]            CHAR (1)      NULL,
    [txn_code]            CHAR (1)      NULL,
    [log_code]            CHAR (1)      NULL,
    [fdate]               DATETIME      NULL,
    [ldate]               DATETIME      NULL,
    [postmark]            CHAR (25)     NULL,
    [submissionid]        CHAR (20)     NULL,
    [irs_ack_dt]          DATE          NULL,
    [irs_acc_cd]          CHAR (1)      NULL,
    [irs_eft_ind]         CHAR (1)      NULL,
    [irs_dup_code]        CHAR (3)      NULL,
    [rej_cnt]             SMALLINT      NULL,
    [irs_refund]          INT           NULL,
    [bank_id]             CHAR (1)      NULL,
    [sub_date]            DATE          NULL,
    [resp_date]           DATE          NULL,
    [bank_stat]           CHAR (1)      NULL,
    [decline_code]        INT           NULL,
    [pei_tran_fee]        INT           NULL,
    [ero_tran_fee]        INT           NULL,
    [sb_prep_fee]         INT           NULL,
    [tax_prep_fee]        INT           NULL,
    [ero_bank_fee]        INT           NULL,
    [req_bank_fee]        INT           NULL,
    [req_acnt_fee]        INT           NULL,
    [pei_prot_fee]        INT           NULL,
    [ero_prot_fee]        INT           NULL,
    [req_tech_fee]        INT           NULL,
    [req_loan_amt]        INT           NULL,
    [verify_level]        SMALLINT      NULL,
    [filing_stat]         CHAR (1)      NULL,
    [prep_ind]            CHAR (1)      NULL,
    [prep_id]             CHAR (8)      NULL,
    [cross_collect_ind]   CHAR (1)      NULL,
    [ero_state]           CHAR (2)      NULL,
    [tot_bank_fee]        INT           NULL,
    [tot_acnt_fee]        INT           NULL,
    [tot_prep_fee]        INT           NULL,
    [ebnk_pay_date]       DATE          NULL,
    [ebnk_pay_amt]        INT           NULL,
    [tot_tran_fee]        INT           NULL,
    [tot_sb_fee]          INT           NULL,
    [tot_pprot_fee]       INT           NULL,
    [tot_eprot_fee]       INT           NULL,
    [tot_tech_fee]        INT           NULL,
    [tot_ebank_fee]       INT           NULL,
    [tot_prior_yr_amt]    INT           NULL,
    [fee_pay_date]        DATE          NULL,
    [fee_pay_amt]         INT           NULL,
    [tran_pay_date]       DATE          NULL,
    [tran_pay_amt]        INT           NULL,
    [tran_add_date]       DATE          NULL,
    [tran_add_amt]        INT           NULL,
    [sb_pay_date]         DATE          NULL,
    [sb_pay_amt]          INT           NULL,
    [irs_pay_date]        DATE          NULL,
    [irs_pay_amt]         INT           NULL,
    [sta_pay_date1]       DATE          NULL,
    [sta_pay_amt1]        INT           NULL,
    [sta_pay_date2]       DATE          NULL,
    [sta_pay_amt2]        INT           NULL,
    [sta_pay_date3]       DATE          NULL,
    [sta_pay_amt3]        INT           NULL,
    [otc_pay_date]        DATE          NULL,
    [otc_pay_amt]         INT           NULL,
    [cancel_date]         DATE          NULL,
    [user_dcnx]           CHAR (12)     NULL,
    [xmit_date]           DATETIME      NULL,
    [xmit_arcv_no]        INT           NULL,
    [xmit_refund]         INT           NULL,
    [irs_debt_ind]        CHAR (1)      NULL,
    [irs_dob_errs]        CHAR (1)      NULL,
    [toss_ackl]           CHAR (1)      NULL,
    [irs_pin_ind]         CHAR (1)      NULL,
    [irs_payment_ind]     CHAR (1)      NULL,
    [guid]                CHAR (32)     NULL,
    [rsrvd_ip_addr]       CHAR (1)      NULL,
    [irs_8453OL]          CHAR (1)      NULL,
    [ws_lock]             CHAR (1)      NULL,
    [time_stamp]          CHAR (19)     NULL,
    [roll]                CHAR (1)      NULL,
    [cust_id_sha1]        CHAR (40)     NULL,
    [adv_cmpid]           INT           NULL,
    [adv_locid]           INT           NULL,
    [adv_dstid]           INT           NULL,
    [bnk_prim_id]         INT           NULL,
    [bnk_sec_id]          INT           NULL,
    [bnk_appid]           INT           NULL,
    [mef_errcnt]          CHAR (4)      NULL,
    [ptin]                CHAR (9)      NULL,
    [roll_fee_pay_amt]    INT           NULL,
    [roll_tran_pay_amt]   INT           NULL,
    [roll_sb_pay_amt]     INT           NULL,
    [schema_version]      CHAR (50)     NULL,
    [ip_address]          CHAR (15)     NULL,
    [disb_type]           CHAR (1)      NULL,
    [fld_8379_ind]        CHAR (1)      NULL,
    [fetchSeq]            CHAR (4)      NULL,
    [advnt_email_discl]   CHAR (1)      NULL,
    [tot_rush_fee]        INT           NULL,
    [tot_phone_fee]       INT           NULL,
    [tot_prev_paid_amt]   INT           NULL,
    [split_disb_amt]      INT           NULL,
    [rtn_id]              INT           NULL,
    [login_id]            INT           NULL,
    [home_phone]          CHAR (10)     NULL,
    [work_phone]          CHAR (10)     NULL,
    [email_address]       CHAR (44)     NULL,
    [sec_email]           CHAR (44)     NULL,
    [FORM_TYPE_1040]      CHAR (1)      NULL,
    [req_cadr_fee]        INT           NULL,
    [req_phone_fee]       INT           NULL,
    [alert_count]         TINYINT       NULL,
    [prot_pay_date]       DATE          NULL,
    [prot_pay_amt]        INT           NULL,
    [cadr_pay_date]       DATE          NULL,
    [cadr_pay_amt]        INT           NULL,
    [elf_prep_fee]        INT           NULL,
    [tot_cadr_fee]        INT           NULL,
    [gender]              CHAR (1)      NULL,
    [recTS]               DATETIME2 (0) NULL,
    [isProtPlus]          AS            (case when [pei_prot_fee]>(0) then (1) else (0) end) PERSISTED NOT NULL,
    [isProtPlusFunded]    AS            (case when [pei_prot_fee]>(0) AND [prot_pay_amt]>=[pei_prot_fee] then (1) else (0) end) PERSISTED NOT NULL,
    [isCadr]              AS            (case when [req_cadr_fee]>(0) then (1) else (0) end) PERSISTED NOT NULL,
    [isCadrFunded]        AS            (case when [req_cadr_fee]>(0) AND [cadr_pay_amt]>=[req_cadr_fee] then (1) else (0) end) PERSISTED NOT NULL,
    [mefHold]             CHAR (1)      NULL,
    [rac_pay_amt]         INT           NULL,
    [rac_pay_date]        DATE          NULL,
    [srac_pay_amt]        INT           NULL,
    [srac_pay_date]       DATE          NULL,
    [LastUpdate]          DATETIME      CONSTRAINT [DF_tblTaxMast_LastUpdate] DEFAULT (getdate()) NULL,
    [req_utip_fee]        INT           NULL,
    [tot_utip_fee]        INT           NULL,
    [utip_pay_date]       DATE          NULL,
    [utip_pay_amt]        INT           NULL,
    [req_mmac_fee]        INT           NULL,
    [tot_mmac_fee]        INT           NULL,
    [mmac_pay_date]       DATE          NULL,
    [mmac_pay_amt]        INT           NULL,
    [req_mmip_fee]        INT           NULL,
    [tot_mmip_fee]        INT           NULL,
    [mmip_pay_date]       DATE          NULL,
    [mmip_pay_amt]        INT           NULL,
    [doc_prep_fee]        INT           NULL,
    [tot_doc_fee]         INT           NULL,
    [doc_pay_date]        DATE          NULL,
    [doc_pay_amt]         INT           NULL,
    [tot_elf_fee]         INT           NULL,
    [elf_pay_date]        DATE          NULL,
    [elf_pay_amt]         INT           NULL,
    [phone_pay_date]      DATE          NULL,
    [phone_pay_amt]       INT           NULL,
    [isBankProd]          AS            (case when [ral_flag]=(5) then (1) else (0) end) PERSISTED NOT NULL,
    [isBankProdFunded]    AS            (case when [ral_flag]=(5) AND ((([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee])>(0) OR [fee_pay_amt]>(0)) AND [tran_pay_amt]>=(([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee]) then (1) else (0) end) PERSISTED NOT NULL,
    [FirstSubId]          CHAR (20)     NULL,
    [FirstRespDt]         DATETIME      NULL,
    [TpText]              CHAR (1)      NULL,
    [SpText]              CHAR (1)      NULL,
    [wheresFlag]          CHAR (1)      NULL,
    [designeePin]         INT           NULL,
    [FLD1272]             INT           NULL,
    [FLD1274]             CHAR (1)      NULL,
    [FLD1276]             CHAR (1)      NULL,
    [FLD1278]             CHAR (17)     NULL,
    [TaxpayerAgreeDate]   DATE          NULL,
    [SpouseAgreeDate]     DATE          NULL,
    [TaxpayeriProtectID]  VARCHAR (9)   NULL,
    [SpouseiProtectID]    VARCHAR (9)   NULL,
    [StateRTFlag]         CHAR (1)      NULL,
    [ModifiedDate]        DATETIME2 (7) CONSTRAINT [DF_tblTaxmast_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedDate]         DATETIME2 (7) CONSTRAINT [DF_tblTaxmast_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [parentAccount]       VARCHAR (8)   NULL,
    [port_num]            VARCHAR (5)   NULL,
    [fullyFundedDate]     AS            (case when [ral_flag]=(5) AND ((([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee])>(0) OR [fee_pay_amt]>(0)) AND [tran_pay_amt]>=(([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee]) then isnull([tran_pay_date],[fee_pay_date])  end) PERSISTED,
    [RowVer]              ROWVERSION    NOT NULL,
    [nRowVer]             AS            (CONVERT([bigint],[RowVer],0)) PERSISTED,
    [net_tran_fee]        INT           NULL,
    [preack_stat]         CHAR (1)      NULL,
    [fst_prim_ssn]        INT           NULL,
    [fst_sec_ssn]         INT           NULL,
    [ral_apr]             INT           NULL,
    [ral_finance_chrg]    INT           NULL,
    [preack_amt]          INT           NULL,
    [loan_amt]            INT           NULL,
    [finance_amt]         INT           NULL,
    [finance_chrg]        INT           NULL,
    [finance_apr]         INT           NULL,
    [admin_tran_fee]      INT           NULL,
    [cpts_ef_fee]         INT           NULL,
    [ero_ef_fee]          INT           NULL,
    [admin_ef_fee]        INT           NULL,
    [adv_date]            DATE          NULL,
    [adv_stat]            CHAR (1)      NULL,
    [adv_code]            INT           NULL,
    [padv_date]           DATE          NULL,
    [padv_stat]           CHAR (1)      NULL,
    [padv_code]           INT           NULL,
    [isFullyFunded]       AS            (case when [ral_flag]=(5) AND (([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee])>(0) AND [tran_pay_amt]>=((([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee])+[ero_ef_fee]) then (1) when [ral_flag]<>(5) AND [tran_pay_amt]>(0) AND [tran_pay_amt]>=(((([req_tech_fee]+[pei_tran_fee])+[ero_tran_fee])+[ero_ef_fee])+[admin_ef_fee]) then (1) else (0) end) PERSISTED NOT NULL,
    [account]             VARCHAR (8)   NULL,
    [cpts_admin_fee]      INT           NULL,
    [effee_allProd]       BIT           CONSTRAINT [DF_tblTaxmast_effee_allProd] DEFAULT ((0)) NULL,
    [cpts_admin_tech_fee] INT           NULL,
    [sbFee_allProd]       BIT           CONSTRAINT [DF_tblTaxmast_sbFee_allProd] DEFAULT ((0)) NULL,
    [techFee_allProd]     BIT           CONSTRAINT [DF_tblTaxmast_techFee_allProd] DEFAULT ((0)) NULL,
    [ero_tech_fee]        INT           NULL,
    CONSTRAINT [PK_taxmast_test] PRIMARY KEY CLUSTERED ([pssn] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblTaxmast]
    ON [dbo].[tblTaxmast]([submissionid] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_tblTaxmast_user_id]
    ON [dbo].[tblTaxmast]([user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [ID2_tblTaxmast]
    ON [dbo].[tblTaxmast]([ret_stat] ASC);


GO
CREATE NONCLUSTERED INDEX [ID3_tblTaxmast]
    ON [dbo].[tblTaxmast]([pri_lname] ASC);


GO
CREATE NONCLUSTERED INDEX [ID4_tblTaxmast]
    ON [dbo].[tblTaxmast]([ldate] ASC);


GO
CREATE NONCLUSTERED INDEX [ID5_tblTaxmast]
    ON [dbo].[tblTaxmast]([irs_acc_cd] ASC);


GO
CREATE NONCLUSTERED INDEX [ID6_tblTaxmast]
    ON [dbo].[tblTaxmast]([user_id] ASC)
    INCLUDE([pssn], [irs_acc_cd], [filing_stat]);


GO
CREATE NONCLUSTERED INDEX [ID7_tblTaxmast]
    ON [dbo].[tblTaxmast]([sec_ssn] ASC);


GO
CREATE NONCLUSTERED INDEX [ID8_tblTaxmast]
    ON [dbo].[tblTaxmast]([isCadr] ASC)
    INCLUDE([user_id], [efin]);


GO
CREATE NONCLUSTERED INDEX [ID9_tblTaxmast]
    ON [dbo].[tblTaxmast]([LastUpdate] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_rtn_id]
    ON [dbo].[tblTaxmast]([rtn_id] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_summary]
    ON [dbo].[tblTaxmast]([pssn] ASC, [user_id] ASC)
    INCLUDE([irs_acc_cd], [ral_flag]);


GO
CREATE NONCLUSTERED INDEX [IX1_tblTaxmast_EFIN]
    ON [dbo].[tblTaxmast]([efin] ASC);


GO
CREATE NONCLUSTERED INDEX [ID10_tblTaxmast]
    ON [dbo].[tblTaxmast]([bank_stat] ASC)
    INCLUDE([pssn], [user_id], [efin], [ral_flag], [ldate], [submissionid], [irs_ack_dt], [irs_pay_amt], [otc_pay_amt]);


GO
CREATE NONCLUSTERED INDEX [IX_tblTaxmast_nRowVer]
    ON [dbo].[tblTaxmast]([nRowVer] DESC)
    INCLUDE([pssn]);


GO


CREATE TRIGGER [dbo].[tgrTaxmast_parentAccount] 
   ON  [dbo].[tblTaxmast] 
   AFTER INSERT
AS 
    begin
        
        declare @season smallint

        set nocount on	

        set @season = '20' + right(db_name(),2)

        update tm
            set tm.account = u.account 
        ,   tm.parentAccount = ch.parentAccount
        from 
            dbo.tblTaxmast tm join inserted i on tm.pssn = i.pssn
            join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
            left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on u.account = ch.childAccount
                and ch.season = @season

    end;

GO
/****** Object:  Trigger [dbo].[tgrWebserviceDiff_Taxmast]    Script Date: 11/21/2013 7:29:22 AM ******/

-- =============================================
-- Author:		Josh Daniel/Charles Krebs
-- Create date: 1/26/2012
-- Description:	Trigger to update WebServiceDiff table table whenever a change
--				has been made
-- =============================================
CREATE TRIGGER [dbo].[tgrWebserviceDiff_Taxmast] 
   ON  [dbo].[tblTaxmast] 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @stamp datetime
    
    Set @stamp = getDate();
    
		
		
	update a set a.atomDelivered=0,a.irsstatusdelivered=0, a.timestamp=@stamp
		from WebserviceDiff a inner join inserted b on a.pssn=b.pssn where b.pssn is not null

		if(@@ROWCOUNT = 0)
		begin

			insert into WebserviceDiff (pssn,timestamp) 
				select pssn, @stamp from inserted where pssn is not null
    
		end

END




GO



CREATE trigger [dbo].[trg_tblTaxmast_paytransaction]
on 
    [dbo].[tblTaxmast]
for
    update, insert
  
as

    set nocount on 

    insert [dbo].[tblPayTransaction](
        pssn    
    ,   bankId
    ,   feeType
    ,   payAmount
    ,   payDate
    )
        select
            i.pssn
        ,   i.bank_id
        ,   1
        ,   (i.fee_pay_amt - isnull(d.fee_pay_amt,0)) / 100.00
        ,   isnull(i.fee_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.fee_pay_amt,0) > isnull(d.fee_pay_amt,0)

        union select
            i.pssn
        ,   i.bank_id
        ,   2
        ,   (i.tran_pay_amt - isnull(d.tran_pay_amt,0)) / 100.00
        ,   isnull(i.tran_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.tran_pay_amt,0) > isnull(d.tran_pay_amt,0)

        union select
            i.pssn
        ,   i.bank_id
        ,   3
        ,   (i.sb_pay_amt - isnull(d.sb_pay_amt,0)) / 100.00
        ,   isnull(i.sb_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.sb_pay_amt,0) > isnull(d.sb_pay_amt,0)

        union select
            i.pssn
        ,   i.bank_id
        ,   4
        ,   (i.prot_pay_amt - isnull(d.prot_pay_amt,0)) / 100.00
        ,   isnull(i.prot_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.prot_pay_amt,0) > isnull(d.prot_pay_amt,0)
 
        union select
            i.pssn
        ,   i.bank_id
        ,   5
        ,   (i.cadr_pay_amt - isnull(d.cadr_pay_amt,0))  / 100.00
        ,   isnull(i.cadr_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.cadr_pay_amt,0) > isnull(d.cadr_pay_amt,0)
  
        union select
            i.pssn
        ,   i.bank_id
        ,   6
        ,   (i.rac_pay_amt - isnull(d.rac_pay_amt,0))  / 100.00
        ,   isnull(i.rac_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.rac_pay_amt,0) > isnull(d.rac_pay_amt,0)

        union select
            i.pssn
        ,   i.bank_id
        ,   7
        ,   (i.srac_pay_amt - isnull(d.srac_pay_amt,0))  / 100.00
        ,   isnull(i.srac_pay_date,getdate())
        from
            inserted i left join deleted d on i.pssn = d.pssn
        where
            isnull(i.srac_pay_amt,0) > isnull(d.srac_pay_amt,0)


GO
CREATE trigger [dbo].[trg_tblTaxMast_ChangeOccurred]
on 
    [dbo].[tblTaxMast]
after
    insert, update
as
	if @@rowcount = 0
		return

	set nocount on

	--insert change tracking row
	insert into tblFetchSvcRtnStatus
	select pssn, filing_stat, [user_id], GETDATE(), 0 from inserted

	--update ModifiedDate, LastUpdate on original table
	update tm       
        set tm.ModifiedDate = getdate(),
            tm.LastUpdate = getdate()
    from
        dbo.tblTaxMast tm join inserted i on tm.pssn = i.pssn