
/************************************************************************************************
Name: up_getActiveUsers
Purpose: Procedure to get the Ativation status for the users under a specific account. This 
procedure requires the account and the current season.
Called By:

Parameters: 
 1 @account varchar(8)
 2 @season     int

Result Codes:
 0 success

Author: Jay Willis 01/15/2014

Changes/Update:
    
	JW - 01/15/2014:
		Creation
**************************************************************************************************/
CREATE procedure [dbo].[up_getActiveUsers] 
    @account        varchar(8)
,   @season     int
as

select 
	max(case when itm.prod_cd = 'USTP' then 1 else 0 end) IsActiveFed
,	max(case when itm.prod_cd like 'BUS%' then 1 else 0 end) IsActiveBus
,	us.user_id UserID
,	us.account Account
,	us.fname Fname
,	us.lname Lname
,	us.company CompanyName

from dbCrosslinkGlobal..tblUser us
	left join orders ord on us.account = ord.account 
		and ord.user_id = us.user_id
		and ord.season = @season
		and ord.ord_stat IN ('C', 'A', 'P', 'N')
	left join ord_items itm on itm.ord_num = ord.ord_num
		and (itm.prod_cd = 'USTP' or itm.prod_cd like 'BUS%')
		and itm.qty > 0

where us.account = @account

group by us.user_id, us.account, us.fname, us.lname, us.company
order by us.user_id


