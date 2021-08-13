-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-04-04
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE up_GetReturnsAfterFetchDateByAccount
create PROCEDURE [dbo].[ke_GetReturnsAfterFetchDateByAccount]
	@FetchFrom datetime2(7),
	@Account varchar(50),
	@TaxSeason int
AS
BEGIN

	declare @includedAccounts table(
		account varchar(50)
	);

	declare @siblings table(
		account varchar(50)
	);

	declare @parentAccount varchar(50) = 
		(select parentAccount from dbcrosslinkglobal.dbo.tblCustomerHierarchy 
			where childAccount = @Account
			and season = @TaxSeason)

	declare @userIDs table(
		userID int
	);

	--self
	insert into @includedAccounts select @Account

	--children accounts
	insert into @includedAccounts
	select childAccount from dbCrosslinkGlobal.dbo.tblCustomerHierarchy 
		where parentAccount = @Account
		and season = @TaxSeason

	--sibling
	insert into @siblings
	select childAccount from dbCrosslinkGlobal.dbo.tblCustomerHierarchy where parentAccount = @parentAccount

	--get user IDs belonging to this account or a child
	insert into @userIDs
	select u.user_id from tblUser u
		inner join @includedAccounts a
			on u.account = a.account
	--get supplemental user IDs
	-- supplemental user IDS MUST belong to this account, its parent, or a sibling
	insert into @userIDs
	select supID.User_ID from WebserviceSupplementalUserID supID
		where supID.Account = @Account or supID.Account = @parentAccount
		or supID.Account in (select * from @siblings)

	select PrimarySSN, FilingStatus, t.UserID, ModifiedDate from (
		select 
			row_number() over(partition by PrimarySSN, FilingStatus, rfs.UserID order by ModifiedDate desc) as rowNum
			, PrimarySSN, FilingStatus, rfs.UserID, ModifiedDate 
		from tblReturnFetchStatus rfs
			inner join @userIDs u
				on rfs.UserID = u.userID
	) t 
	where 
		t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster
		and t.ModifiedDate >= @FetchFrom
END