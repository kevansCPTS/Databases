-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-04-04
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE up_GetReturnsAfterFetchDateByAccount
CREATE PROCEDURE [dbo].[up_MobileGetPagedReturnsAfterFetchDateByAccount] --'12/02/2016', 'PETZ01', 2017
	@Page int,
	@PageSize int,
	@FetchFrom datetime2(7),
	@Account varchar(8),
	@TaxSeason smallint,
	@Segment int = 1, --1=InProgress; 2=ToSign; 3=Signed
	@SearchString varchar(10) = null
AS

declare @includedAccounts table(
	account varchar(50)
);

declare @userIDs table(
	userID int
);

declare @CalcSuccessCode int = 
		(select mobile_calc_status from reftblMobileCalcStatus where short_desc = 'CALC_SUCCESS')

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

	select * from (
		select 
			ROW_NUMBER() OVER(order by PrimarySSN) as RowNumber
		,	t.PrimarySSN
		,	t.FilingStatus
		,	t.UserID
		,	t.ModifiedDate 
		,	t.PrimaryFirstName
		,	t.PrimaryMiddleInitial
		,	t.PrimaryLastName
		from (
				select 
					rfs.PrimarySSN
				,	rfs.FilingStatus
				,	rfs.UserID
				,	rfs.ModifiedDate		
				,	rm.PrimaryFirstName
				,	rm.PrimaryMiddleInitial
				,	rm.PrimaryLastName
				,	row_number() over(partition by rfs.PrimarySSN, rfs.FilingStatus, rfs.UserID order by rfs.ModifiedDate desc) as rowNum
				from 
					@includedAccounts ia join dbCrosslinkGlobal.dbo.tblUser u on ia.account = u.account
					join dbo.tblReturnFetchStatus rfs on u.[user_id] = rfs.UserID
						and rfs.ModifiedDate > @FetchFrom
					join dbo.tblReturnMaster rm 
						on rm.UserID = rfs.UserID
						and rm.FilingStatus = rfs.FilingStatus
						and rm.PrimarySSN = rfs.PrimarySSN
					--segment filter
					WHERE 
					(@SearchString is null or 
						(@SearchString is not null and RIGHT(rm.PrimarySSN, 4) like '%'+@SearchString+'%')
					)
					and 
					(
						(@segment = 1 and ( --segment = InProgress
							(not exists( --no success app sign state (temporary)
								select 1 from tblAppSignState appss 
									where 
										appss.ssn = rm.PrimarySSN
									and appss.filing_status = rm.FilingStatus
									and appss.user_id = rm.UserID
									and appss.mobile_calc_status = @CalcSuccessCode
							)) and rm.PrimarySSN like '2159712%' -- FOR DEMO
							and not exists(select 1 from tblDocumentForRemoteSigRequest doc 
										join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
									where TaxReturnGUID = rm.[GUID] and SignatureImage is not null) -- not signed
						))
						OR
						(@segment = 2 and ( --segment = ToSign
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
							and rm.PrimarySSN like '2159712%' -- FOR DEMO
						))
						OR
						(@segment = 3 and ( --segment = Signed
							--signed
							exists(select 1 from tblDocumentForRemoteSigRequest doc 
										join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
									where TaxReturnGUID = rm.[GUID] and SignatureImage is not null) -- signed
							and rm.PrimarySSN like '2159712%' -- FOR DEMO
						))
					)

			) t 
		where 
			t.rowNum = 1 --largest ModifiedDate between tblTaxMast and tblReturnMaster
	) t where t.RowNumber between ((@Page - 1) * @PageSize + 1) and (@Page * @PageSize)