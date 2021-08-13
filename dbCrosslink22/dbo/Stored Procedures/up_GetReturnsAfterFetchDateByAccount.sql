-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-04-04
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE up_GetReturnsAfterFetchDateByAccount
CREATE PROCEDURE [dbo].[up_GetReturnsAfterFetchDateByAccount] --'12/02/2016', 'PETZ01', 2017
	@FetchFrom datetime2(7),
	@Account varchar(8),
	@TaxSeason smallint
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
			and ch.season = @TaxSeason
		union select 
			@Account account;


	select 
		t.PrimarySSN
	,	t.FilingStatus
	,	t.UserID
	,	t.ModifiedDate 
	,	cast(1 as bit) as 'IsValid'
	from (
			select 
				rfs.PrimarySSN
			,	rfs.FilingStatus
			,	rfs.UserID
			,	rfs.ModifiedDate			
			,	row_number() over(partition by rfs.PrimarySSN, rfs.FilingStatus, rfs.UserID order by rfs.ModifiedDate desc) as rowNum
			from 
				@includedAccounts ia join dbCrosslinkGlobal.dbo.tblUser u on ia.account = u.account
				join dbo.tblReturnFetchStatus rfs on u.[user_id] = rfs.UserID
					and rfs.ModifiedDate > @FetchFrom
		) t 
	where 
		t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster