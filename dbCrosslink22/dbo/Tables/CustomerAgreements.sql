CREATE TABLE [dbo].[CustomerAgreements] (
    [Account]                     VARCHAR (8)  NOT NULL,
    [AgreeToPassthroughTerms]     BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToPassthroughTerms] DEFAULT ((0)) NOT NULL,
    [AgreeToProtectionPlus]       BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToProtectionPlus] DEFAULT ((0)) NOT NULL,
    [AgreeToPassthroughTermsDate] DATETIME     NULL,
    [AgreeToProtectionPlusDate]   DATETIME     NULL,
    [AgreeToCAD]                  BIT          CONSTRAINT [DF_AgreeToCAD] DEFAULT ((0)) NOT NULL,
    [AgreeToCADTermsDate]         DATETIME     NULL,
    [ParticipatePassthrough]      BIT          CONSTRAINT [DF_ParticipatePassthrough] DEFAULT ((1)) NOT NULL,
    [ParticipateProtectionPlus]   BIT          CONSTRAINT [DF_ParticipateProtectionPlus] DEFAULT ((1)) NOT NULL,
    [ParticipateCAD]              BIT          CONSTRAINT [DF_ParticipateCAD] DEFAULT ((1)) NOT NULL,
    [AgreeToAddendum]             BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToAddendum] DEFAULT ((0)) NOT NULL,
    [AgreeToAddendumDate]         DATETIME     NULL,
    [AgreeToPassthroughUser]      VARCHAR (20) NULL,
    [AgreeToBankProducts]         BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToBankProducts] DEFAULT ((0)) NOT NULL,
    [AgreeToBankProductsDate]     DATETIME     NULL,
    [AgreeToBankProductsUser]     VARCHAR (20) NULL,
    [AgreeToEFTerms]              BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToEFTerms] DEFAULT ((0)) NOT NULL,
    [AgreeToEFTermsDate]          DATETIME     NULL,
    [ParticipateEF]               BIT          CONSTRAINT [DF_CustomerAgreements_ParticipateEF] DEFAULT ((0)) NOT NULL,
    [AgreeToEFUser]               VARCHAR (20) NULL,
    [LockEFFeeAll]                BIT          CONSTRAINT [DF_CustomerAgreements_LockEFFeeAll] DEFAULT ((0)) NOT NULL,
    [AgreeToPPR]                  BIT          CONSTRAINT [DF_CustomerAgreements_AgreeToPPR] DEFAULT ((0)) NOT NULL,
    [AgreeToPPRDate]              DATETIME     NULL,
    [AgreeToPPRUser]              VARCHAR (20) NULL,
    CONSTRAINT [PK_CustomerAgreements] PRIMARY KEY CLUSTERED ([Account] ASC)
);


GO

/****** Object:  Trigger [dbo].[tgrCustomerAgreementsDate]    Script Date: 8/17/2018 5:15:21 PM ******/

-- =============================================
-- Author:		Charles Krebs
-- Create date: 10/20/2011
-- Description:	When the Agree To flags are set, set the Dates as well
/*	In addition, if an Account is agreeing to the Protection Plus 
	terms, we need to send an activation code to any already-live users
	under that account to activate Protection Plus within the software.
*/
-- Updated: 03/07/2014 Jay Willis - modified to check for participation flag on Protection Plus
-- Updated: 12/10/2014 KJE - Per Jay, dumped the admin messages and replaced them with xml records added the tblMgmt
-- Updated: 9/16/2015 JW - product activation now done from tblAccountAncillaryProduct table 
-- Updated 8/17/2018 JW - Added AgreeToBankProductsDate
-- Updated 9/20/2019 JW - Added AgreeToEFDate
-- Updated 9/1/2020 JW - Added AgreeToPPRDate
-- =============================================
CREATE TRIGGER [dbo].[tgrCustomerAgreementsDate] 
   ON  [dbo].[CustomerAgreements] 
   AFTER INSERT,UPDATE
