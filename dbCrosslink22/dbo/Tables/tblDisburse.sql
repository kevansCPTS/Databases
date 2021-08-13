CREATE TABLE [dbo].[tblDisburse] (
    [pssn]            INT       NOT NULL,
    [cur_chk]         CHAR (2)  NOT NULL,
    [chk_type]        CHAR (1)  NULL,
    [chk_date]        CHAR (8)  NULL,
    [chk_amt]         INT       NULL,
    [chk_num]         INT       NULL,
    [disb_num]        BIGINT    NULL,
    [verify_id]       CHAR (10) NULL,
    [prev_chk_num]    INT       NULL,
    [reissue_stat]    CHAR (1)  NULL,
    [reissue_date]    CHAR (4)  NULL,
    [clr_date]        CHAR (4)  NULL,
    [auth_date]       CHAR (4)  NULL,
    [dep_amt]         INT       NULL,
    [dep_type]        CHAR (1)  NULL,
    [bank_fee]        INT       NULL,
    [acnt_fee]        INT       NULL,
    [prep_fee]        INT       NULL,
    [elf_fee]         INT       NULL,
    [dep_amt_st]      INT       NULL,
    [tran_fee]        INT       NULL,
    [sb_fee]          INT       NULL,
    [pprot_fee]       INT       NULL,
    [eprot_fee]       INT       NULL,
    [tech_fee]        INT       NULL,
    [prior_yr_amt]    INT       NULL,
    [prior_yr_reason] CHAR (40) NULL,
    [prim_name]       CHAR (35) NULL,
    [sec_name]        CHAR (35) NULL,
    [filler]          CHAR (32) NULL,
    [void_date]       CHAR (4)  NULL,
    [rush_fee]        INT       NULL,
    [phone_fee]       INT       NULL,
    [prev_paid_amt]   INT       NULL,
    [chk_loc_id]      CHAR (10) NULL,
    [cadr_fee]        INT       NULL,
    [ebnk_fee]        INT       NULL,
    [doc_fee]         INT       NULL,
    [utip_fee]        INT       NULL,
    [mmip_fee]        INT       NULL,
    [mmac_fee]        INT       NULL,
    [disb_type]       CHAR (1)  NULL,
    [loan_amt]        INT       NULL,
    [finance_chrg]    INT       NULL,
    [financed_amt]    INT       NULL,
    [loan_apr]        INT       NULL,
    [aprod_tag1]      CHAR (3)  NULL,
    [aprod_banktag1]  CHAR (16) NULL,
    [aprod_name1]     CHAR (32) NULL,
    [aprod_fee1]      INT       NULL,
    [aprod_tag2]      CHAR (3)  NULL,
    [aprod_banktag2]  CHAR (16) NULL,
    [aprod_name2]     CHAR (32) NULL,
    [aprod_fee2]      INT       NULL,
    [aprod_tag3]      CHAR (3)  NULL,
    [aprod_banktag3]  CHAR (16) NULL,
    [aprod_name3]     CHAR (32) NULL,
    [aprod_fee3]      INT       NULL,
    [aprod_tag4]      CHAR (3)  NULL,
    [aprod_banktag4]  CHAR (16) NULL,
    [aprod_name4]     CHAR (32) NULL,
    [aprod_fee4]      INT       NULL,
    CONSTRAINT [PK_Disburse] PRIMARY KEY NONCLUSTERED ([pssn] ASC, [cur_chk] ASC)
);


GO


-- =============================================
-- Author:		Josh Daniel/Charles Krebs
-- Create date: 1/26/2012
-- Description:	Trigger to update WebServiceDiff table table whenever a change
--				has been made
-- =============================================
CREATE TRIGGER [dbo].[tgrWebserviceDiff_Disburse] 
   ON  [dbo].[tblDisburse] 
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



