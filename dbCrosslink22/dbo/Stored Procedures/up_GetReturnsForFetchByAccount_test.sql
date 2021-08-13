CREATE PROCEDURE [dbo].[up_GetReturnsForFetchByAccount_test] 
	@Account varchar(8),
	@ClientID varchar(200)
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
			and ch.season = 2019
		union select 
			@Account account;

	-- get last change ID
	declare @changeID int = (select Change_ID from WebserviceAccountDiff where account = @Account and ClientId = @ClientID)
	
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
					and (@changeID is null or rfs.ChangeID > @changeID)
		) t 
	where 
		t.rowNum = 1 --most recent between tblTaxMast and tblReturnMaster records
	order by t.ChangeID asc