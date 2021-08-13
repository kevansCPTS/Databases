
CREATE PROCEDURE [dbo].[upLatestReturns]
-- Add the parameters for the stored procedure here
--@Season AS int
AS
--SET NOCOUNT ON added to prevent extra result sets FROM
--interfering with SELECT statements.

SET NOCOUNT ON;
BEGIN

DECLARE @TblTaxMastMaxVer BIGINT
--DECLARE @NewTblTaxMastMaxVer BIGINT	
DECLARE @TblStaMastMaxVer BIGINT
--DECLARE @NewTblStaMastMaxVer BIGINT
DECLARE @tblReturnMasterMaxVer BIGINT
--DECLARE @NewtblReturnMasterMaxVer BIGINT
DECLARE @Season INT
DECLARE @DateProcessed DATETIME2
DECLARE @ReturnList TABLE (pssn INT,  nRowVer BIGINT , Tablesource NVARCHAR (25));

SET  @Season =  CONVERT(INT,'20'  + RIGHT(DB_NAME(),2)) ;   
SET @DateProcessed = GETDATE();

--Select the Prior Max revisions form Max Revision Table

SELECT  
	@TblTaxMastMaxVer =  tbltaxmast
	, @TblStaMastMaxVer =  tblStamast
	, @tblReturnMasterMaxVer  = tblReturnMaster
FROM tblMaxRowVersion ;

INSERT @ReturnList 
SELECT  Primaryssn pssn , MAX(nRowVer) nRowVer , 'tblReturnMaster' Tablesource  
FROM tblReturnMaster WHERE nRowVer > @tblReturnMasterMaxVer GROUP BY  Primaryssn
UNION
SELECT  pssn , nRowVer , 'tblTaxmast' Tablesource FROM tblTaxmast WHERE nRowVer > @TblTaxMastMaxVer 
UNION
SELECT  pssn , MAX(nRowVer) nRowVer , 'tblStamast' Tablesource FROM tblStamast WHERE nRowVer > @TblStaMastMaxVer GROUP BY pssn

--Reinitiate the variables
SELECT  @TblTaxMastMaxVer =  MAX(nRowVer) FROM @ReturnList WHERE Tablesource = 'tblTaxmast'
SELECT  @TblStaMastMaxVer =  MAX(nRowVer) FROM @ReturnList WHERE Tablesource = 'tblStamast'
SELECT  @tblReturnMasterMaxVer =  MAX(nRowVer) FROM @ReturnList WHERE Tablesource = 'tblReturnMaster'

--SELECT  
--	@NewTblTaxMastMaxVer =  MAX(COALESCE(CASE WHEN Tablesource = 'tblTaxmast' THEN nRowVer END,0)) , 
--	@NewTblStaMastMaxVer = MAX(COALESCE(CASE WHEN Tablesource = 'tblStamast' THEN nRowVer END,0)) ,  
--	@NewtblReturnMasterMaxVer  = MAX(COALESCE(CASE WHEN Tablesource = 'tblReturnMaster' THEN nRowVer END,0))  
--FROM  @ReturnList GROUP BY Tablesource;

IF  @TblTaxMastMaxVer IS NOT NULL
BEGIN
UPDATE tblMaxRowVersion  
SET tbltaxmast =@TblTaxMastMaxVer 
END

IF  @TblStaMastMaxVer IS NOT NULL
BEGIN
UPDATE tblMaxRowVersion 
SET tblStaMast =@TblStaMastMaxVer 
END

IF  @tblReturnMasterMaxVer IS NOT NULL
BEGIN
UPDATE tblMaxRowVersion 
SET tblReturnMaster =@tblReturnMasterMaxVer 
END

UPDATE LR
SET 
	lr.ModifiedDate = @DateProcessed,
	lr.VersionNumber = NMR.nRowVer,
	lr.ReturnVersionCount =  lr.ReturnVersionCount +1,
	lr.ReturnVersionDate = @DateProcessed,
	lr.RebuildRequired = 1

FROM
	dbFetch.dbo.tblLatestReturns LR 
	JOIN 
	(			
	SELECT PSSN, SUM(nRowVer)  nRowVer FROM @ReturnList GROUP BY pssn
	) 
	NMR ON LR.PrimarySSN = NMR.pssn
	AND LR.Season = @Season		

INSERT INTO dbFetch.dbo.tblLatestReturns  
( 
	PrimarySSN
	,Season
	,CreateDate
	,ModifiedDate		
	,VersionNumber
	,ReturnVersionCount --1
	,ReturnVersionDate
	,RebuildRequired --TRUE/1
	,ReturnBuildCount -- ZERO		
)

SELECT  
	NMR.pssn 
	, @Season AS Season
	, @DateProcessed
	, @DateProcessed
	, NMR.nRowVer
	,1
	,@DateProcessed
	,1
	,0		
FROM
(			
	SELECT PSSN, SUM(nRowVer)  nRowVer FROM @ReturnList GROUP BY pssn
) 
NMR  
LEFT JOIN 
	dbFetch.dbo.tblLatestReturns LR ON NMR.pssn = LR.PrimarySSN AND LR.Season = @Season
WHERE  lr.ID IS NULL

END