AS 
BEGIN


    --declare @sLaunch varchar(200)
    --declare @sGlobal varchar(100)

    --set @sLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
    --set @sGlobal = '<xmldata><cmnd>Global</cmnd><AUDF>X</AUDF></xmldata>'


        --Set the update date fields when the flags are changed
        update ca
            set ca.AgreeToAddendumDate = case 
                                                    when i.AgreeToAddendum = 1 then isnull(i.AgreeToAddendumDate,getdate())
                                                    when i.AgreeToAddendum = 0 and i.AgreeToAddendumDate is not null then null                
                                                    else ca.AgreeToAddendumDate
                                                 end
        ,   ca.AgreeToPassthroughTermsDate = case 
                                                    when i.AgreeToPassthroughTerms = 1 then isnull(i.AgreeToPassthroughTermsDate,getdate())
                                                    when i.AgreeToPassthroughTerms = 0 and i.AgreeToPassthroughTermsDate is not null then null                
                                                    else ca.AgreeToPassthroughTermsDate
                                                 end
        ,   ca.AgreeToProtectionPlusDate = case 
                                                when i.AgreeToProtectionPlus = 1  then isnull(i.AgreeToProtectionPlusDate,getdate())
                                                when i.AgreeToProtectionPlus = 0 and i.AgreeToProtectionPlusDate is not null then null                
                                                else ca.AgreeToProtectionPlusDate
                                           end                                            
        ,   ca.AgreeToCADTermsDate = case 
                                                when i.AgreeToCAD = 1 then isnull(i.AgreeToCADTermsDate,getdate())
                                                when i.AgreeToCAD = 0 and i.AgreeToCADTermsDate is not null then null                
                                                else ca.AgreeToCADTermsDate
                                           end     
         ,	ca.AgreeToBankProductsDate = case 
                                                    when i.AgreeToBankProducts = 1 then isnull(i.AgreeToBankProductsDate,getdate())
                                                    when i.AgreeToBankProducts = 0 and i.AgreeToBankProductsDate is not null then null                
                                                    else ca.AgreeToBankProductsDate
                                                 end
         ,	ca.AgreeToEFTermsDate = case 
                                                    when i.AgreeToEFTerms = 1 then isnull(i.AgreeToEFTermsDate,getdate())
                                                    when i.AgreeToEFTerms = 0 and i.AgreeToEFTermsDate is not null then null                
                                                    else ca.AgreeToEFTermsDate
                                                 end
         ,	ca.AgreeToPPRDate = case 
                                                    when i.AgreeToPPR = 1 then isnull(i.AgreeToPPRDate,getdate())
                                                    when i.AgreeToPPR = 0 and i.AgreeToPPRDate is not null then null                
                                                    else ca.AgreeToPPRDate
                                                 end
        from
            dbo.CustomerAgreements ca join inserted i on ca.Account = i.Account
  




        ---- Insert the launch record if it does not exist
        --insert dbo.tblMgmt(
        --    [delivered]
        --,   [userid]
        --,   [seqno]
        --,   [xmldata]
        --)
        --    select
        --        ' ' [delivered]
        --    ,   u.[user_id] 
        --    ,   1 [seqno]
        --    ,   @sLaunch [xmldata] 
        --    from
        --        inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
        --            and (i.ParticipateProtectionPlus = 1 
        --                    or i.ParticipateCAD = 1)
        --            and u.[user_id] < 996000
        --        left join dbo.tblMgmt m on u.[user_id] = m.userid
        --            and m.seqno = 1 
        --    where
        --        m.seqno is null


        ---- Insert the PP global record if they are participating
        --insert dbo.tblMgmt(
        --    [delivered]
        --,   [userid]
        --,   [seqno]
        --,   [xmldata]
        --)
        --    select
        --        ' ' [delivered]
        --    ,   a.[user_id] [userid]
        --    ,   a.seqno + 1 [seqno]
        --    ,   @sGlobal [xmldata]   
        --    from
        --        (
        --            select
        --                u.[user_id] 
        --            ,   m.seqno
        --            ,   row_number() over ( partition by u.[user_id] order by m.seqno desc) rowNum
        --            from
        --                inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
        --                    and i.ParticipateProtectionPlus = 1 
        --                    and u.[user_id] < 996000
        --                join dbo.tblMgmt m on u.[user_id] = m.userid

        --        ) a
        --    where
        --        a.rowNum = 1



        ---- Insert the PP and CADR record if they are participating
        --insert dbo.tblMgmt(
        --    [delivered]
        --,   [userid]
        --,   [seqno]
        --,   [xmldata]
        --)
        --    select
        --        ' ' [delivered]
        --    ,   a.[user_id] [userid]
        --    ,   a.seqno + 1 [seqno]
        --    ,   '<xmldata><cmnd>AuthCode</cmnd>' +
        --        case 
        --            when a.ParticipateProtectionPlus = 1 then '<PAC8>X</PAC8>'
        --            else ''
        --        end + 
        --        case 
        --            when a.ParticipateCAD = 1 then '<PAC7>X</PAC7>'
        --            else ''
        --        end + '</xmldata>' [xmldata]   
        --    from
        --        (
        --            select
        --                u.[user_id] 
        --            ,   m.seqno
        --            ,   i.ParticipateProtectionPlus
        --            ,   i.ParticipateCAD
        --            ,   row_number() over ( partition by u.[user_id] order by m.seqno desc) rowNum
        --            from
        --                inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account 
        --                    and (i.ParticipateProtectionPlus = 1 
        --                            or i.ParticipateCAD = 1)
        --                    and u.[user_id] < 996000
        --                join dbo.tblMgmt m on u.[user_id] = m.userid
        --        ) a
        --    where
        --        a.rowNum = 1



















  

    /*
    --Create the Protection Plus admin message
    insert dbo.[admin](
        delivered
    ,   req_type
    ,   [param]
    ,   ssn
    ,   dt
    ,   requestor
    )
        select
            ' ' delivered
        ,   'T' req_type
        ,   'PAC8XYZ' [param]
        ,   convert(varchar(25),u.[user_id]) ssn
        ,   convert(varchar(25),getdate(),121) dt
        ,   'System' requestor
        from
            inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account
                and i.AgreeToProtectionPlus = 1 
                and i.ParticipateProtectionPlus = 1
                and u.[user_id] < 996000
            join dbo.[admin] act on u.[user_id] = act.ssn  
            left join dbo.[admin] a on u.[user_id] = a.ssn
                and a.req_type = 'T'
                and a.[param] = 'PAC8XYZ'
        where
            a.ssn is null

    --Create the CAD admin message
    insert dbo.[admin](
        delivered
    ,   req_type
    ,   [param]
    ,   ssn
    ,   dt
    ,   requestor
    )
        select
            ' ' delivered
        ,   'T' req_type
        ,   'PAC7CADR' [param]
        ,   convert(varchar(25),u.[user_id]) ssn
        ,   convert(varchar(25),getdate(),121) dt
        ,   'CADR_Enroll' requestor
        from
            inserted i join dbCrosslinkGlobal.dbo.tblUser u on i.Account = u.account
                and i.AgreeToCAD = 1 
                and i.ParticipateCAD = 1
                and u.[user_id] < 996000
            join dbo.[admin] act on u.[user_id] = act.ssn  
            left join dbo.[admin] a on u.[user_id] = a.ssn
                and a.req_type = 'T'
                and a.[param] = 'PAC7CADR'
        where
            a.ssn is null
    */

