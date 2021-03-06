-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSendPasswordReset]
	-- Add the parameters for the stored procedure here
	@Account	varchar(8),
	@URL		varchar(80)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @mailProfile varchar(50), @body1 varchar(max), @Link varchar(max)
	DECLARE @Username varchar(8), @Email varchar(80)
	DECLARE @id AS varchar(max)
	

	SET @ID = NEWID();

	SELECT @mailProfile = 'externalCommunication'

	SELECT @Link = 'https://' + @URL + '/crosslink/support/resetpassword.asp?id=' + @ID
	IF ISNUMERIC(@account) = 1
	Begin
		SELECT @Email = email FROM tbluser WHERE user_id = @account;
	End
	ELSE
	Begin
		SELECT @Email = email FROM customer WHERE account = @account;
	End
	SELECT @body1 = '<style media="screen" type="text/css">TD IMG {DISPLAY: block}</style><center><table cellPadding="0" cellSpacing="0" border="0" bgColor="#ffffff" height="100%" width="100%"><tbody><tr><td align="center" height="100%"><table cellPadding="0" cellSpacing="0" border="0" width="601"><tbody><tr vAlign="top"><td colSpan="3" height="1" width="601"><img border="0" src="http://208.69.42.99/email/2010-03-17/blank.gif" height="1" width="1" /></td></tr><tra vAlign="top"></tra><tr><td colSpan="3" width="601"><a target="_blank" href="http://www.crosslinktax.com/about/contact_us.asp" title="CrossLink Customer Service"><img border="0" src="https://www1.vtrenz.net/imarkownerfiles/ownerassets/2165/Email_Header_CustomerService_v4-1.jpg" height="145" width="601" /></a></td></tr><tr vAlign="top"><td colSpan="3" width="601"><img border="0" src="http://208.69.42.99/email/2010-03-17/blank.gif" height="10" width="1" /></td></tr><tr vAlign="top"><td align="left" width="312"><p style="margin: 0px 0px 4px"><font style="line-height: 24px; font-family: Arial,sans-serif; font-size: 18px" size="2" face="Arial, sans-serif" color="#000000">You Have Requested to Reset Your Password</font>&nbsp; </p><p style="margin: 0px 0px 16px"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif">We have received your request to reset your CrossLink password by email. Follow the instructions below to reset your password.</font></font><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><br /><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif">&nbsp;</font></font></font> </p><p style="margin: 0px 0px 16px"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif" color="#ff0000"><strong>TO RESET YOUR PASSWORD:</strong></font> </font><p style="text-indent: -21pt; margin: 0in 0in 0pt 21pt" class="msolistparagraphcxsplast"><span><font face="arial,helvetica,sans-serif"><span><span size="2" face="Arial, sans-serif" color="#000000" style="font-family: Arial,sans-serif; font-size: 12px">&nbsp;&nbsp;&nbsp;1.<span></span><span style="font-size: 12px"><font size="2">&nbsp;&nbsp;</font></span></span></span><font size="2"><span>Click on the link below and follow the instructions on the page; or</span> </font></font></span></p><br /><p style="text-indent: -21pt; margin: 0in 0in 0pt 21pt" class="msolistparagraphcxsplast"><span><font face="arial,helvetica,sans-serif"><span><span size="2" face="Arial, sans-serif" color="#000000" style="font-family: Arial,sans-serif; font-size: 12px">&nbsp;&nbsp;&nbsp;2.<span></span><span style="font-size: 12px"><font size="2">&nbsp;&nbsp;</font></span></span></span><font size="2"><span>Copy and paste the below Internet address into your Internet browser address bar. Press Enter or Return on your keyboard, then follow the instructions on the page.</span> </font></font></span></p><br /><a href="'+ @Link +'">'+ @Link +'</a></font></p><br /><p style="margin: 0px 0px 16px"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif">Sincerely,</font></font><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"></font> </p><p style="margin: 0px 0px 16px"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif">Your CrossLink Team</font></font><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"></font> </p></td><td width="20">&nbsp;</td><td align="left" width="269"><table cellPadding="0" cellSpacing="0" border="0" bgColor="#efefef" width="269"><tbody><tr vAlign="top"><td colSpan="5" height="5" width="269"><img src="http://208.69.42.99/email/2010-03-17/box_top.png" height="5" width="269" /></td></tr><tr vAlign="top"><td bgColor="#c9c9c9" width="1"><img src="http://208.69.42.99/email/2010-03-17/blank.gif" height="1" width="1" /></td><td bgColor="#efefef" width="4"><img src="http://208.69.42.99/email/2010-03-17/blank.gif" height="1" width="4" /></td><td bgColor="#efefef" align="left" width="259"><p style="margin: 0px 0px 16px"><a target="_blank" href="http://www.crosslinktax.com/features/default.asp" title="CrossLink Features"></a><img src="https://www1.vtrenz.net/imarkownerfiles/ownerassets/2165/email_blackbar_custserv.gif" /> </p><p style="margin: 0px 0px 16px"><font style="line-height: 18px; font-family: Arial,sans-serif; font-size: 12px" size="3" face="Arial, sans-serif" color="#000000"><font size="2" face="arial,helvetica,sans-serif">If you have questions or need to contact a CrossLink Technical Support Team Member, call us at 800.345.4337 or email us at <a href="mailto:support@petzent.com">support@petzent.com</a>. </font></font></p></td><td bgColor="#efefef" width="4"><img src="http://208.69.42.99/email/2010-03-17/blank.gif" height="1" width="4" /></td><td bgColor="#c9c9c9" width="1"><img src="http://208.69.42.99/email/2010-03-17/blank.gif" height="1" width="1" /></td></tr><tr vAlign="top"><td colSpan="5" height="5" width="269"><img src="http://208.69.42.99/email/2010-03-17/box_bot.png" height="5" width="269" /></td></tr></tbody></table><br /><p style="margin: 15px 0px 8px"><font style="line-height: 14px; font-family: Arial,sans-serif; font-size: 14px" size="3" face="Arial, sans-serif" color="#000000"><strong><img src="https://www1.vtrenz.net/imarkownerfiles/ownerassets/2165/stmt_bcpersonally.gif" /></strong></font> </p><p style="margin: 15px 0px 8px"><font style="line-height: 14px; font-family: Arial,sans-serif; font-size: 14px" size="3" face="Arial, sans-serif" color="#000000">Contact your CrossLink Team today to learn more. </font></p><p style="margin: 10px 0px 8px"><b><font style="font-family: Arial,sans-serif; font-size: 14px" face="Arial, sans-serif" color="#000000"><font size="4">Call 800.345.4337 or <br />visit us </font><font size="4"><a target="_blank" href="http://www.crosslinktax.com/about/contact_us.asp">online</a>.</font></font></b> </p></td></tr><tr vAlign="top"><td colSpan="3" width="601"><img border="0" src="http://208.69.42.99/email/2010-03-17/blank.gif" height="10" width="601" /></td></tr><tr vAlign="top"><td colSpan="3" bgColor="#fdd104" align="left" height="31" width="601"><img border="0" src="http://www.crosslinktax.com/img/XL10_1974_tagline.png" alt="Putting Customers First Since 1974" height="31" width="280" /></td></tr><tr vAlign="top"><td colSpan="3" align="left" width="601"><font style="line-height: 12px; font-family: Arial,sans-serif; font-size: 10px" size="3" face="Arial, sans-serif" color="#000000"><p style="margin: 8px 0px" align="left"><font style="line-height: 12px; font-family: Arial,sans-serif; font-size: 10px" size="3" face="Arial, sans-serif" color="#000000"><font size="1"><font size="+0"><a target="_blank" href="http://www.crosslinktax.com/"><font face="arial,helvetica,sans-serif"><font size="1">CrossLink&reg;</font></font></a> </font><a target="_blank" href="http://www.crosslinktax.com/Default.asp" title="http://www.crosslinktax.com/Default.asp"><font face="arial,helvetica,sans-serif"><br title="http://www.crosslinktax.com" /></font></a>7575 W. Linne Road<br />Tracy, CA 95304<br />800.345.4337<br /></font><font size="1"><a target="_blank" href="http://crosslinktax.com/privacy_policy.asp" title="http://crosslinktax.com/privacy_policy.asp">Privacy &amp; Security</a>&nbsp;| &nbsp;<a target="_blank" href="http://crosslinktax.com/about" title="http://crosslinktax.com/about">About Us</a></font></font> </p></font></td></tr></tbody></table></td></tr></tbody></table></center>'

	INSERT INTO dbGlobal..tblPassThrough ( passId, activityType, data ) VALUES ( @id, 'CrossLink', @Account );


    -- Insert statements for procedure here
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name=@mailProfile,
			@recipients=@Email,
			@body=@body1,
			@body_format='HTML',
			@subject = 'Request to reset your Password'	
END


