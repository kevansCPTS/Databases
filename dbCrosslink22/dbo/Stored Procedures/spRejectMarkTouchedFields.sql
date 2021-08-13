-- =============================================  
-- Author:  Edvin Eshagh  
-- Create date: 12/20/2012  
-- Description: Update tblReject.touch or MEFerror.touch when a users has   
--    modified the corresponding field in taxbrain or mso; thus,   
--    the error displays from user screen without doing a clac operation  
--  
-- Traceability:  Taxbrain/includes/appFormPrefix.inc ->markTouchedFields()  
--      Taxbrain/includes/values.inc ->markTouchedFields2()  
--  
-- Changes/Update:
--	Tak Leung 04/20/2017
--		Split into 2 separate Stored Procs to handle updates in MSO and Portal
-- 
-- =============================================  
CREATE PROCEDURE [dbo].[spRejectMarkTouchedFields]   
  
 @returnId INT ,         
   
 -- Form filename as identified   
 -- in ltblRejectLocation.filename  
 @filename VARCHAR(50),       
   
 -- Comma delimited form field names as   
 -- identifed in ltblRjectLocaiton.Element  
 @commaDelimitedFieldNames VARCHAR(1000),  
   
 -- Ignore field type preifixes such as  
 -- txt*, cur*, dat*, dod*, phn*, etc  
 -- for fieldname matches  
 @bIgnoreFieldPrefix BIT 
, @touchCount INT OUTPUT  
  
AS  

SET NOCOUNT ON

BEGIN  
  
 DECLARE @TransactionId VARCHAR(12)  
 
 SELECT @TransactionId=RIGHT('000000000000' + CAST( Max(TransactionID) AS VARCHAR), 12)
 FROM tblTransaction WHERE returnId=@returnId  
  
UPDATE dbcrosslink18..tblRejects                           
 SET touched=1                              
 FROM dbcrosslink18..tblRejects RJ                          
 INNER JOIN ltblRejectLocation RL ON RL.RejectCode = CONVERT(char(2), RJ.state_id) + CONVERT(char(4), RJ.form_seq) + CONVERT(char(4), RJ.field_seq)  
 WHERE RJ.user_dcnx =  @TransactionId And rtn_id = @returnId  
   AND RL.filename = @filename    
   AND CASE WHEN @bIgnoreFieldPrefix=1 THEN SUBSTRING(RL.element,4,99) ELSE RL.Element END  
      IN  (SELECT item FROM SplitString( @commaDelimitedFieldNames, ',') )  
  
 -- ********************************************  
 -- If there is a record in tblReject, then  
 -- there will not be a record in MEFError to update.  
 -- Similarly, if there is a record in the MEFError  
 -- there will not be a record in tblReject  
 --  
 IF @@ROWCOUNT > 0 RETURN  
 --  
 -- ********************************************  
  
 UPDATE dbcrosslink18..MEFError                           
 SET touched=1                  
               
 FROM dbcrosslink18..MEFResponse R  
   
 INNER JOIN dbcrosslink18..MEFError E ON E.SubmissionID  = R.SubmissionID   
             AND R.transactionId =  @TransactionId  
               
 INNER JOIN ltblRejectLocation RL ON RL.RejectCode = CONVERT(char(2), E.stateid)   
               + CONVERT(char(4), E.form_seq)   
               + CONVERT(char(4), E.field_seq)  
  
 WHERE R.transactionId =  @TransactionId AND  
    RL.filename = @filename     
   AND CASE WHEN @bIgnoreFieldPrefix=1 THEN SUBSTRING(RL.element,4,99) ELSE RL.Element END  
      IN  (SELECT item FROM SplitString( @commaDelimitedFieldNames, ',') )  
  
END  


