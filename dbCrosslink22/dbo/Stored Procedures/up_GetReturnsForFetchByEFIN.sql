CREATE PROCEDURE [dbo].[up_GetReturnsForFetchByEFIN]
	@EFIN varchar(8),
	@ClientID varchar(200)
AS

	set nocount on

	-- get last change ID
	declare @changeID int = (select Change_ID from WebserviceEfinDiff where efin = @EFIN and ClientId = @ClientID)
	
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
				tblFetchSvcRtnStatus rfs
				join tblReturnMaster rm on 
					rfs.PrimarySSN = rm.PrimarySSN
					and
					rfs.UserID = rm.UserID
					and
					rfs.FilingStatus = rm.FilingStatus
					and
					(rm.EFIN = @EFIN or rm.EFIN = '0'+@EFIN) and (@changeID is null or rfs.ChangeID > @changeID)
		) t 
	where 
		t.rowNum = 1 --most recent between tblTaxMast and tblReturnMaster records
		order by t.ChangeID asc