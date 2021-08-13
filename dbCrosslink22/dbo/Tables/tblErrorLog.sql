CREATE TABLE [dbo].[tblErrorLog] (
    [elogId]        INT           IDENTITY (1, 1) NOT NULL,
    [callingObject] VARCHAR (255) NOT NULL,
    [eNum]          INT           NOT NULL,
    [eMsg]          VARCHAR (MAX) NOT NULL,
    [eData]         XML           NULL,
    [createDate]    DATETIME      CONSTRAINT [DF_Table_1_eCreateDate] DEFAULT (getdate()) NOT NULL,
    [createBy]      VARCHAR (50)  CONSTRAINT [DF_Table_1_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [eResolved]     BIT           CONSTRAINT [DF_tblErrorLog_eResolved] DEFAULT ((0)) NOT NULL,
    [updateDate]    DATETIME      CONSTRAINT [DF_Table_1_UpdateDate] DEFAULT (getdate()) NOT NULL,
    [updateBy]      VARCHAR (50)  CONSTRAINT [DF_tblErrorLog_updateBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_tblErrorLog] PRIMARY KEY NONCLUSTERED ([elogId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblErrorLog]
    ON [dbo].[tblErrorLog]([callingObject] ASC, [eNum] ASC, [eResolved] ASC, [createDate] ASC);


GO


CREATE TRIGGER [dbo].[trg_tblErrorLog_updateUser]
   ON  [dbo].[tblErrorLog]
   AFTER UPDATE
AS 
	set nocount on

	update e
		set e.updateDate = getdate()
	,	e.updateBy = system_user
	from
		dbo.tblErrorLog e join inserted i on e.elogId = i.elogId



