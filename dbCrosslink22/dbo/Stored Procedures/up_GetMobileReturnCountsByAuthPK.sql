-- =============================================
-- Author:		Langston, Michael
-- Create date: 2017-11-01
-- Description:	Get segmented return counts
-- =============================================
--DROP PROCEDURE up_GetPagedTaxpayerReturnsByAuthPK
CREATE PROCEDURE [dbo].[up_GetMobileReturnCountsByAuthPK] --'12/02/2016', 'PETZ01', 2017
	@user_auth_pk int
AS

	declare @CalcSuccessCode int = 
		(select mobile_calc_status from dbTaxpayer..reftblMobileCalcStatus where short_desc = 'CALC_SUCCESS')
	declare @CUSTOMER_ACCOUNT_TYPE_CODE int =
		(select auth_login_type from dbTaxpayer..reftblAuthLoginType where short_desc = 'CUSTOMER')
	declare @EROID varchar(8) =
		(select ero_id from dbTaxpayer..tblTaxpayerAuth where user_auth_pk = @user_auth_pk)
	declare @EROUserID int =
		(select [user_id] from dbCrosslinkGlobal..tblUser where eroId = @EROID)

	set nocount on

	declare @InProgressCount int = (
		select count(*) from (
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

		) x ) t		--segment filter
		where (
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

	declare @ToSignCount int = (
		select count(*) from (
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

		) x ) t
		where (
				(exists( --we have success app sign state (temporary)
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

	declare @SignedCount int = (
		select count(*) from (
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

		) x ) t
		where (
				exists(select 1 from tblDocumentForRemoteSigRequest doc 
							join tblTaxPayerRemoteSignature rs on doc.DocumentPk = rs.DocumentPk
						where TaxReturnGUID = t.ReturnGUID and SignatureImage is not null) -- signed
		))


select @InProgressCount as 'InProgress', @ToSignCount as 'ToSign', @SignedCount as 'Signed'