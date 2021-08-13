CREATE TABLE [dbo].[tblUserAncillaryProduct] (
    [UserID]              INT       NOT NULL,
    [aprodid]             INT       NOT NULL,
    [ProductTag]          CHAR (3)  NOT NULL,
    [eroAddOn]            BIT       NOT NULL,
    [addOnAmount]         MONEY     NULL,
    [autoAdd]             BIT       NOT NULL,
    [autoAddFinancial]    BIT       NOT NULL,
    [autoAddNonFinancial] BIT       NOT NULL,
    [agreeToParticipate]  BIT       NOT NULL,
    [createdDate]         DATETIME  NOT NULL,
    [createdBy]           CHAR (20) NOT NULL,
    CONSTRAINT [PK_tblUserAncillaryProduct] PRIMARY KEY CLUSTERED ([UserID] ASC, [aprodid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblUserAncillaryProduct]
    ON [dbo].[tblUserAncillaryProduct]([ProductTag] ASC);


GO

-- =============================================
-- Author:		Jay Willis
-- Create date: 9/21/2018
-- Description:	
-- Update: 
-- =============================================
CREATE TRIGGER [dbo].[tgrtblUserAncillaryProduct] 
   ON  [dbo].[tblUserAncillaryProduct] 
   AFTER INSERT,UPDATE
AS 
BEGIN

	declare @userid int

	create table #temp (
		Userid int,
		XMLString varchar(max),
	)

	DECLARE cur_rs2 CURSOR
	FOR
    select
        u.[user_id]
    from
        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.UserID = u.user_id
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
                inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.UserID = u.user_id 
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
                        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.UserID = u.user_id
                            and u.[user_id] < 996000
                        join dbo.tblMgmt m on u.[user_id] = m.userid
						join #temp t on u.user_id = t.Userid
						--where i.agreeToParticipate = 1
                ) a
            where
                a.rowNum = 1

END


