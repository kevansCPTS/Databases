-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-04-04
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE up_GetReturnsAfterFetchDateByAccount
CREATE PROCEDURE [dbo].[up_GetSupplementalReturnsAfterFetchDateByAccount] --'12/02/2016', 'PETZ01', 2017
	@FetchFrom datetime2(7),
	@Account varchar(8),
	@TaxSeason smallint
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
	,	t.ModifiedDate 
	,	t.IsValid
	from (
			select 
				rfs.PrimarySSN
			,	rfs.FilingStatus
			,	rfs.UserID
			,	rfs.ModifiedDate			
			,	ia.isValid
			,	row_number() over(partition by rfs.PrimarySSN, rfs.FilingStatus, rfs.UserID order by rfs.ModifiedDate desc) as rowNum
			from 
				@includedAccounts ia join dbo.tblReturnFetchStatus rfs 
					on ia.UserID = rfs.UserID
					and rfs.ModifiedDate >= @FetchFrom
		) t 
	where 
		t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster