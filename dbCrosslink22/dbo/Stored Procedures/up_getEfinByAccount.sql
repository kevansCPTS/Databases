
CREATE procedure [dbo].[up_getEfinByAccount] --'RIVEDG'
	@account	varchar(8)
as

	set nocount on

	
SELECT EFIN.UserID
,	EFIN.EFIN
,	EFIN.FirstName
,	EFIN.LastName
,	EFIN.SelectedBank
,	EFIN.HoldFlag
,	App.EROTranFee, EFIN.email
,	IsNull(RegStatus.Description, App.Registered) Registered
,	efin.locked
,	efin.EFINType
,	App.EROBankFee
,	efin.HoldNote
,	efin.HoldDate
,	efin.HoldBy
,	vwCustomerSize.CustomerSize
,	App.SBPrepFee
,	App.SBFeeAll
,	efin.AgreeFeeOption
,	efin.RushStatusDesc
,	efin.EfinCard
,	DocPrepFee
,	efin.EfinPrint 
,	EfinProduct2
,	efin.EfinProduct
,   app.NetTranFee
,	efin.EFFee
,	efin.EFFeeAll
FROM 
dbo.efin
INNER JOIN dbCrosslinkGlobal.dbo.tblUser ON EFIN.userID = tblUser.user_ID 
LEFT JOIN dbCrosslinkGlobal.dbo.vwCustomerSize on vwCustomerSize.Account = tblUser.Account 
LEFT JOIN dbo.vwLatestSubmittedApplication App ON App.Efin = efin.Efin AND App.BankID = efin.SelectedBank 
LEFT JOIN dbo.ltblRegistrationStatusDescription RegStatus ON RegStatus.Registered = App.Registered 
WHERE tblUser.account = @account
ORDER BY EFIN.UserID, EFIN.EFIN 



