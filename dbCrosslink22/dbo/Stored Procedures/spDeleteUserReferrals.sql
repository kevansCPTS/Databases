-- =============================================
-- Author:		Jay Willis
-- Create date: 10/31/2012
-- Description:	
-- =============================================
create PROCEDURE [dbo].[spDeleteUserReferrals] 
	-- Add the parameters for the stored procedure here
	@referral_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@seqno int,
		@seq_num varchar(3),
		@XMLString xml,
		@XMLStringLaunch xml

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkReferralDatabase WHERE referral_id = @referral_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	SELECT 
	@seq_num = ISNULL(seq_num, '')
	FROM tblXlinkReferralDatabase
	WHERE referral_id = @referral_id 

	SELECT @XMLString = '<xmldata><cmnd>ReferralsDel</cmnd>
	<D001>' + RIGHT('000' + ISNULL(@seq_num, ''), 3) + '</D001>
	</xmldata>'

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

END




