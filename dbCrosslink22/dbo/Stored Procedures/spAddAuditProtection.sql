-- =============================================
-- Author:		Jay Willis
-- Create date: ??
-- Description:	
-- Update: 11/22/2011 added franchise user code - Jay Willis
-- =============================================
Create PROCEDURE [dbo].[spAddAuditProtection] 
	-- Add the parameters for the stored procedure here
	@account varchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare		
@user_id varchar(6),
@seqno int,				
@XMLString varchar(max) = '<xmldata><cmnd>Global</cmnd><AUDF>X</AUDF></xmldata>',
@XMLStringLaunch varchar(max) = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'

	DECLARE cur_rs CURSOR
	FOR
select user_id from tblUser where account in 
(select account from CustomerAgreements where AgreeToProtectionPlus = 1 and Account = @account)

	OPEN cur_rs;
	FETCH NEXT FROM cur_rs INTO @user_id;
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
			BEGIN   
				update tblxlinkusersettings set auto_add_audit_protection = 'X' where user_id = @user_id

				-- get last sequence number and increment by 1
				SELECT @seqno = 0
				SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
				SELECT @seqno = @seqno + 1

				IF @seqno = 1
					BEGIN
						INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
						--select @user_id, @seqno, @XMLStringLaunch
						SELECT @seqno = 2
					END		

				INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) 
				VALUES (' ',@user_id,@seqno, @XMLString)
				--select @user_id, @seqno, @XMLString
			END;
		FETCH NEXT FROM cur_rs INTO @user_id;
	END;
	CLOSE cur_rs;
	DEALLOCATE cur_rs;

END


