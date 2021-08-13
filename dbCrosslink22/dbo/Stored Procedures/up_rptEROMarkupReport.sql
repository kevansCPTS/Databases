
-- =============================================
-- Author:		Sundeep Brar
-- =============================================
CREATE PROCEDURE [dbo].[up_rptEROMarkupReport]

AS

DECLARE @Season INT
DECLARE @sqlStr NVARCHAR(max)

CREATE TABLE #PriorYear(
	priorEfin					INT
,	priorAddonFee				FLOAT
,	priorCPTSAdminFee			FLOAT
,	priorCPTSAdminEFFee			FLOAT
,	priorEFilesFee				INT
,	priorSBPrepFee				INT
,	priorCheckPrintFee			BIT
,	priorYearBank				VARCHAR(50)
,	priorYearAcks				INT
,	priorYearSubmittedBPs		INT
,	priorYearFundedBPs			INT
,	priorYearExpectedAdminFee	FLOAT
,	priorYearExpectedAdminEFFee	FLOAT
)

CREATE TABLE #CurrentYear(
	accountID			VARCHAR(10)
,	userID				INT
,	efin				INT
,	parentAccount		VARCHAR(10)
,	accountRep			VARCHAR(50)
,	customerSize		VARCHAR(20)
,	vipSize				VARCHAR(20)
,	bank				VARCHAR(50)
,	AddonFee			FLOAT
,	CPTSAdminFee		FLOAT
,	CPTSAdminEFFee		FLOAT
,	eFilesFee			INT
,	SBPrepFee			INT
,	CheckPrintFee		BIT
,	RemoteSig			BIT
,	currentRemoteSigFee	FLOAT
,	UpdatedDate			DATETIME2
,	totalAcks			INT
,	submittedBPs		INT
,	fundedBPs			INT
,	expectedAdminFee	FLOAT
,	expectedAdminEFFee	FLOAT
)

    set nocount on

    SET @Season = right(db_name(),2)

    set @sqlStr = 'exec [dbCrosslink'+CAST(@Season - 1 as varchar)+ '].[dbo].[up_rptEROMarkupReportPriorVersion]'


    insert #priorYear
        exec dbo.sp_executeSql @sqlStr

    insert #currentYear 
        exec [dbo].[up_rptEROMarkupReportCurrentVersion]

    SELECT
	    CY.accountID
    ,	CY.userID
    ,	CY.efin
    ,	CY.parentAccount
    ,	CY.accountRep
    ,	CY.customerSize
    ,	CY.vipSize
    ,	CY.bank
    ,	CY.AddonFee
	,	ISNULL(CY.CPTSAdminFee, 0) CPTSAdminFee
	,	ISNULL(CY.CPTSAdminEFFee, 0) CPTSAdminEFFee
    ,	CY.eFilesFee
    ,	CY.SBPrepFee
    ,	CY.CheckPrintFee
    ,	CY.RemoteSig
    ,	CY.currentRemoteSigFee
	,	CY.UpdatedDate
	,	CY.totalAcks
	,	CY.submittedBPs
	,	CY.fundedBPs
	,	ISNULL(CY.expectedAdminFee, 0) expectedAdminFee
	,	ISNULL(CY.expectedAdminEFFee, 0) expectedAdminEFFee
	,	PY.priorAddonFee
	,	ISNULL(PY.priorCPTSAdminFee, 0) priorCPTSAdminFee
	,	ISNULL(PY.priorCPTSAdminEFFee, 0) priorCPTSAdminEFFee
    ,	PY.priorEFilesFee
    ,	PY.priorSBPrepFee
    ,	PY.priorCheckPrintFee
    ,	PY.priorYearBank
	,	PY.priorYearAcks
	,	PY.priorYearSubmittedBPs
	,	PY.priorYearFundedBPs
	,	ISNULL(PY.priorYearExpectedAdminFee, 0) priorYearExpectedAdminFee
	,	ISNULL(PY.priorYearExpectedAdminEFFee, 0) priorYearExpectedAdminEFFee
    FROM
	    #CurrentYear CY
	    LEFT JOIN #PriorYear PY ON CY.efin = PY.priorEfin
    ORDER BY
	    CY.accountID
    ,	CY.userID
    ,	CY.efin
    ,	CY.bank
    ,	PY.priorAddonFee
    ,	PY.priorEFilesFee
    ,	PY.priorSBPrepFee
    ,	PY.priorCheckPrintFee
    ,	PY.priorYearBank
  


    drop table #PriorYear
    drop table #CurrentYear

