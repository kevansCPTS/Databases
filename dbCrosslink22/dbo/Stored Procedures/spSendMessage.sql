-- =============================================
-- Author:		Chuck Robertson
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSendMessage]
	@Type		char(1),
	@Account	varchar(8),
	@UserId		int,
	@Message	varchar(250) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @To		varchar(250), @mailProfile char(50), @body1 varchar(max), @Subject varchar(50)
	DECLARE @Season	int
	
	SELECT @To = null, @mailProfile = 'externalCommunication'
	SET @Season = dbo.getXlinkSeason()


	select
	 	@To = case 
			when len(t1.EmailAddress) is null and len(t2.EmailAddress) is null then null 
			when len(t1.EmailAddress) > 0 and len(t2.EmailAddress) > 0 then t1.EmailAddress + ';' + t2.EmailAddress
			else replace(isnull(t1.EmailAddress,'') + ';' + isnull(t2.EmailAddress,''),';','')
		end
	from
		dbCrossLinkGlobal.dbo.SeasonalLeadExecutive sle left join dbcrosslinkglobal.dbo.logins l1 on sle.LeadExec = l1.initials
		left join dbcrosslinkglobal.dbo.logins l2 on sle.SupportExec = l2.initials
		left join peiSupport.dbo.Tech t1 on l1.[login] = t1.XLinkDBLogin
		left join peiSupport.dbo.Tech t2 on l2.[login] = t2.XLinkDBLogin
	where
		sle.Season = @Season
		and sle.AccountCode = @Account
	
	-- Build the email string.
	IF @Type = 'N'
	BEGIN
		SELECT @body1 = 'Good Morning,<BR><BR>' 
			+ 'This is an automated message to inform you that a new User Id (' 
			+ rtrim(convert(char(6), @UserId)) + ') has been created under Account (' + @Account + ').', @Subject = 'New User Id Generated'
	END
	ELSE IF @Type = 'O'
	BEGIN
		SELECT @body1 = 'Good Morning,<BR><BR>This is an automated message to inform that the following occurred for User Id (' + convert(varchar(6), @UserId)
			+ ') under Account (' + @Account + ').<BR><BR>' + @Message, @Subject = 'New Order Generated'
	END

	-- If the only email found is the generic support email, add this text to the body.
	if @To is null
		begin
			select
				@To = t.EmailAddress
			from
				PEISupport.dbo.Tech t
			where 
				t.TechLogin = 'support'
				and t.Active = 1
	
			if @To is null
				set @To = 'support@petzent.com'

			set @body1 = 'Support Team,<BR><BR>'
				+ 'The portal has generated the customer notification below, but there does not appear to be a sales executive registered to receive notifications for this account.<BR><BR>'  
				+ 'Please alert the Sales Department of this missing executive assignment.<BR><BR>'
				+ 'Thank you.<BR><BR><BR><BR>'
				+ @body1

			if @@SERVERNAME != 'PRODDBA'
				set @body1 = '######################### Testing Testing Testing ... Please disregard #########################<BR>'
					+ '######################### Testing Testing Testing ... Please disregard #########################<BR>'
					+ '######################### Testing Testing Testing ... Please disregard #########################<BR><BR><BR><BR>'
					+ @body1
		end	


	-- Send an email about invalid transaction.
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name=@mailProfile,
		@recipients= @To,
		@body= @body1,
		@body_format='HTML',
		@subject = @Subject
END








