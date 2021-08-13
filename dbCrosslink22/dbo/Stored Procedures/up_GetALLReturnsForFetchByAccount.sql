CREATE PROCEDURE [dbo].[up_GetALLReturnsForFetchByAccount] 
	@Account varchar(8)
AS

declare @includedAccounts table(
	account varchar(50)
);

declare @userIDs table(
	userID int
);

	set nocount on

	-- get all accounts
	insert @includedAccounts
		select
			ch.childAccount
		from	
			dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch
		where
			ch.parentAccount = @Account
			and ch.season = 2018
		union select 
			@Account account;
	
	select 
		t.PrimarySSN
	,	t.FilingStatus
	,	t.UserID
	,	t.ChangeID as 'LastChangeID'
	from (
			select 
				rfs.PrimarySSN
			,	rfs.FilingStatus
			,	rfs.UserID
			,	rfs.ChangeID
			,	rfs.ChangeDTTM
			,	row_number() over(partition by rfs.PrimarySSN, rfs.FilingStatus, rfs.UserID order by rfs.ChangeDTTM desc) as rowNum
			from 
				@includedAccounts ia join dbCrosslinkGlobal.dbo.tblUser u on ia.account = u.account
				join dbo.tblFetchSvcRtnStatus rfs on u.[user_id] = rfs.UserID
		) t 
	where 
		t.rowNum = 1 --most recent between tblTaxMast and tblReturnMaster records