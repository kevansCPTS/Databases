CREATE TABLE [dbo].[tblSignatureAuditLog] (
    [audit_event_id]         INT           IDENTITY (1, 1) NOT NULL,
    [service_name]           VARCHAR (50)  NOT NULL,
    [tax_year]               INT           NOT NULL,
    [originating_ip_address] VARCHAR (50)  NOT NULL,
    [remotesig_error_code]   INT           NOT NULL,
    [unique_id]              VARCHAR (100) NOT NULL,
    [signature_types]        VARCHAR (10)  NOT NULL,
    [last_name]              VARCHAR (30)  NULL,
    [rep_last_name]          VARCHAR (30)  NULL,
    [date_of_birth]          DATETIME2 (7) NULL,
    [last_4_ssn]             VARCHAR (4)   NULL,
    [last_4_rep_ssn]         VARCHAR (4)   NULL,
    [filer_ein]              VARCHAR (20)  NULL,
    [created_dttm]           DATETIME      DEFAULT (getdate()) NULL,
    [zip]                    VARCHAR (12)  NULL,
    CONSTRAINT [PK_tblSignatureAuditLog] PRIMARY KEY CLUSTERED ([audit_event_id] ASC),
    CONSTRAINT [FK_tblSignatureAuditLog_reftblSignatureError] FOREIGN KEY ([remotesig_error_code]) REFERENCES [dbo].[reftblSignatureError] ([remotesig_error_code])
);


GO
-- =============================================
-- Author:		Michael Langston
-- Create date: 2017-03-03
-- Description:	Insert a record into tblErrorLog if we get an system error (code 4)
-- =============================================
CREATE TRIGGER tgrRemoteSigSystemErr
   ON  [dbo].[tblSignatureAuditLog]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @errID int = (select remotesig_error_code from inserted)


	if(@errID = 4)
	begin
		INSERT INTO [dbo].[tblErrorLog]
					([callingObject]
					,[eNum]
					,[eMsg]
					,[eData]
					,[eResolved])
		VALUES
			('Remote Signature Service'
			,@errID
			,'System error requiring dev attention'
			,(select * from inserted for xml raw)
			,0)
    end

END
