CREATE TABLE [dbo].[MEFError] (
    [MEFErrorID]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [primid]        INT           NOT NULL,
    [SubmissionID]  CHAR (20)     NOT NULL,
    [ErrorID]       SMALLINT      NOT NULL,
    [stateid]       CHAR (2)      NULL,
    [form_seq]      CHAR (4)      NULL,
    [field_seq]     CHAR (4)      NULL,
    [DataValue]     VARCHAR (MAX) NULL,
    [DocumentID]    VARCHAR (MAX) NULL,
    [XPath]         VARCHAR (MAX) NULL,
    [ErrorCategory] VARCHAR (MAX) NULL,
    [ErrorMessage]  VARCHAR (MAX) NULL,
    [RuleNumber]    VARCHAR (MAX) NULL,
    [Severity]      VARCHAR (MAX) NULL,
    [touched]       BIT           NULL,
    [MEFErrorDate]  DATETIME      CONSTRAINT [DF_MEFError_MEFErrorDate] DEFAULT (getdate()) NOT NULL,
    [subtype]       CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    CONSTRAINT [PK_MEFError] PRIMARY KEY CLUSTERED ([MEFErrorID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MEFError]
    ON [dbo].[MEFError]([SubmissionID] ASC, [ErrorID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MEFErrorPSSNSubIDErrorID]
    ON [dbo].[MEFError]([primid] ASC, [SubmissionID] ASC, [ErrorID] ASC);


GO
-- =============================================
-- Author:		Charles Krebs
-- Create date: 1/4/2012
-- Description:	When an XML Schema validation error comes in, 
-- Send an e-mail to QA to alert them to the issue.
-- =============================================
CREATE TRIGGER [dbo].[xmlErrorAlert]
   ON  [dbo].[MEFError]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @body_text varchar(MAX)
	DECLARE @errorMessage varchar(MAX)
	DECLARE @primid int
	DECLARE @stateID varchar(2)
	DECLARE @returnID varchar(9)
	DECLARE @userID int
	DECLARE @form_seq varchar(4)
	DECLARE @field_seq varchar(4)
	DECLARE @dataValue varchar(MAX)
	DECLARE @DocumentID varchar(MAX)
	DECLARE @xpath varchar(MAX)
	DECLARE @ErrorCategory varchar(MAX)
	DECLARE @rulenumber varchar(MAX)
	DECLARE @severity varchar(MAX)
	DECLARE @newLine varchar(5)
    DECLARE @errordate datetime



	SET @newLine = CHAR(10) + char(13)

	DECLARE update_cursor CURSOR FOR 

	SELECT MEFerror.primid, MEFError.ErrorMessage, MEFResponse.returnID, TM.user_id, 
		MEFError.stateid, MEFError.form_seq, MEFError.field_seq, MEFError.dataValue,
		MEFError.DocumentID, MEFError.xpath, MEFError.ErrorCategory, 
		MEFError.RuleNumber, MEFError.Severity, MEFError.MEFErrorDate
	FROM inserted 
		INNER JOIN MEFError ON MEFError.MEFErrorID = inserted.MEFErrorID
		INNER JOIN MEFResponse ON MEFError.SubmissionID=MEFResponse.SubmissionID
		LEFT JOIN tblTaxmast TM ON TM.pssn = MEFError.primid
	WHERE MEFError.RuleNumber like 'X%' OR MEFError.RuleNumber like MEFError.stateid + 'X%'

	OPEN update_cursor

	FETCH NEXT FROM update_cursor 
	INTO @primid, @errorMessage, @returnID, @userID, @stateID, @form_seq, @field_seq,
	@dataValue, @DocumentID, @xpath, @errorCategory, @ruleNumber, @severity, @errordate

	WHILE @@FETCH_STATUS = 0
	BEGIN
	   PRINT ' ' + convert(varchar(25),@primid) + ' ' + @stateID
	   
		SET @body_text = 'PrimaryId: ' + convert(varchar(25),@primid) + @newLine + 
		'UserID: ' + Convert(varchar(10), @userID) + @newLine + 'ReturnID: ' + @returnID + @newLine
		+ 'StateID: ' + @stateID + @newLine + 'Error Message: ' + rtrim(@errorMessage) + @newLine
		+ 'Form Sequence: ' + rtrim(@form_seq) + @newLine + 
		'Field Sequence: ' + rtrim(@field_seq) + @newLine + 
		'Data Value: ' + rtrim(@dataValue) + @newLine + 
		'DocumentID: ' + rtrim(@documentID) + @newLine + 
		'X-Path: ' + rtrim(@xpath) + @newLine + 
		'Error Category: ' + rtrim(@errorCategory) + @newLine + 
		'Rule Number: ' + rtrim(@ruleNumber) + @newLine + 
		'Severity: ' + rtrim(@severity) + @newLine +
		'Error Date: ' + convert(varchar(50),@errordate,121) + @newLine 
		
		
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name='externalCommunication',
					@recipients= 'qateamdev@petzent.com',
					@body=@body_text,
					@body_format='HTML',
					@subject = 'XML MEF Error Encountered'
	   
		  SELECT @body_text
	   FETCH NEXT FROM update_cursor 
		INTO @primid, @errorMessage, @returnID, @userID, @stateID, @form_seq, @field_seq,
		@dataValue, @DocumentID, @xpath, @errorCategory, @ruleNumber, @severity, @errordate
	END

	CLOSE update_cursor
	DEALLOCATE update_cursor


	END




GO
DISABLE TRIGGER [dbo].[xmlErrorAlert]
    ON [dbo].[MEFError];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Used by TaxBrain & MSO after a user touches a form field after an error.  Thus, we remove errors from display (assuming the user fixed the issue), which will be made visibile on subsequent calc/submission.
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MEFError', @level2type = N'COLUMN', @level2name = N'touched';

