-- =============================================
-- Author:		Michael Langston
-- Create date: 2017-02-13
-- Description:	Intended to run as a scheduled job - deletes taxpayer document data once signatures have been collected
-- =============================================
CREATE PROCEDURE [dbo].[spAutoDeleteDocumentData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Nullify document data when all signatures for a document have been collected
	UPDATE drsr 
		SET drsr.DocumentData = NULL
	FROM 
		dbo.tblDocumentForRemoteSigRequest drsr JOIN (
														SELECT 
															drsr1.DocumentPk
														FROM 
															dbo.tblTaxPayerRemoteSignature trs1	JOIN dbo.tblDocumentForRemoteSigRequest drsr1 ON trs1.DocumentPk = drsr1.DocumentPk
																AND datalength(drsr1.DocumentData) > 0
														GROUP BY  
															drsr1.DocumentPk
														HAVING 
															count(*) - sum(case --expected signatures and collected signatures are equal
																				WHEN trs1.DateDelivered is NOT NULL THEN 1
																				ELSE 0 
																		   end) = 0 
													 ) a ON drsr.DocumentPk = a.DocumentPk
END
