-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-04-04
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE up_MobileGetReturnCountsAfterFetchDateByAccount
CREATE PROCEDURE [dbo].[up_MobileGetReturnCountsAfterFetchDateByAccount] --'12/02/2016', 'PETZ01', 2017
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

	declare @CalcSuccessCode int = 
		(select mobile_calc_status from reftblMobileCalcStatus where short_desc = 'CALC_SUCCESS')

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

	declare @allReturns table(
		PrimarySSN int,
		UserID int,
		FilingStatus int
	);

	insert into @allReturns
	select 
		 t.PrimarySSN
		,t.UserID
		,t.FilingStatus
	from (
			select 
				rfs.PrimarySSN
			,	rfs.FilingStatus
			,	rfs.UserID		
			,	row_number() over(partition by rfs.PrimarySSN, rfs.FilingStatus, rfs.UserID order by rfs.ModifiedDate desc) as rowNum
			from 
				@includedAccounts ia join dbCrosslinkGlobal.dbo.tblUser u on ia.account = u.account
				join dbo.tblReturnFetchStatus rfs on u.[user_id] = rfs.UserID
		) t 
	where 
		t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster)

	declare @allCount int = (select COUNT(1) from @allReturns)
	declare @toSignCount int;
	declare @signedCount int;
	declare @weirdCount int;
	declare @inProgressCount int;

	select @inProgressCount = COUNT(1) from @allReturns ar
		join dbo.tblReturnMaster rm
			on rm.UserID = ar.UserID
				and rm.FilingStatus = ar.FilingStatus
				and rm.PrimarySSN = ar.PrimarySSN		
		Where 
			(not exists( --no success app sign state (temporary)
				select 1 from tblAppSignState appss 
					where 
						appss.ssn = rm.PrimarySSN
					and appss.filing_status = rm.FilingStatus
					and appss.user_id = rm.UserID
					and appss.mobile_calc_status = @CalcSuccessCode
			))
			and not exists(select 1 from tblDocumentForRemoteSigRequest doc 
						join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
					where TaxReturnGUID = rm.[GUID] and SignatureImage is not null) -- not signed

	select @toSignCount = COUNT(1) from @allReturns ar
		join dbo.tblReturnMaster rm 
			on rm.UserID = ar.UserID
				and rm.FilingStatus = ar.FilingStatus
				and rm.PrimarySSN = ar.PrimarySSN
		Where 
			(exists( --we have success app sign state (temporary)
				select 1 from tblAppSignState appss 
					where 
						appss.ssn = rm.PrimarySSN
					and appss.filing_status = rm.FilingStatus
					and appss.user_id = rm.UserID
					and appss.mobile_calc_status = @CalcSuccessCode
			))
			and not exists(select 1 from tblDocumentForRemoteSigRequest doc 
						join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
					where TaxReturnGUID = rm.[GUID] and SignatureImage is not null) -- not signed

	select @signedCount = COUNT(1) from @allReturns ar
		join dbo.tblReturnMaster rm 
			on rm.UserID = ar.UserID
				and rm.FilingStatus = ar.FilingStatus
				and rm.PrimarySSN = ar.PrimarySSN
				and exists(select 1 from tblDocumentForRemoteSigRequest doc 
						join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
					where TaxReturnGUID = rm.[GUID] and SignatureImage is not null) -- is signed

	select 
			@allCount as 'All'
		,	@toSignCount as 'ToSign'
		,	@inProgressCount as 'InProgress'
		,	@signedCount as 'Signed'