
CREATE procedure [dbo].[up_getFranchiseOwners]
    @account     varchar(10)
as 

select distinct fo.*
, case when lsa.UserID is not null then 1 else 0 end hasSubmittedApp 
from dbCrosslinkGlobal..tblUser u
join FranchiseOwner fo on fo.UserID = u.user_id
left join (SELECT *, ROW_NUMBER() OVER(Partition by parentUserID ORDER BY ParentUserid) AS Row_Number from FranchiseChild) fc on fc.ParentUserID = fo.UserID  and fc.Row_Number = 1
left join (select *, ROW_NUMBER() over(PARTITIOn by userid order by userid) as Row_Number from vwLatestSubmittedApplication) lsa on (lsa.UserID = fc.ChildUserID or lsa.UserID = fo.UserID) and lsa.Row_Number = 1
where u.account = @account
order by fo.UserID

--grant exec on up_getFranchiseUsers to public
