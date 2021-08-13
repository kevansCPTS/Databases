
/************************************************************************************************
Name: up_RejectCounts

Purpose: Get Reject count from portal for a given return

Called by: MSO worksheets.asp

Changes/Update:

*/

CREATE PROCEDURE [dbo].[up_RejectCounts] 
	@return int 
,	@txnId	int

AS  

DECLARE @strReturn varchar(9), @strTxnId varchar(12)

SELECT @strReturn = REPLICATE('0', 9 - LEN(CONVERT(varchar(9),@return))) + CONVERT(varchar(9),@return)
	, @strTxnId = REPLICATE('0', 12 - LEN(CONVERT(varchar(12),@txnId))) + CONVERT(varchar(12),@txnId)

	SELECT 
			( SELECT COUNT(*)
			FROM tblRejects r 
			WHERE
				r.rtn_id = @strReturn
				AND r.user_dcnx = @strTxnId  
			)
			+ ( SELECT COUNT(*)
			FROM MEFErrOR e 
				JOIN MEFResponse r ON e.SubmissionID = r.SubmissionID
				LEFT JOIN MEFResponse r1 ON	r1.returnID = @strReturn
								AND r1.transactionID = ISNULL(@strTxnId,r1.transactionID)
								And r1.recTS = (Select MAX(recTS) FROM MEFResponse 
												WHERE returnId = @strReturn 
												 And transactionID = ISNULL(@strTxnId,r.transactionID)
												 And stateID = r.stateID)
					WHERE r.returnID = @strReturn
					AND r.transactionID = @strTxnId
					AND e.Severity NOT IN ('Alert', 'Processing Delay')
					AND r1.AcceptanceStatus <> 'A'	
		)		
		AS HasRejectError


