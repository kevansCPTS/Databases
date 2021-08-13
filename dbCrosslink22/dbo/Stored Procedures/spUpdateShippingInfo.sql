-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateShippingInfo]
		@Account		varchar(8),
		@UserID			int,
		@Contact		varchar(34),
		@CPhone			varchar(10),
		@Fax			varchar(10),
		@Company		varchar(34),
		@Address		varchar(34),
		@City			varchar(20),
		@State			varchar(2),
		@Zip			varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE	dbCrossLinkGlobal..tblUser
	SET		contact = @Contact,
			c_phone = @CPhone,
			fax = @Fax,
			company = @Company,
			addr1 = @Address,
			city = @City,
			state = @State,
			zip = @Zip
	WHERE	account = @Account
	AND		user_id = @UserID
END


