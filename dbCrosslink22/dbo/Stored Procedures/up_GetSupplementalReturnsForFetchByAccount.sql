CREATE PROCEDURE [dbo].[up_GetSupplementalReturnsForFetchByAccount]
	@Account varchar(8),
	@ClientID varchar(200)
AS

declare @parentAccount varchar(50) = (
	select distinct ch.parentAccount from dbcrosslinkglobal.dbo.tblCustomerHierarchy ch
		where ch.childAccount = @Account
)

declare @siblingAccounts table (
	account varchar(50)
);

declare @includedAccounts table(
	account varchar(50),
	UserID int,
	isValid bit
);

	insert into @siblingAccounts
	select ch.childAccount from dbcrosslinkglobal.dbo.tblCustomerHierarchy ch
		where ch.parentAccount = @parentAccount

	insert into @includedAccounts
	select u.account, sup.User_ID, 1 from WebserviceSupplementalUserID sup
		join dbcrosslinkglobal.dbo.tblUser u
			on sup.User_ID = u.user_id 

	-- get last change ID
	declare @changeID int = (select Change_ID from WebserviceAccountDiff where account = @Account and ClientId = @ClientID)

	--validate
	update @includedAccounts
	set isValid = 0
	where account <> @parentAccount 
		and account <> @Account 
		and (account not in (select account from @siblingAccounts))

	--select
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
				@includedAccounts ia join dbo.tblFetchSvcRtnStatus rfs 
					on ia.UserID = rfs.UserID
					and rfs.ChangeID > @changeID
		) t 
	where 
		t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster

