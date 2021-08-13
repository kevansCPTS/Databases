

-- =============================================
-- Author:		Steve Trautman
-- Create date: 08/24/2015
-- Description: When the text is sent to the provider, update the sent column to 1, provider_id and provider status for a TextLink message
-- =============================================
CREATE PROCEDURE [dbo].[spTextLinkSentUpdate]
	@pk_textlink_id uniqueidentifier,
	@provider_id uniqueidentifier = NULL,
	@provider_status varchar(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE tblTextLink
	WITH (ROWLOCK)
	SET sent = 1,
		provider_id = COALESCE(@provider_id, provider_id),
		fk_textlink_provider_status_id = COALESCE((SELECT pk_textlink_provider_status_id FROM reftblTextlinkProviderStatus WITH (NOLOCK) WHERE status = @provider_status), fk_textlink_provider_status_id)
	WHERE pk_textlink_id = @pk_textlink_id;
	
    IF @@ROWCOUNT = 0
    BEGIN
		--RAISERROR ('Unknown textlink id.', 12, 1);
		SELECT 1 AS RESULT;
	END
	ELSE
	BEGIN
		SELECT 0 AS RESULT;
	END
END