--select convert(smallint,'20' + right(convert(varchar(25),db_name()),2))


/*

	IF Update(AgreeToPassthroughTerms) 
	BEGIN


		UPDATE CustomerAgreements
		SET AgreeToPassthroughTermsDate = 
			(CASE WHEN inserted.AgreeToPassthroughTerms = 1 AND inserted.AgreeToPassthroughTermsDate is null THEN getDate()
				WHEN inserted.AgreeToPassthroughTerms = 1 AND inserted.AgreeToPassthroughTermsDate is not null THEN inserted.AgreeToPassthroughTermsDate
				WHEN inserted.AgreeToPassthroughTerms = 0 AND inserted.AgreeToPassthroughTermsDate is not null THEN null END)
		FROM CustomerAgreements 
			INNER JOIN inserted ON inserted.Account = CustomerAgreements.Account
			
		

	END

	IF Update(AgreeToProtectionPlus) or Update(ParticipateProtectionPlus)
	BEGIN
	
		DECLARE @userID int
		
		DECLARE update_cursor CURSOR FOR 
		SELECT tblUser.user_ID
		FROM inserted 
		INNER JOIN dbCrosslinkGlobal..tblUser ON tblUser.Account = inserted.Account
		LEFT JOIN deleted ON inserted.Account = deleted.Account
		WHERE inserted.AgreeToProtectionPlus = 1 AND inserted.ParticipateProtectionPlus = 1
		AND user_ID in (SELECT ssn FROM admin WHERE req_type = 'A')
		AND user_ID not in (SELECT ssn FROM admin WHERE req_type = 'T' AND param = 'PAC8XYZ')
		AND user_ID < 996000
		OPEN update_cursor

		FETCH NEXT FROM update_cursor 
		INTO @userID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec spInsertAdminMessage2 @userID, 'T', 'PAC8XYZ', 'System'
			  -- UPDATE dbCrosslink..efin SET ral_bank = @ralBank WHERE efin = @efin
		   FETCH NEXT FROM update_cursor 
		   INTO @userID
		END

		CLOSE update_cursor
		DEALLOCATE update_cursor
	
		UPDATE CustomerAgreements
		SET AgreeToProtectionPlusDate = 
			(CASE WHEN inserted.AgreeToProtectionPlus = 1 AND inserted.AgreeToProtectionPlusDate is null THEN getDate()
				WHEN inserted.AgreeToProtectionPlus = 1 AND inserted.AgreeToProtectionPlusDate is not null THEN inserted.AgreeToProtectionPlusDate
				WHEN inserted.AgreeToProtectionPlus = 0 AND inserted.AgreeToProtectionPlusDate is not null THEN null END)
		FROM CustomerAgreements 
			INNER JOIN inserted ON inserted.Account = CustomerAgreements.Account

	END
*/
END


