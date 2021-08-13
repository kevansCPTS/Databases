
CREATE PROCEDURE [dbo].[up_RemoteDocumentSignature] -- null '791C9781929174A78085E9EE8EE580B4'

	@UniqueId			VARCHAR(50)

AS

IF @UniqueId is NULL BEGIN

	SELECT Doc.UniqueId, Sig.SignatureType, Sig.SignatureImage, Sig.DateCaptured, Doc.UserId, Sig.DateDelivered FROM tblTaxPayerRemoteSignature Sig
	JOIN tblDocumentForRemoteSigRequest Doc ON Sig.DocumentPk = Doc.DocumentPk
	WHERE 
		Sig.SignatureImage IS NOT NULL
		AND Sig.DateDelivered IS NULL

END ELSE BEGIN

	DECLARE @DocumentPk INT = 0

	SELECT @DocumentPk = DocumentPk FROM tblDocumentForRemoteSigRequest
	WHERE UniqueId = @UniqueId

	IF @DocumentPk > 0
	BEGIN
		SELECT Doc.UniqueId, Sig.SignatureType, Sig.SignatureImage, Sig.DateCaptured, Doc.UserId, Sig.DateDelivered FROM tblTaxPayerRemoteSignature Sig
		JOIN tblDocumentForRemoteSigRequest Doc ON Sig.DocumentPk = Doc.DocumentPk
		WHERE Doc.DocumentPk = @DocumentPk
		AND Sig.SignatureImage IS NOT NULL
	END

END
