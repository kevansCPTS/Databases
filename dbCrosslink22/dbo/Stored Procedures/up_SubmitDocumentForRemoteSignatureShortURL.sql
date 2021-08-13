


CREATE PROCEDURE [dbo].[up_SubmitDocumentForRemoteSignatureShortURL] -- 'testguid', null, null, null, 1, '01-10-2001', '1234', 'LastName1', null, null, '5678'

	@UniqueId			VARCHAR(50)
,	@TaxReturnGUID		VARCHAR(50)
,	@DocumentMIMEType	VARCHAR(20) = 'application/pdf'
,	@DocumentFileName	VARCHAR(50)
	
,	@SignatureTypes		varchar(10)
,	@DateOfBirth		DATETIME
,	@Last4SSN			CHAR(4)
,	@LastName			VARCHAR(100)
,	@FilerEIN			VARCHAR(10) = NULL
,	@BankType			INT = NULL

,	@DocumentData		VARBINARY(MAX)
,	@UserId				VARCHAR(50)
,	@FormType			VARCHAR(4)
,	@ResetExpiration	INT
,	@Is1040				bit = 1
,	@XmlData			xml = NULL
,	@URLStem			VARCHAR(100) OUT

AS
   SET NOCOUNT ON;

DECLARE @urlYear CHAR(2)
DECLARE @ShortURLCode VARCHAR(8)
DECLARE @ShortURL VARCHAR(60)
DECLARE @LongURL VARCHAR(100)

SET @urlYear = RIGHT (DB_NAME(), 2)

-- get long URL
EXEC [dbo].[up_SubmitDocumentForRemoteSignature] @UniqueId, @TaxReturnGUID, @DocumentMIMEType, @DocumentFileName, @SignatureTypes, @DateOfBirth,
	@Last4SSN, @LastName, @FilerEIN, @BankType, @DocumentData, @UserId, @FormType, @ResetExpiration, @Is1040, @XmlData, @URLStem = @LongURL output

-- convert long URL to short URL
EXEC [dbCrosslinkGlobal].[dbo].[up_GenerateShortURL] @LongURL, @urlYear, @ShortURL = @ShortURLCode output


SELECT @ShortURL =
CASE
WHEN PATINDEX('%DEV%', @@SERVERNAME) > 0 THEN  CONCAT('http://devws.petzent.com/urlService/', @ShortURLCode)
WHEN PATINDEX('%QA%', @@SERVERNAME) > 0 THEN @LongURL
WHEN PATINDEX('%PROD%', @@SERVERNAME) > 0 THEN CONCAT('http://sigreq.tax/s/', @ShortURLCode)
END 

SET @URLStem = @ShortURL;
SELECT @URLStem


