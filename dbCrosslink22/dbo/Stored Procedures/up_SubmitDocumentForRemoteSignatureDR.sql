

CREATE PROCEDURE [dbo].[up_SubmitDocumentForRemoteSignatureDR] -- 'testguid', null, null, null, 1, '01-10-2001', '1234', 'LastName1', null, null, '5678'

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
,	@URLStem			VARCHAR(100) OUT

AS
   SET NOCOUNT ON;
DECLARE @DocumentPk INT
DECLARE @urlYear CHAR(2)
DECLARE @ShortURLCode VARCHAR(8)
DECLARE @ShortURL VARCHAR(60)
DECLARE @LongURL VARCHAR(100)

SET @urlYear = RIGHT (DB_NAME(), 2)

IF @SignatureTypes = 0
BEGIN
	--RAISERROR ('SignatureType can not be zero.', 0, 1) WITH LOG
	RETURN
END

SELECT @DocumentPk = DocumentPk FROM [dbo].[tblDocumentForRemoteSigRequest] WHERE UniqueId = @UniqueId

IF @DocumentPk is null
BEGIN
	INSERT INTO [dbo].[tblDocumentForRemoteSigRequest] (UniqueId, DocumentData, DocumentMIMEType, DocumentFileName, DateCreated, TaxReturnGUID, UserId, FormType, Is1040)
	VALUES	(@UniqueId, @DocumentData, @DocumentMIMEType, @DocumentFileName, GETDATE(), @TaxReturnGUID, @UserId, @FormType, @Is1040);
	SET @DocumentPk = SCOPE_IDENTITY()
END

declare @i int = 1
declare @SignatureType varchar;

WHILE @i <= LEN(@SignatureTypes)
BEGIN
	set @SignatureType = substring(@SignatureTypes,@i,1)
	IF NOT EXISTS (SELECT DocumentPk FROM [dbo].[tblTaxPayerRemoteSignature] WHERE DocumentPk = @DocumentPk AND SignatureType = @SignatureType)
	BEGIN
		INSERT INTO [dbo].[tblTaxPayerRemoteSignature] (DocumentPk, SignatureType, DateOfBirth, Last4SSN, LastName, FilerEIN, DateExpired, BankType)
		VALUES (@DocumentPk, @SignatureType, @DateOfBirth, @Last4SSN, @LastName, @FilerEIN, DATEADD(HOUR, 36, GETDATE()), @BankType )
	END
	ELSE
	BEGIN
		IF @ResetExpiration = 1
		UPDATE [dbo].[tblTaxPayerRemoteSignature] SET DateExpired = DATEADD(HOUR, 36, GETDATE()) WHERE DocumentPk = @DocumentPk AND SignatureType = @SignatureType
	END
	set @i = @i + 1
END

SELECT @LongURL =
CASE
--WHEN PATINDEX('%DEV%', @@SERVERNAME) > 0 THEN  CONCAT('https://DEVcobrand.petzent.com/signature18/?ty=18&xlink=', @UniqueId, '&sigt=', @SignatureTypes)
WHEN PATINDEX('%DEV%', @@SERVERNAME) > 0 THEN  CONCAT('https://DEVcobrand.petzent.com/signature', @urlYear, '/?ty=',@urlYear, '&xlink=', @UniqueId, '&sigt=', @SignatureTypes)
WHEN PATINDEX('%QA%', @@SERVERNAME) > 0 THEN   CONCAT('https://QAcobrand.petzent.com/signature', @urlYear, '/?ty=',@urlYear, '&xlink=', @UniqueId, '&sigt=', @SignatureTypes)
WHEN PATINDEX('%PROD%', @@SERVERNAME) > 0 THEN CONCAT('https://mytaxofficeportal.com/signature', @urlYear, '/?ty=',@urlYear, '&xlink=', @UniqueId, '&sigt=', @SignatureTypes)
END 

-- convert long URL to short URL
EXEC [dbCrosslinkGlobal].[dbo].[spGenerateShortURL] @LongURL, @ShortURL = @ShortURLCode output

SELECT @ShortURL =
CASE
WHEN PATINDEX('%DEV%', @@SERVERNAME) > 0 THEN  CONCAT('http://devws.petzent.com/urlService/', @ShortURLCode)
WHEN PATINDEX('%PROD%', @@SERVERNAME) > 0 THEN CONCAT('https://sigreq.tax/s/', @ShortURLCode)
END 

SET @URLStem = @ShortURL;
SELECT @URLStem

