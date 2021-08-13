
-- RIVEDG01/tier 42612  
-- RIVEDG01/child 42613 
-- RIVEDG01/main 42614
-- RIVEDG/tier 19564  
-- RIVEDG/child 19565
-- RIVEDG/main 19566

CREATE procedure [dbo].[up_getUserIDDetail] 
    @parentaccount        varchar(8)
,   @userid     int = null
as

declare @season int = dbo.getXlinkSeason()

select us.user_id as UserID
,	us.account as Account
,	case when fo.UserID is not null then fo.UserID else fc.ParentUserID end as TierOwner

from tblUser us
left join dbCrosslinkGlobal..tblCustomerHierarchy ch
on ch.childAccount = us.account
left join FranchiseOwner fo
on fo.UserID = us.user_id
left join FranchiseChild fc
on fc.ChildUserID = us.user_id
where us.user_id = @userid
and ((ch.parentAccount = @parentaccount and ch.season = @season) or us.account = @parentaccount)


