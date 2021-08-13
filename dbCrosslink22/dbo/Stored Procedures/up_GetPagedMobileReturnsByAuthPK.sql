-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-11-01
-- Description:	Get return keys that have been modified after a given date
-- =============================================
--DROP PROCEDURE [dbo].[up_GetPagedMobileReturnsByAuthPK]
CREATE PROCEDURE [dbo].[up_GetPagedMobileReturnsByAuthPK]
	@Page int,
	@PageSize int,
	@user_auth_pk int,
	@Segment int = 1, --1=InProgress; 2=ToSign; 3=Signed
	@SearchString varchar(10) = null
AS

	declare @CalcSuccessCode int = 
		(select mobile_calc_status from reftblMobileCalcStatus where short_desc = 'CALC_SUCCESS')
	declare @CUSTOMER_ACCOUNT_TYPE_CODE int =
		(select auth_login_type from dbTaxpayer..reftblAuthLoginType where short_desc = 'CUSTOMER')
	declare @EROID varchar(8) =
		(select ero_id from dbTaxpayer..tblTaxpayerAuth where user_auth_pk = @user_auth_pk)
	declare @EROUserID int =
		(select [user_id] from dbCrosslinkGlobal..tblUser where eroId = @EROID)
	set nocount on

	select * from (
		select *, ROW_NUMBER() OVER(order by PrimarySSN) as 'RowNumber' from (
			select --returnmaster results with no tblTaxpayer
				rm.PrimarySSN as 'PrimarySSN'
			,	rm.FilingStatus as 'FilingStatus'
			,	NULL as 'TaxpayerID'
			,	NULL as 'ReturnID'
			,	rm.PrimaryFirstName as 'PrimaryFirstName'
			,	rm.PrimaryMiddleInitial as 'PrimaryMiddleInitial'
			,	rm.PrimaryLastName as 'PrimaryLastName'
			,	rm.GUID	as 'ReturnGUID'
			from 
				dbo.tblReturnMaster rm 
				where UserID = @EROUserID
					and not exists(select 1 from dbTaxpayer..tblTaxpayer where ssn = rm.PrimarySSN)
			union(
				select --tblTaxpayer results that may or may not have tblReturnMaster
						tp.ssn as 'PrimarySSN'
					,	ret.filingStatusId as 'FilingStatus'
					,	tp.tpId as 'TaxpayerID'
					,	ret.retId as 'ReturnID'
					,	tp.fName as 'PrimaryFirstName'
					,	tp.mName as 'PrimaryMiddleInitial'
					,	tp.lName as 'PrimaryLastName'
					,	rm.GUID as 'ReturnGUID'
					from dbTaxpayer..tblTaxpayer tp 
						join dbTaxpayer..tblTaxpayerReturn ret 
							on tp.tpId = ret.tpId and tp.user_auth_pk = @user_auth_pk
						left join dbo.tblReturnMaster rm --for signature detection
							on rm.UserID = @EROUserID
							and rm.FilingStatus = ret.filingStatusId
							and rm.PrimarySSN = tp.ssn
			)

		) t		--segment filter
		WHERE 
		(@SearchString is null or 
			(@SearchString is not null and RIGHT(t.PrimarySSN, 4) like '%'+@SearchString+'%')
			or
			(@SearchString is not null and t.PrimaryFirstName like '%'+@SearchString+'%')
			or
			(@SearchString is not null and t.PrimaryLastName like '%'+@SearchString+'%')
		)
		and 
		(
			(@segment = 1 and ( --segment = InProgress
				(not exists( --no success app sign state
					select 1 from tblAppSignState appss 
						where 
							appss.ssn = t.PrimarySSN
						and appss.filing_status = t.FilingStatus
						and appss.user_id = @EROUserID
						and appss.mobile_calc_status = @CalcSuccessCode
				)) 
				and not exists(select 1 from tblDocumentForRemoteSigRequest doc 
							join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
						where TaxReturnGUID = t.ReturnGUID and SignatureImage is not null) -- not signed
			))
			OR
			(@segment = 2 and ( --segment = ToSign
				(exists( --we have success app sign state 
					select 1 from tblAppSignState appss 
						where 
							appss.ssn = t.PrimarySSN
						and appss.filing_status = t.FilingStatus
						and appss.user_id = @EROUserID
						and appss.mobile_calc_status = @CalcSuccessCode
				))
				and not exists(select 1 from tblDocumentForRemoteSigRequest doc 
							join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
						where TaxReturnGUID = t.ReturnGUID and SignatureImage is not null) -- not signed
			))
			OR
			(@segment = 3 and ( --segment = Signed
				--signed
				exists(select 1 from tblDocumentForRemoteSigRequest doc 
							join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
						where TaxReturnGUID = t.ReturnGUID and SignatureImage is not null) -- signed
			))
		)
	) t where t.RowNumber between ((@Page - 1) * @PageSize + 1) and (@Page * @PageSize)

