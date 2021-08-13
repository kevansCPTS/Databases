CREATE TABLE [dbo].[tblAccountAncillaryProduct] (
    [account]            VARCHAR (8)  NOT NULL,
    [aprodId]            INT          NOT NULL,
    [addonAmount]        MONEY        NULL,
    [tag]                CHAR (3)     NOT NULL,
    [agreeToTerms]       BIT          CONSTRAINT [DF_tblAccountAncillaryProduct_agreeToTerms] DEFAULT ((0)) NOT NULL,
    [agreeToTermsDate]   DATETIME     NULL,
    [agreeToParticipate] BIT          CONSTRAINT [DF_tblAccountAncillaryProduct_agreeToParticipate] DEFAULT ((0)) NOT NULL,
    [autoAddDefault]     BIT          CONSTRAINT [DF_tblAccountAncillaryProduct_autoAddDefualt] DEFAULT ((0)) NOT NULL,
    [createDate]         DATETIME     CONSTRAINT [DF_tblAccountAncillaryProduct_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]           VARCHAR (50) CONSTRAINT [DF_tblAccountAncillaryProduct_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate]         DATETIME     CONSTRAINT [DF_tblAccountAncillaryProduct_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]           VARCHAR (50) CONSTRAINT [DF_tblAccountAncillaryProduct_modifyBy] DEFAULT (original_login()) NOT NULL,
    [id]                 INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_tblAccountAncillaryProduct] PRIMARY KEY CLUSTERED ([account] ASC, [aprodId] ASC),
    CONSTRAINT [FK_tblAccountAncillaryProduct_tblAncillaryProduct] FOREIGN KEY ([aprodId]) REFERENCES [dbo].[tblAncillaryProduct] ([aprodId])
);


GO
-- =============================================
-- Author:		Jay Willis
-- Create date: 7/31/2015
-- Description:	
-- Update: 10/12/2015 allow removal of products
-- =============================================
CREATE TRIGGER [dbo].[tgrtblAccountAncillaryProduct] 
   ON  [dbo].[tblAccountAncillaryProduct] 
   AFTER INSERT,UPDATE
AS 
BEGIN

	declare @userid int

	create table #temp (
	Userid int,
	XMLString varchar(max)
	)
	
	DECLARE cur_rs2 CURSOR
	FOR
    select
        u.[user_id] 
    from
        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
            and u.[user_id] < 996000
		--where i.agreeToParticipate = 1

	OPEN cur_rs2;
	FETCH NEXT FROM cur_rs2 INTO @userid
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
				BEGIN 

			insert into #temp
			exec up_getProductTags2 @userid
		END;
		FETCH NEXT FROM cur_rs2 INTO @userid
		END;
	CLOSE cur_rs2;
	DEALLOCATE cur_rs2;

	--select * from #temp
	--drop table #temp;


    declare @sLaunch varchar(200)

    set @sLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'

        -- Insert the launch record if it does not exist
        insert dbo.tblMgmt(
            [delivered]
        ,   [userid]
        ,   [seqno]
        ,   [xmldata]
        )
            select
                ' ' [delivered]
            ,   u.[user_id] 
            ,   1 [seqno]
            ,   @sLaunch [xmldata] 
            from
                inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
                    and u.[user_id] < 996000
                left join dbo.tblMgmt m on u.[user_id] = m.userid
                    and m.seqno = 1 
            where
                m.seqno is null
				--and i.agreeToParticipate = 1



        -- Insert the Global records for products
        insert dbo.tblMgmt(
            [delivered]
        ,   [userid]
        ,   [seqno]
        ,   [xmldata]
        )
            select
                ' ' [delivered]
            ,   a.[user_id] [userid]
            ,   a.seqno + 1 [seqno]
            ,   '<xmldata><cmnd>Global</cmnd>' + a.xmldata+ '</xmldata>' [xmldata]   
            from
                (
                    select
                        u.[user_id] 
                    ,   m.seqno
					,	t.XMLString xmldata
                    ,   row_number() over ( partition by u.[user_id] order by m.seqno desc) rowNum
                    from
                        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
                            and u.[user_id] < 996000
                        join dbo.tblMgmt m on u.[user_id] = m.userid
						join #temp t on u.user_id = t.Userid
						--where i.agreeToParticipate = 1
                ) a
            where
                a.rowNum = 1

END


GO
    CREATE trigger [dbo].[trg_tblAccountAncillaryProduct_Modify]
    on 
        [dbo].[tblAccountAncillaryProduct]
    for
        update
    as
        update aap      
            set aap.modifyDate = isnull(i.modifyDate, getdate())
        ,   aap.modifyBy = isnull(i.modifyBy, SYSTEM_USER)
        from
            tblAccountAncillaryProduct aap join inserted i on aap.aprodId = i.aprodId
                and aap.account = i.account
                and (i.modifyBy is null
                    or i.modifyDate is null)
                


















