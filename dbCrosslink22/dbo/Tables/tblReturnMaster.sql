CREATE TABLE [dbo].[tblReturnMaster] (
    [PrimarySSN]             INT           NOT NULL,
    [FilingStatus]           TINYINT       NOT NULL,
    [UserID]                 INT           NOT NULL,
    [SenderID]               INT           NULL,
    [PrimaryFirstName]       VARCHAR (255) NULL,
    [PrimaryLastName]        VARCHAR (255) NULL,
    [PrimaryMiddleInitial]   VARCHAR (255) NULL,
    [SecondarySSN]           VARCHAR (255) NULL,
    [SecondaryFirstName]     VARCHAR (255) NULL,
    [SecondaryLastName]      VARCHAR (255) NULL,
    [SecondaryMiddleInitial] VARCHAR (255) NULL,
    [SiteID]                 VARCHAR (255) NULL,
    [PaidPreparerID]         VARCHAR (255) NULL,
    [EFIN]                   VARCHAR (255) NULL,
    [GUID]                   VARCHAR (255) NULL,
    [RALF]                   VARCHAR (255) NULL,
    [TransmitDate]           VARCHAR (255) NULL,
    [TransmitTime]           VARCHAR (255) NULL,
    [PrintFinal]             CHAR (8)      NULL,
    [PrepFee]                INT           NULL,
    [SBFee]                  INT           NULL,
    [PEIProtPlusFee]         INT           NULL,
    [BankProductAttached]    BIT           NULL,
    [HealthQuestion1]        CHAR (1)      NULL,
    [HealthQuestion2]        CHAR (1)      NULL,
    [HealthQuestion3]        CHAR (1)      NULL,
    [HealthCareID]           VARCHAR (255) NULL,
    [PrimaryPhone]           CHAR (10)     NULL,
    [PrimaryWork]            CHAR (10)     NULL,
    [PrimaryCell]            CHAR (10)     NULL,
    [PrimaryEmail]           VARCHAR (255) NULL,
    [RefferalType]           VARCHAR (255) NULL,
    [RefferalText]           VARCHAR (255) NULL,
    [Address]                VARCHAR (255) NULL,
    [City]                   VARCHAR (255) NULL,
    [State]                  CHAR (2)      NULL,
    [Zip]                    CHAR (12)     NULL,
    [PreparerName]           VARCHAR (255) NULL,
    [PTIN]                   CHAR (9)      NULL,
    [recTS]                  DATETIME2 (0) CONSTRAINT [DF_tblReturnMaster_recTS] DEFAULT (getdate()) NULL,
    [DependentCount]         INT           NULL,
    [Discount]               INT           NULL,
    [ScheduleA]              TINYINT       NULL,
    [ScheduleC]              TINYINT       NULL,
    [form_type_1040]         CHAR (1)      NULL,
    [FLD1272]                INT           NULL,
    [FLD1274]                CHAR (1)      NULL,
    [FLD1276]                CHAR (1)      NULL,
    [FLD1278]                CHAR (17)     NULL,
    [NonFinInvTotal]         INT           NULL,
    [TaxpayeriProtectID]     VARCHAR (9)   NULL,
    [TaxpayerDOB]            DATE          NULL,
    [SpouseiProtectID]       VARCHAR (9)   NULL,
    [SpouseDOB]              DATE          NULL,
    [TaxpayerAgreeDate]      DATE          NULL,
    [SpouseAgreeDate]        DATE          NULL,
    [req_utip_fee]           INT           NULL,
    [req_mmac_fee]           INT           NULL,
    [req_mmip_fee]           INT           NULL,
    [ret_stat]               CHAR (1)      NULL,
    [AncillaryCode]          CHAR (4)      NULL,
    [CreatedReturnDate]      DATETIME      NULL,
    [SecondaryHome]          CHAR (10)     NULL,
    [SecondaryWork]          CHAR (10)     NULL,
    [SecondaryCell]          CHAR (10)     NULL,
    [ModifiedDate]           DATETIME2 (7) CONSTRAINT [DF_tblReturnMaster_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedDate]            DATETIME2 (7) CONSTRAINT [DF_tblReturnMaster_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [advOptOut]              BIT           CONSTRAINT [DF_tblReturnMaster_advOptOut] DEFAULT ((0)) NOT NULL,
    [advRequestDate]         DATETIME      NULL,
    [ScheduleCEz]            TINYINT       NULL,
    [Form8863]               TINYINT       NULL,
    [DisabledDependent]      TINYINT       NULL,
    [HCQ9]                   BIT           CONSTRAINT [DF_tblReturnMaster_HCQ9] DEFAULT ((0)) NOT NULL,
    [referral]               BIT           CONSTRAINT [DF_tblReturnMaster_referral] DEFAULT ((0)) NOT NULL,
    [referralName]           VARCHAR (80)  NULL,
    [referralSSN]            CHAR (9)      NULL,
    [referralPhone]          CHAR (10)     NULL,
    [referralAddress]        VARCHAR (35)  NULL,
    [referralCity]           VARCHAR (35)  NULL,
    [referralState]          CHAR (2)      NULL,
    [referralZipCode]        VARCHAR (12)  NULL,
    [ExternalId]             CHAR (26)     NULL,
    [InvTotalPayments]       INT           NULL,
    [RowVer]                 ROWVERSION    NOT NULL,
    [nRowVer]                AS            (CONVERT([bigint],[RowVer],0)) PERSISTED,
    [bankAcctType]           CHAR (1)      NULL,
    [ReferralDate]           DATETIME      NULL,
    [referralIDScanned]      BIT           DEFAULT ((0)) NOT NULL,
    [qualifyException]       BIT           CONSTRAINT [df_tblReturnMaster_qualifyException] DEFAULT ((0)) NULL,
    [CDSj_q1]                BIT           CONSTRAINT [df_tblReturnMaster_CDSj_q1] DEFAULT ((0)) NULL,
    [CDSj_q2]                BIT           CONSTRAINT [df_tblReturnMaster_CDSj_q2] DEFAULT ((0)) NULL,
    [CDSj_q3]                BIT           CONSTRAINT [df_tblReturnMaster_CDSj_q3] DEFAULT ((0)) NULL,
    [CDSj_q4]                BIT           CONSTRAINT [df_tblReturnMaster_CDSj_q4] DEFAULT ((0)) NULL,
    [CustomerAdvance]        INT           NULL,
    [userStatus]             VARCHAR (7)   NULL,
    [EIP]                    CHAR (1)      NULL,
    [remoteSigBaseFee]       INT           NULL,
    [remoteSigAddOnFee]      INT           NULL,
    [PaperFileRT]            CHAR (1)      NULL,
    [charge_subtotal1]       INT           NULL,
    [discount_subtotal]      INT           NULL,
    [charge_subtotal2]       INT           NULL,
    [payment_subtotal]       INT           NULL,
    [prior_year_balance]     INT           NULL,
    [net_invoice]            INT           NULL,
    [ImportAPIKey]           VARCHAR (64)  NULL,
    [CDSj_q5]                BIT           CONSTRAINT [DF_tblReturnMaster_CDSj_q5] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblReturnMaster] PRIMARY KEY CLUSTERED ([PrimarySSN] ASC, [FilingStatus] ASC, [UserID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblReturnMaster]
    ON [dbo].[tblReturnMaster]([BankProductAttached] ASC, [UserID] ASC)
    INCLUDE([PrimarySSN], [FilingStatus], [GUID], [PrintFinal], [SBFee], [PEIProtPlusFee], [recTS]);


GO
CREATE NONCLUSTERED INDEX [ID2_tblReturnMaster]
    ON [dbo].[tblReturnMaster]([PrintFinal] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblReturnMaster_nRowVer]
    ON [dbo].[tblReturnMaster]([nRowVer] DESC)
    INCLUDE([PrimarySSN]);


GO
CREATE trigger [dbo].[trg_tblReturnMaster_ChangeOccurred]
on 
    [dbo].[tblReturnMaster]
after
    insert, update
as
	if @@rowcount = 0
		return

	set nocount on

	--insert change tracking row
	insert into tblFetchSvcRtnStatus
	select PrimarySSN, FilingStatus, UserID, GETDATE(), 1 from inserted

	--update ModifiedDate on original table
	update rm       
        set rm.ModifiedDate = getdate()
    from
        dbo.tblReturnMaster rm join inserted i on rm.PrimarySSN = i.PrimarySSN

