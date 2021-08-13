/************************************************************************************************
Name: up_getEROSummary

Return the ERO summary information specified in the below supplied queries from Jay:

    select tblXlinkUserSettings.user_id as user_id, name, publish_date, edit_date, usersettings_id,
    tblUser.passwd as transmit_password
    from tblXlinkUserSettings
    join tblUser on tblXlinkUserSettings.user_id = tblUser.user_id
    where 
        account_id = @accountid 
        and franchiseuser_id = @franchiseuserid –- this comparision needs to be fixed

    --For every userid returned I need the following boolean set like this

    select case when COUNT(*) > 0 then 1 else 0 end as IsPickedUp from call_log
    where mgmt != 0 and stat = 'O'
    and user_id = 19841
    and mgmt in (
    select top 1 seqno from tblMgmt
    where userid = 19841
    order by seqno desc


Called By:

Parameters: 
 1 @accountid           varchar(8)     
 2 @franchiseuserid     int             = null

Result Codes:
 0 success

Author: Ken Evans 01/14/2013

Changes/Updates:
    01/21/2013 - KJE
        Renamed the below output columns:
            mgmt to processedID 
            seqno to managementID

    01/25/2013 - KJE
        Updated the logic in the routine that gets the call log info to sort by seq_no instead of mgmt.

    01/26/2013 - KJE
        Moved the virtual selects to to table variables after the above change to improve performance.

    12/04/2013 - KJE
        Added tblXlinkOfficeSetup fields to to the output when the uiser_id and franchiseId match.

	11/04/2014 - JW
		Added more lookups for Database configuration and other tables

	12/08/2014 - KJE
		Refactored the procedure to improve performance after the addition of the new tables on 11/4

	11/21/2019 - CER
		Updated the published logic for the following Databases. If all records have been individually published (and user didn't use Publish All), then still return that everything has been published.
			- User Logins
			- ERO Database
			- Paid Preparers
			- Referral Database
			- Status Codes
**************************************************************************************************/
CREATE procedure [dbo].[up_getEROSummary] --@accountid ='RIVEDG',@franchiseuserid=30632
    @accountid varchar(8) 
,   @franchiseuserid int = null
as


declare @userSettings table (
    [user_id]           int         primary key
,   name                varchar(35)
,   publish_date        datetime
,   edit_date           datetime
,   usersettings_id     int
,	transmit_type		char(1)
,   transmit_password   varchar(8)
,	hidden				bit
,   officeSetup_id      int
,   officeEditDate      datetime
,   officePublishDate   datetime

,   mgmt_seqno          int
,   cl_mgmt             int

,   rfld_pubDate        datetime
,   rfld_editDate       datetime

,   rfrm_pubDate        datetime
,   rfrm_editDate       datetime

,   ul_pubDate          datetime
,   ul_editDate         datetime
,   ul_count            int
,	ul_dirty			bit

,   ed_pubDate          datetime
,   ed_editDate         datetime
,   ed_count            int
,	ed_dirty			bit

,   pd_pubDate          datetime
,   pd_editDate         datetime
,   pd_count            int
,	pd_dirty			bit

,   rd_pubDate          datetime
,   rd_editDate         datetime
,   rd_count            int
,	rd_dirty			bit

,   usc_pubDate         datetime
,   usc_editDate        datetime
,   usc_count           int
,	usc_dirty			bit

,   unique clustered(
        [user_id]
    )
)


