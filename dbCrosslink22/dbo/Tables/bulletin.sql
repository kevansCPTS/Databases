CREATE TABLE [dbo].[bulletin] (
    [bull_number]           INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [bull_file]             VARCHAR (10)  NULL,
    [bull_header]           VARCHAR (60)  NULL,
    [bull_content]          VARCHAR (MAX) NULL,
    [BulletinTypeID]        INT           NOT NULL,
    [SendDate]              DATETIME      NULL,
    [hasBusinessLicense]    INT           NULL,
    [selectedBankId]        VARCHAR (1)   NULL,
    [deliveredStatePackage] VARCHAR (3)   NULL,
    CONSTRAINT [PK_bulls] PRIMARY KEY CLUSTERED ([bull_number] ASC),
    CONSTRAINT [FK_bulletin_bulletin] FOREIGN KEY ([BulletinTypeID]) REFERENCES [dbo].[BulletinType] ([BulletinTypeID])
);


GO
-- =============================================
-- Author:		Charles Krebs & Tim Gong
-- Create date: 11/29/2010
-- Description:	When adding a bulletin, create a filename from the bulletin number
-- =============================================
CREATE TRIGGER [dbo].[tgrBulletinInsert] 
   ON  [dbo].[bulletin] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @filename char(10)
	DECLARE @bull_number int

	SELECT @bull_number = bull_number FROM INSERTED
	SET @filename = '' + @bull_number

	WHILE Len(@filename) < 6
	BEGIN
		SET @filename = '0' + @filename
	END
	SET @filename = 'g' + @filename


	UPDATE Bulletin 
	SET bull_file = @filename 
	WHERE bull_number = @bull_number

END



