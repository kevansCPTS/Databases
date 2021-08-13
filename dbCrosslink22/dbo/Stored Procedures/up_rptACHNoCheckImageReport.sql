
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 06/04/2020
-- Description:	Stored procedure for inteneral report > customer support report > ACH No Check Image Report
-- =============================================
CREATE PROCEDURE [dbo].[up_rptACHNoCheckImageReport]

AS

BEGIN
	declare @season smallint
	set @season = '20' + right(db_name(),2)

	select
		cach.Account
	,	cach.Season
	,	cach.ACHActive
	,	cach.ACHBankName
	,	cach.ACHRoutingNumber
	,	cach.ACHAccountNumber
	,	cach.ACHAccountType
	,	cach.ACHAccountName
	,	cach.CheckImage
	,	cach.CreatedDate
	,	cach.CreatedBy
	,	cach.ModifiedDate
	,	cach.ModifiedBy
	,	case cach.ACHAccountType 
			when 'C' then 'Checking' 
			when 'S' then 'Saving'
			else 'Other'
		end ACHAccountTypeChecked
	from
		dbCrosslinkGlobal.dbo.tblCustomerACH cach
	where
		cach.Season = @season 
        and cach.ACHActive = 1 
        and cach.CheckImage is null

END

