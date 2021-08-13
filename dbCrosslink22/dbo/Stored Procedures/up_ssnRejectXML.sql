

CREATE procedure [dbo].[up_ssnRejectXML] 
	@v_pssn int
--,   @oXml varchar(max) output
as
 
DECLARE @v_SubmissionID varchar(20)
DECLARE @v_schema_version varchar(50)
DECLARE @v_SubmissionTyp varchar(6)
DECLARE @v_MEFErrorCount int
declare @taxYear smallint

    set nocount on

    set @taxYear = '20' + right(db_name(),2) - 1

    SELECT @v_SubmissionID = SubmissionID
          ,@v_schema_version = schema_version
	      ,@v_SubmissionTyp =
	         (CASE FORM_TYPE_1040
	               WHEN 1 THEN '1040A'
		           WHEN 2 THEN '1040EZ'
		           WHEN 3 THEN '1040NR'
		           WHEN 4 THEN '1040SS'
		      ELSE '1040'
		      END)
	       from tblTaxmast where pssn = @v_pssn
    select v_MEFErrorCount = count(*) from MEFError where SubmissionID = @v_SubmissionID

/*
set @oXml = convert(varchar(max),(select RTRIM(@v_schema_version) AS [@submissionVersionNum]
      ,RTRIM(@v_schema_version) AS "@validatingSchemaVersionNum"
      ,RTRIM(r.SubmissionID) AS "SubmissionId"
      ,SUBSTRING(r.SubmissionID,1,6) AS "EFIN"
      ,'2018' AS "TaxYr"
      ,'IRS' AS "ExtndGovernmentCd"
      ,@v_SubmissionTyp AS "SubmissionTyp"
      ,'IND' AS "ExtndSubmissionCategoryCd"
      ,RTRIM(r.Postmark)+'8:00' AS "ElectronicPostmarkTs"
      ,'Rejected' AS "AcceptanceStatusTxt" -- Convert Code to text
      ,'false' AS "ContainedAlertsInd" -- Count to text
      ,SUBSTRING(r.StatusDate,1,4)+'-'+SUBSTRING(r.StatusDate,5,2)+'-'+SUBSTRING(r.StatusDate,7,2) AS "StatusDt"
      ,RTRIM(r.primid) AS "TIN"
      ,'2018-12-31' AS "TaxPeriodEndDt"
      ,'true' AS "SubmissionValidationCompInd"
----  ,'????' AS "EmbeddedCRC32Num"
----  ,'????' AS "ComputedCRC32Num"
      ,RTRIM(r.ExpectedRefund) AS "ExpectedRefundAmt"
      ,RTRIM(r.DOBCode) AS "BirthDtValidityCd"
	  ,@v_MEFErrorCount AS "ValidationErrorList/@errorCnt"

	  ,(select e.ErrorID AS "@errorId"
              ,RTRIM(e.DocumentID) AS "DocumentId"
              ,RTRIM(e.XPath) AS "XpathContextTxt"
              ,RTRIM(e.ErrorCategory) AS "ErrorCategoryCd"
              ,RTRIM(e.ErrorMessage) AS "ErrorMessageTxt"
              ,RTRIM(e.RuleNumber) AS "RuleNum"
              ,RTRIM(e.Severity) AS "SeverityCd"
              ,RTRIM(e.DataValue) AS "FieldValueTxt"
        from MEFError e where e.SubmissionID = r.SubmissionID
		     FOR XML PATH ('ValidationErrorGrp'), TYPE) AS [ValidationErrorList]
    from MEFResponse r
        where r.SubmissionID = @v_SubmissionID
	    FOR XML PATH ('Acknowledgement'), TYPE))
*/


select convert(varchar(max),(select RTRIM(@v_schema_version) AS "@submissionVersionNum"
      ,RTRIM(@v_schema_version) AS "@validatingSchemaVersionNum"
      ,RTRIM(r.SubmissionID) AS "SubmissionId"
      ,SUBSTRING(r.SubmissionID,1,6) AS "EFIN"
      ,@taxYear AS "TaxYr"
      ,'IRS' AS "ExtndGovernmentCd"
      ,@v_SubmissionTyp AS "SubmissionTyp"
      ,'IND' AS "ExtndSubmissionCategoryCd"
      ,RTRIM(r.Postmark)+'8:00' AS "ElectronicPostmarkTs"
      ,'Rejected' AS "AcceptanceStatusTxt" -- Convert Code to text
      ,'false' AS "ContainedAlertsInd" -- Count to text
      ,SUBSTRING(r.StatusDate,1,4)+'-'+SUBSTRING(r.StatusDate,5,2)+'-'+SUBSTRING(r.StatusDate,7,2) AS "StatusDt"
      ,RTRIM(r.primid) AS "TIN"
      ,@taxYear + '-12-31' AS "TaxPeriodEndDt"
      ,'true' AS "SubmissionValidationCompInd"
----  ,'????' AS "EmbeddedCRC32Num"
----  ,'????' AS "ComputedCRC32Num"
      ,RTRIM(r.ExpectedRefund) AS "ExpectedRefundAmt"
      ,RTRIM(r.DOBCode) AS "BirthDtValidityCd"
	  ,@v_MEFErrorCount AS "ValidationErrorList/@errorCnt"

	  ,(select e.ErrorID AS "@errorId"
              ,RTRIM(e.DocumentID) AS "DocumentId"
              ,RTRIM(e.XPath) AS "XpathContextTxt"
              ,RTRIM(e.ErrorCategory) AS "ErrorCategoryCd"
              ,RTRIM(e.ErrorMessage) AS "ErrorMessageTxt"
              ,RTRIM(e.RuleNumber) AS "RuleNum"
              ,RTRIM(e.Severity) AS "SeverityCd"
              ,RTRIM(e.DataValue) AS "FieldValueTxt"
        from MEFError e where e.SubmissionID = r.SubmissionID
		     FOR XML PATH ('ValidationErrorGrp'), TYPE) AS [ValidationErrorList]
    from MEFResponse r
        where r.SubmissionID = @v_SubmissionID
	    FOR XML PATH ('Acknowledgement'), TYPE))  rejectXml