set nocount on 

    insert @userSettings(
        [user_id]  
    ,   name     
    ,   publish_date     
    ,   edit_date       
    ,   usersettings_id    
	,	transmit_type
    ,   transmit_password
    ,	hidden				
    ,   officeSetup_id    
    ,   officeEditDate     
    ,   officePublishDate 
    )
        select
            u.[user_id] 
        ,   us.name
        ,   us.publish_date
        ,   us.edit_date
        ,   us.usersettings_id
		,	us.transmit_type
        ,   u.passwd transmit_password
        ,	us.hidden
        ,   os.officeSetup_id
        ,   os.edit_date officeEditDate
        ,   os.publish_date officePublishDate
        from    
			tblUser u left join FranchiseChild fc on u.[user_id] = fc.ChildUserID
			left join FranchiseOwner fo on u.[user_id] = fo.UserID
			left join tblXlinkUserSettings us on u.[user_id] = us.[user_id]
            left join dbo.tblXlinkOfficeSetup os on u.[user_id] = os.[user_id]
		where 
            u.account = @accountid
            and (@franchiseuserid is null
                    and fc.ParentUserID is null
                    and fo.UserID is null
                )
                or 
                    (@franchiseuserid is not null
                        and (fc.ParentUserID = @franchiseuserid
				                or fo.UserID = @franchiseuserid                            
                            )
                    )

    update us
        set us.cl_mgmt = cl.mgmt
    from
        @userSettings us join (
                                select
                                    cl2.[user_id]
                                ,   cl2.mgmt
                                from
                                    (
                                        select
                                            us1.[user_id]
                                        ,   cl1.mgmt
                                        ,   row_number() over ( partition by us1.[user_id] order by cl1.seq_no desc) rowNum
                                        from
                                            @userSettings us1 join dbo.call_log cl1 on us1.[user_id] = cl1.[user_id]
                                                and cl1.stat = 'O'
                                    ) cl2 left join @userSettings us on cl2.[user_id] = us.[user_id]
                                where
                                    cl2.rowNum = 1    
                              ) cl on us.[user_id] = cl.[user_id]


    update us
        set us.mgmt_seqno = m.seqno
    from
        @userSettings us join (
                                select
                                    m2.[user_id]
                                ,   m2.seqno
                                from
                                    (
                                        select
                                            us2.[user_id]
                                        ,   m1.seqno
                                        ,   row_number() over ( partition by us2.[user_id] order by m1.seqno desc) rowNum
                                        from
                                            @userSettings us2 join dbo.tblMgmt m1 on us2.[user_id] = m1.userid
                                    ) m2
                                where 
                                    m2.rowNum = 1
                              ) m on us.[user_id] = m.[user_id]



    update us
        set us.rfld_pubDate = rf.rfld_pubDate
    ,   us.rfld_editDate = rf.rfld_editDate
    from
        @userSettings us join (
                                select 
                                    us1.[user_id] 
                                ,   min(rfd.publish_date) rfld_pubDate
                                ,   max(rfd.update_date) rfld_editDate
                                from    
                                    @userSettings us1 left join dbo.tblXlinkRestrictedFields rfd on us1.[user_id] = rfd.[user_id]
                                group by 
                                    us1.[user_id]
                              ) rf on us.[user_id] = rf.[user_id]


    update us
        set us.rfrm_pubDate = rf.rfrm_pubDate
    ,   us.rfrm_editDate = rf.rfrm_editDate
    from
        @userSettings us join (
                                select 
                                    us1.[user_id] 
                                ,   min(rfrm.publish_date) rfrm_pubDate
                                ,   max(rfrm.update_date) rfrm_editDate
                                from    
                                    @userSettings us1 left join dbo.tblXlinkRestrictedForms rfrm on us1.[user_id] = rfrm.[user_id]
                                group by 
                                    us1.[user_id]
                              ) rf on us.[user_id] = rf.[user_id]


    update us
        set us.ul_pubDate = ul.ul_pubdate
    ,   us.ul_editDate = ul.ul_editdate
    ,   us.ul_count = ul.ul_count
	,	us.ul_dirty = case when ul.ul_dirty > 0 then 1 else 0 end
    from
        @userSettings us join (
                                    select
                                        a.[user_id] 
                                    ,   max(a.publish_date)	ul_pubdate
                                    ,   max(a.edit_date) ul_editdate
                                    ,   count(a.userlogin_id) ul_count
									,	sum(a.Dirty) ul_dirty
                                    from (
										    select	
                                                us1.[user_id]
										    ,   ul1.publish_date
										    ,   ul1.edit_date
										    ,   ul1.userlogin_id
										    ,   case when ISNULL(ul1.publish_date,'1/1/2000') < ul1.edit_date then 1 else 0 end Dirty
										    from  
                                                @userSettings us1 join dbo.tblXlinkUserLogins ul1 on us1.[user_id] = ul1.[user_id]
									    ) a
                                    group by 
                                        a.[user_id]
                              ) ul on us.[user_id] = ul.[user_id]



    update us
        set us.ed_pubDate = ed.ed_pubdate
    ,   us.ed_editDate = ed.ed_editdate
    ,   us.ed_count = ed.ed_count
	,	us.ed_dirty = case when ed.ed_dirty > 0 then 1 else 0 end
    from
        @userSettings us join (
                                    select
                                        a.[user_id]
                                    ,   max(a.publish_date)	ed_pubdate
                                    ,   max(a.edit_date) ed_editdate
                                    ,   count(a.efin_id) ed_count
									,	sum(a.Dirty) ed_dirty
                                    from (
										    select	us1.[user_id]
										    ,		ed1.publish_date
										    ,		ed1.edit_date
										    ,		ed1.efin_id
										    ,		case when ISNULL(ed1.publish_date,'1/1/2000') < ed1.edit_date then 1 else 0 end Dirty
										    from	
                                                @userSettings us1 join dbo.tblXlinkEFINDatabase ed1 on us1.[user_id] = ed1.[user_id]
									    ) a
									group by 
                                        a.[user_id]
                              ) ed on us.[user_id] = ed.[user_id]



    update us
        set us.pd_pubDate = pd.pd_pubdate
    ,   us.pd_editDate = pd.pd_editdate
    ,   us.pd_count = pd.pd_count
	,	us.pd_dirty = case when pd.pd_dirty > 0 then 1 else 0 end
    from
        @userSettings us join (
							        select	
                                        a.[user_id]
							        ,   max(publish_date) pd_pubdate
							        ,   max(edit_date) pd_editdate
							        ,   count(preparer_id) pd_count
							        ,   sum(dirty) pd_dirty
							        from(
								            select 
                                                us1.[user_id]
								            ,	pd1.publish_date
								            ,	pd1.edit_date
								            ,	pd1.preparer_id
								            ,	case when ISNULL(pd1.publish_date,'1/1/2000') < pd1.edit_date then 1 else 0 end Dirty
								            from 
                                                @userSettings us1 join dbo.tblXlinkPreparerDatabase pd1 on us1.[user_id] = pd1.[user_id]
    							        ) a 
							        group by 
                                        a.[user_id]
                    ) pd on us.[user_id] = pd.[user_id]

    update us
        set us.rd_pubDate = rd.rd_pubdate
    ,   us.rd_editDate = rd.rd_editdate
    ,   us.rd_count = rd.rd_count
	,	us.rd_dirty = case when rd.rd_dirty > 0 then 1 else 0 end
    from
        @userSettings us join (
                                    select
                                        a.[user_id]
                                    ,   max(publish_date) rd_pubdate
                                    ,   max(update_date) rd_editdate
                                    ,   count(referral_id) rd_count
									,	sum(dirty) rd_dirty
                                    from  (
										    select 
                                                us1.[user_id]
										    ,	rd1.publish_date
										    ,	rd1.update_date
										    ,	rd1.referral_id
										    ,	case when ISNULL(rd1.publish_date,'1/1/2000') < rd1.update_date then 1 else 0 end dirty
										    from 
                                                @userSettings us1 join dbo.tblXlinkReferralDatabase rd1 on us1.[user_id] = rd1.[user_id]
									    ) a
                                    group by 
                                        a.[user_id]
                              ) rd on us.[user_id] = rd.[user_id]



    update us
        set us.usc_pubDate = usc.usc_pubdate
    ,   us.usc_editDate = usc.usc_editdate
    ,   us.usc_count = usc.usc_count
	,	us.usc_dirty = case when usc.usc_dirty > 0 then 1 else 0 end
    from
        @userSettings us join (
                                    select
                                        a.[user_id]
                                    ,   max(publish_date) usc_pubdate
                                    ,   max(update_date) usc_editdate
									,   count(status_id) usc_count
									,	sum(dirty) usc_dirty
                                    from (
										select 
                                            us1.[user_id]
										,   usc1.publish_date
										,   usc1.update_date
										,   usc1.status_id
										,   case when ISNULL(usc1.publish_date,'1/1/2000') < usc1.update_date then 1 else 0 end dirty
										from 
                                            @userSettings us1 join dbo.tblXlinkUserStatusCodes usc1 on us1.[user_id] = usc1.[user_id]
									    ) a
                                    group by 
                                        a.[user_id]
                              ) usc on us.[user_id] = usc.[user_id]

    select
        us.[user_id] 
    ,   us.name
    ,   us.publish_date
    ,   us.edit_date
    ,   us.usersettings_id
	,	us.transmit_type
    ,   us.transmit_password
    ,   case when isnull(us.mgmt_seqno,-1) != isnull(us.cl_mgmt,-2) then 0 else 1 end IsPickedUp
    ,   us.mgmt_seqno managementID
    ,   us.cl_mgmt processedID
    ,	us.hidden
    ,   us.officeSetup_id
    ,   us.officeEditDate
    ,   us.officePublishDate

    ,   us.rfld_pubDate restrictedFieldsPublishDate
    ,   us.rfld_editDate restrictedFieldsEditDate 

    ,   us.rfrm_pubDate restrictedFormsPublishDate
    ,   us.rfrm_editDate restrictedFormsEditDate

    ,	us.ul_pubDate userloginsPublishDate
    ,	us.ul_editDate userloginsEditDate
    ,	us.ul_count userloginsCount
	,	us.ul_dirty userloginsUnpublished

    ,	us.ed_pubDate EROsPublishDate
    ,	us.ed_editDate EROsEditDate
    ,	us.ed_count EROsCount
	,	us.ed_dirty EROsUnpublished

    ,	us.pd_pubDate preparersPublishDate
    ,	us.pd_editDate preparersEditDate
    ,	us.pd_count preparersCount
	,	us.pd_dirty preparersUnpublished

    ,	us.rd_pubDate referralsPublishDate
    ,	us.rd_editDate referralsEditDate
    ,	us.rd_count referralsCount
	,	us.rd_dirty referralsUnpublished

    ,	us.usc_pubDate statusCodesPublishDate
    ,	us.usc_editDate statusCodesEditDate
    ,	us.usc_count statusCodesCount
	,	us.usc_dirty statusCodesUnpublished

    from
        @userSettings us
