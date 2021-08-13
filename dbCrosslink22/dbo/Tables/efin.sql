CREATE TABLE [dbo].[efin] (
    [EfinID]                     INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Efin]                       INT           NOT NULL,
    [Master]                     INT           NULL,
    [HoldFlag]                   CHAR (1)      CONSTRAINT [DF_efin_hold_flag] DEFAULT ('N') NULL,
    [UserID]                     INT           NULL,
    [Ein]                        INT           NULL,
    [Company]                    VARCHAR (35)  NULL,
    [FirstName]                  VARCHAR (14)  NULL,
    [LastName]                   VARCHAR (20)  NULL,
    [Address]                    VARCHAR (35)  NULL,
    [City]                       VARCHAR (22)  NULL,
    [State]                      VARCHAR (2)   NULL,
    [Zip]                        VARCHAR (9)   NULL,
    [Email]                      VARCHAR (50)  NULL,
    [Phone]                      VARCHAR (10)  NULL,
    [Mobile]                     VARCHAR (10)  NULL,
    [Fax]                        VARCHAR (10)  NULL,
    [DOB]                        DATETIME      NULL,
    [SSN]                        VARCHAR (10)  NULL,
    [CheckName]                  VARCHAR (15)  NULL,
    [FeeBankName]                VARCHAR (25)  NULL,
    [FeeRoutingNumber]           VARCHAR (9)   NULL,
    [FeeAccountNumber]           VARCHAR (17)  NULL,
    [FeeAccountType]             VARCHAR (1)   NULL,
    [SelectedBank]               CHAR (1)      NULL,
    [UpdatedDate]                DATETIME      NULL,
    [UpdatedBy]                  VARCHAR (11)  NULL,
    [CreatedDate]                DATETIME      CONSTRAINT [DF__efin__create_dat__6319B466] DEFAULT (getdate()) NULL,
    [CreatedBy]                  VARCHAR (11)  NULL,
    [Account]                    VARCHAR (8)   NULL,
    [EFINType]                   CHAR (1)      NULL,
    [SBFeeAll]                   CHAR (1)      NULL,
    [DistributorId]              INT           NULL,
    [CompanyId]                  INT           NULL,
    [LocationId]                 INT           NULL,
    [EROBankFee]                 INT           NULL,
    [HoldNote]                   VARCHAR (50)  NULL,
    [HoldDate]                   DATETIME      NULL,
    [HoldBy]                     VARCHAR (12)  NULL,
    [Deleted]                    BIT           CONSTRAINT [DF_efin_Deleted] DEFAULT ((0)) NOT NULL,
    [Locked]                     BIT           CONSTRAINT [DF_efin_Locked] DEFAULT ((0)) NOT NULL,
    [AgreePEITerms]              BIT           CONSTRAINT [DF_efin_AgreePEITerms] DEFAULT ((0)) NOT NULL,
    [AgreePEIDate]               DATETIME      NULL,
    [AllowMultipleBanks]         BIT           CONSTRAINT [DF_efin_AllowMultipleBanks] DEFAULT ((0)) NOT NULL,
    [AdventSent]                 BIT           CONSTRAINT [DF_efin_AdventSent] DEFAULT ((0)) NOT NULL,
    [AgreeFeeOption]             BIT           CONSTRAINT [DF_efin_AgreeFeeOption] DEFAULT ((0)) NOT NULL,
    [AgreeFeeOptionDate]         DATETIME      NULL,
    [AgreeRushCard]              BIT           CONSTRAINT [DF_efin_AgreeRushCard] DEFAULT ((0)) NOT NULL,
    [AgreeRushCardDate]          DATETIME      NULL,
    [RushStatusCode]             CHAR (2)      NULL,
    [RushStatusDate]             DATETIME      NULL,
    [RushPartnerId]              INT           NULL,
    [RushLocationId]             INT           NULL,
    [RushStatusDesc]             VARCHAR (150) NULL,
    [AgreeToSCO]                 BIT           CONSTRAINT [DF_AgreeToSCO] DEFAULT ((0)) NOT NULL,
    [AgreeToSCODate]             DATETIME      NULL,
    [ParticipateSCO]             BIT           NULL,
    [SCOStatusDate]              DATETIME      NULL,
    [SCOStatus]                  VARCHAR (1)   NULL,
    [RefundAdvantageCardProgram] CHAR (1)      NULL,
    [Title]                      VARCHAR (50)  NULL,
    [IDNumber]                   VARCHAR (50)  NULL,
    [IDState]                    VARCHAR (2)   NULL,
    [FeeAccountName]             VARCHAR (35)  NULL,
    [IRSEfinValidation]          CHAR (1)      NULL,
    [EfinStatus]                 CHAR (1)      NULL,
    [EfinProduct]                CHAR (1)      NULL,
    [EfinCompliance]             CHAR (1)      NULL,
    [EfinCard]                   CHAR (1)      NULL,
    [EfinPrint]                  CHAR (1)      NULL,
    [EfinProduct2]               CHAR (1)      NULL,
    [FivePlus]                   BIT           NULL,
    [CorporationType]            CHAR (1)      NULL,
    [CountryCode]                CHAR (3)      NULL,
    [IRSTrackingNumber]          VARCHAR (20)  NULL,
    [EFINRegisteredBy]           VARCHAR (3)   NULL,
    [AgreePEIBy]                 VARCHAR (50)  NULL,
    [EFFeeAll]                   CHAR (1)      NULL,
    [EFOnly]                     BIT           CONSTRAINT [DF_efin_EFOnly] DEFAULT ((0)) NOT NULL,
    [EFFee]                      INT           NULL,
    [NetEFFee]                   INT           NULL,
    [CPTSAdminEFFee]             INT           NULL,
    [IDType]                     VARCHAR (2)   NULL,
    [IDExpirationDate]           DATETIME      NULL,
    [cpts_admin_fee]             INT           NULL,
    [TechFee]                    INT           NULL,
    [NetTechFee]                 INT           NULL,
    [CPTSAdminTechFee]           INT           NULL,
    CONSTRAINT [PK_efin] PRIMARY KEY CLUSTERED ([EfinID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_efin_28_1575676661__K1_K99_57_177]
    ON [dbo].[efin]([Efin] ASC, [EfinID] ASC)
    INCLUDE([SelectedBank]);


GO
CREATE NONCLUSTERED INDEX [ID1_efin]
    ON [dbo].[efin]([Account] ASC, [Deleted] ASC);


GO
CREATE NONCLUSTERED INDEX [ID2_efin]
    ON [dbo].[efin]([Deleted] ASC)
    INCLUDE([Efin], [Account]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_efin]
    ON [dbo].[efin]([Efin] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_efin_UserID_HoldFlag]
    ON [dbo].[efin]([UserID] ASC, [HoldFlag] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_efin_Efin_SelectedBank]
    ON [dbo].[efin]([Efin] ASC, [SelectedBank] ASC);


GO
-- =============================================
-- Author:		Charles Krebs
-- Create date: 9/13/2010
-- Description:	Set the Agree Date if Agree Bank is set
/*
Updated to update on agree to rush card or agree to fee option as well.
9/4/2012 Charles Krebs
*/
-- =============================================
CREATE TRIGGER [dbo].[tgrEFINAgreeBank] 
   ON  [dbo].[efin] 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/* When the Agree to PEI Terms field is changed, we want to set or clear the Agree to PEI Date appropriately. */
	IF Update(AgreePEITerms) 
	BEGIN
		UPDATE efin
		SET AgreePEIDate = 
			(CASE WHEN inserted.AgreePEITerms = 1 AND inserted.AgreePEIDate is null THEN getDate()
				WHEN inserted.AgreePEITerms = 1 AND inserted.AgreePEIDate is not null THEN inserted.AgreePEIDate
				WHEN inserted.AgreePEITerms = 0 AND inserted.AgreePEIDate is not null THEN null END)
		FROM efin 
			INNER JOIN inserted ON inserted.efin = efin.efin
	END
	/* When the Agree to Fee Option field is changed, we want to set or clear the Agree to Fee Option Date appropriately. */
	IF Update(AgreeFeeOption) 
	BEGIN
		UPDATE efin
		SET AgreeFeeOptionDate = 
			(CASE WHEN inserted.AgreeFeeOption = 1 AND inserted.AgreeFeeOptionDate is null THEN getDate()
				WHEN inserted.AgreeFeeOption = 1 AND inserted.AgreeFeeOptionDate is not null THEN inserted.AgreeFeeOptionDate
				WHEN inserted.AgreeFeeOption = 0 AND inserted.AgreeFeeOptionDate is not null THEN null END)
		FROM efin 
			INNER JOIN inserted ON inserted.efin = efin.efin
	END
	/* When the Agree to Rush Card field is changed, we want to set or clear the Agree to Rush Card Date appropriately. */
	IF Update(AgreeRushCard) 
	BEGIN
		UPDATE efin
		SET AgreeRushCardDate = 
			(CASE WHEN inserted.AgreeRushCard = 1 AND inserted.AgreeRushCardDate is null THEN getDate()
				WHEN inserted.AgreeRushCard = 1 AND inserted.AgreeRushCardDate is not null THEN inserted.AgreeRushCardDate
				WHEN inserted.AgreeRushCard = 0 AND inserted.AgreeRushCardDate is not null THEN null END)
		FROM efin 
			INNER JOIN inserted ON inserted.efin = efin.efin
	END
	
END






GO
-- =============================================
-- Author:		Paulo Borges
-- Create date: 12/29/2011
-- Description:	update the service bureau id in taxbrainXX..tblEfin 
-- =============================================
CREATE TRIGGER [dbo].[tgrEFINUserIdUpdate] 
   ON  [dbo].[efin] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @efin int
	/* When the Agree to PEI Terms field is changed, we want to set or clear the Agree to PEI Date appropriately. */
	IF Update(USERID) 
	BEGIN
		UPDATE vwTaxbrainEfin
		SET svcb_id = (SELECT max(svcb_id) FROM vwTaxbrainsvcbureau where svcb_userid = inserted.userid)
		FROM inserted 
		WHERE vwTaxbrainEfin.efin = inserted.efin
	END
END




GO
DISABLE TRIGGER [dbo].[tgrEFINUserIdUpdate]
    ON [dbo].[efin];


GO

CREATE TRIGGER [dbo].[tgr_efinWalletCreate] 
   ON  [dbo].[efin] 
   AFTER INSERT,UPDATE
AS 


declare @account        varchar(8)
declare @userId         int
declare @efin           int
declare @season         smallint = '20' + right(db_name(),2)
declare @wToken         char(32)
declare @mrXml          varchar(255)
declare @seqNum         int

/*
declare @output table(
    walletToken             char(32)
,   account                 varchar(8)
,   userId                  int
,   efin                    int
,   typeId                  tinyint
,   statusId                tinyint
,   currentBalance          money
,   errStatus               tinyint
,   errDesc                 varchar(255)
)
*/

    set nocount on

    declare curWallet cursor fast_forward for
        select 
            e.account
        ,   e.userId
        ,   e.efin
        from
            (
                select 
                    i.Account
                ,   i.UserID
                ,   case when i.userId > 500000 then i.efin else 0 end efin
                from    
                    inserted i left join dbo.efin e1 on i.efinId = e1.EfinID
                    left join deleted d on e1.EfinID = d.EfinID
                where
                    i.userId > 500000
                    and ((i.Account != isnull(e1.Account,'')
                        or i.userId != isnull(e1.UserID,0)
                        or i.efin != isnull(e1.Efin,0))
                            or (e1.Account != isnull(d.Account,'')
                                or e1.userId != isnull(d.UserID,0)
                                or e1.efin != isnull(d.Efin,0)
                                )
                        )
            ) e left join dbCrosslinkGlobal.dbo.tblWallet w on e.account = w.account 
                and e.userId = w.userId
                and e.efin = w.efin
        where
            w.walletId is null
            and e.Account is not null

    open curWallet
    fetch next from curWallet into @account, @userId, @efin 

    while @@fetch_status = 0
        begin
            -- Create the new wallet.
            --insert @output
            exec dbCrosslinkGlobal.dbo.up_walletCreate @account, @efin, @userId, @season, 10, 10, 35, @wtoken output, 1

            --if @wToken is not null -- Commented out per Josh . He did not want to miss it if the wallet could not be created.
            --    begin
                    -- Insert the launch record if it does not exist

                    /*
                    insert dbo.tblMgmt(
                        [delivered]
                    ,   [userid]
                    ,   [seqno]
                    ,   [xmldata]
                    )
                        select
                            a.[delivered]
                        ,   a.[userId]
                        ,   a.[seqno]
                        ,   a.[xmldata]
                        from
                            (
                                select
                                    ' ' [delivered]
                                ,   @userId [userId]
                                ,   1 [seqno]
                                ,   '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>' [xmldata]

                            ) a left join dbo.tblMgmt m on a.[userId] = m.[userId]
                                and m.[seqno] = 1
                        where
                            m.[seqno] is null

                    -- Create the tblMgmt record with the new wallet token.
                    set @mrXml = '<xmldata><cmnd>AuthCode</cmnd>'
                        + case when @efin > 0 then '<efin>' + convert(varchar(10),@efin) + '</efin>' else '' end
                        + '<WALT>' + @wToken +  '</WALT>'
                        + '</xmldata>'

                    -- Insert the new Mgmt record for the updated fees
                    select
                        @seqNum = a.seqno + 1 
                    from
                        (
                            select
                                m.userid [user_id] 
                            ,   m.seqno
                            ,   row_number() over ( partition by m.userid order by m.seqno desc) rowNum
                            from
                                dbo.tblMgmt m
                            where
                                m.userid = @userId
                        ) a
                    where
                        a.rowNum = 1

                    if @seqNum is null
                        set @seqNum = 1

                    insert dbo.tblMgmt(
                        [delivered]
                    ,   [userid]
                    ,   [seqno]
                    ,   [xmldata]
                    )
                        select
                            ' ' [delivered]
                        ,   @userId [userid]
                        ,   @seqNum [seqno]
                        ,   @mrXml [xmldata]
                    */
                --end

            fetch next from curWallet into @account, @userId, @efin 
        end
        
    close curWallet
    deallocate curWallet

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This column is this field', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'efin', @level2type = N'COLUMN', @level2name = N'EfinID';

