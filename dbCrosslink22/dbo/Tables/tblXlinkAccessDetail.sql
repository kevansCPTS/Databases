CREATE TABLE [dbo].[tblXlinkAccessDetail] (
    [detail_id]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME      CONSTRAINT [DF_tblXlinkAccessDetail_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME      CONSTRAINT [DF_tblXlinkAccessDetail_update_date] DEFAULT (getdate()) NULL,
    [account_id]       VARCHAR (8)   NULL,
    [detail]           VARCHAR (200) NULL,
    [level_id]         INT           NULL,
    [franchiseuser_id] INT           NULL,
    CONSTRAINT [PK_tblXlinkAccessDetail] PRIMARY KEY CLUSTERED ([detail_id] ASC),
    CONSTRAINT [FK_tblXlinkAccessDetail_tblXlinkAccessLevels] FOREIGN KEY ([level_id]) REFERENCES [dbo].[tblXlinkAccessLevels] ([level_id]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO

-- =============================================
-- Author:		Jay Willis
-- Create date: 12/22/09
-- Description:	update_date
-- Updated by Charles Krebs 5/17/2012 
--		Now allows for updates of multiple records without crashing
-- =============================================
CREATE TRIGGER [dbo].[insertafterupdatedateXlinkAccessLevel] 
   ON  [dbo].[tblXlinkAccessDetail] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    Update dbo.tblXlinkAccessLevels SET update_date = getdate() 
	where level_id in (Select level_id from Inserted)

END





GO
-- =============================================
-- Author:		Jay Willis
-- Create date: 12/22/09
-- Description:	update_date
-- Updated by Charles Krebs 5/17/2012
--		Now supports update of multiple records at once
-- =============================================
CREATE TRIGGER [dbo].[updatedateXlinkAccessLevel] 
   ON  [dbo].[tblXlinkAccessDetail] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Update dbo.tblXlinkAccessLevels SET update_date = getdate() 
	where level_id in (Select level_id from Inserted)

END



