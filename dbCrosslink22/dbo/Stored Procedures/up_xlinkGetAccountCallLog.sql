/************************************************************************************************
Name: up_xlinkGetAccountCallLog

Purpose: This procedure was an alternative to a LINQ query to conditionally pull the desired 
user and log information. To optimize this call, the following index changes were also made:
    
    dbCrosslinkGlobal.dbo.tblUser - Removed cluster attribute from the primary key (User_ID).
                                  - Added cluster attribute to the index on the 'account' field.

    dbCrosslink12.dbo.call_log - Removed cluster attribute from the primary key (seq_num).
                               - Added a clustered index on the 'user_id' field.


Called By:

Parameters: 
 1 @account    varchar(8)
 2 @userId     int             = null

Result Codes:
 0 success

Author: Ken Evans 07/23/2012

Changes/Update:
    None.
    Jay Willis 01/31/2013 changed format of ver 
    from:
	isnull(REPLACE(LEFT(a.ver, 3),'3','13') + '.' + RIGHT(a.ver, 2 + LEN(a.ver) - 5),'N/A') ver
	to:
	isnull(LEFT(a.ver, LEN(a.ver) - 2) + '.' + RIGHT(a.ver, 2),'N/A') ver

**************************************************************************************************/

CREATE procedure [dbo].[up_xlinkGetAccountCallLog] --'PETZ01',40
    @account    varchar(8)
,   @userId     int             = null
as


set nocount on

    if (@userId is null)
        -- When the @userId is not passed, the list of users that are NOT franchise owners or children for the given account.
        select
            a.[User_Id]
        ,   a.company
        ,   isnull(a.passwd,'(none)') passwd
        ,   a.seq_no
        ,   isnull(REPLACE(LEFT(a.ver, 3),'3','13') + '.' + RIGHT(a.ver, 2 + LEN(a.ver) - 5),'N/A') ver
        ,   a.dt_dd
        ,   a.dt_hh
        ,   a.dt_mi
        ,   a.dt_mm
        ,   ISNULL(a.dt_mm + '/' + a.dt_dd + '-' + a.dt_hh + ':' + a.dt_mi,'N/A') [time]
        from
            (
            select 
                u.[user_id]
            ,   u.company
            ,   u.passwd
            ,   cl.ver
            ,   cl.dt_dd
            ,   cl.dt_hh
            ,   cl.dt_mi
            ,   cl.dt_mm
            ,   cl.seq_no
            ,   row_number() over ( partition by u.[user_id] order by isnull(cl.seq_no,1) desc) AS 'RowNumber' 
            from 
                dbCrosslinkGlobal.dbo.tblUser u left join FranchiseOwner fo on u.[user_id] = fo.UserID 
                left join FranchiseChild fc on u.[user_id] = fc.ChildUserID 
                left join dbo.call_log cl on u.[user_id] = cl.[user_id]
            where 
                u.account = @account
                --and fo.UserID is null 
                --and fc.ChildUserID is null
            ) a
        where
            a.RowNumber = 1

    else
        -- Otherwise, the list of users that are only franchise owners or children for the given account.
        select
            a.[User_Id]
        ,   a.company
        ,   isnull(a.passwd,'(none)') passwd
        ,   a.seq_no
        ,   isnull(REPLACE(LEFT(a.ver, 3),'3','13') + '.' + RIGHT(a.ver, 2 + LEN(a.ver) - 5),'N/A') ver
        ,   a.dt_dd
        ,   a.dt_hh
        ,   a.dt_mi
        ,   a.dt_mm
        ,   ISNULL(a.dt_mm + '/' + a.dt_dd + '-' + a.dt_hh + ':' + a.dt_mi,'N/A') [time]
        from
            (
            select 
                u.[user_id]
            ,   u.company
            ,   u.passwd
            ,   cl.ver
            ,   cl.dt_dd
            ,   cl.dt_hh
            ,   cl.dt_mi
            ,   cl.dt_mm
            ,   cl.seq_no
            ,   row_number() over ( partition by u.[user_id] order by isnull(cl.seq_no,1) desc) AS 'RowNumber' 
            from 
                dbCrosslinkGlobal.dbo.tblUser u join (
                                                        select
                                                            ChildUserID UserId
                                                        from
                                                            FranchiseChild 
                                                        where
                                                            ParentUserID = @userId
                                                        union select
                                                            UserID
                                                        from
                                                            FranchiseOwner fo
                                                        where
                                                            UserID = @userId
                                                      ) fou on u.[user_id] = fou.UserId



                left join dbo.call_log cl on u.[user_id] = cl.[user_id]
            ) a
        where
            a.RowNumber = 1





/*
select
    fo.*
from 
    dbCrosslinkGlobal.dbo.tblUser u join FranchiseOwner fo on u.[user_id] = fo.UserID
        and u.account = 'PETZ01'     

    
UserID	FranchiseName	FranchiseSBFee
7777	BRIAN M TEST	0.00
22	MIKE	22.00
24	IUG	0.00
31	MIKE	22.00
37	MIKE	12.00
40	ITS TIER TEST	1.00
26524	JOHN TESTER	20.00
26658	MY OFFICE 2	25.00
23057	BRIANS TAX OFFICE	25.00
23062	NEW TEST	12.00
26561	DEANNA TAX	0.00
*/





