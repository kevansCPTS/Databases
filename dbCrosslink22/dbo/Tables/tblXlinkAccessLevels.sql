CREATE TABLE [dbo].[tblXlinkAccessLevels] (
    [level_id]         INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME     CONSTRAINT [DF_tblXlinkAccessLevels_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME     CONSTRAINT [DF_tblXlinkAccessLevels_update_date] DEFAULT (getdate()) NULL,
    [level_name]       VARCHAR (30) NULL,
    [account_id]       VARCHAR (8)  NULL,
    [set_id]           INT          NULL,
    [franchiseuser_id] INT          NULL,
    CONSTRAINT [PK_tblXlinkAccessLevels] PRIMARY KEY CLUSTERED ([level_id] ASC),
    CONSTRAINT [FK_tblXlinkAccessLevels_tblXlinkAccessSets] FOREIGN KEY ([set_id]) REFERENCES [dbo].[tblXlinkAccessSets] ([set_id]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblXlinkAccessLevels]
    ON [dbo].[tblXlinkAccessLevels]([level_id] ASC);


GO
-- =============================================
-- Author:		Jay Willis
-- Create date: 12/22/09
-- Description:	update_date
-- Updated by Charles Krebs 5/17/2012
--		Now supports updates of multiple rows
-- =============================================
CREATE TRIGGER [dbo].[updatedateXlinkAccessSets] 
   ON  [dbo].[tblXlinkAccessLevels] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Update dbo.tblXlinkAccessSets SET update_date = getdate() 
	where set_id in (Select set_id from Inserted)

END



