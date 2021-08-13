CREATE TABLE [dbo].[tblCADMemberData] (
    [pssn]          INT           NOT NULL,
    [Account]       VARCHAR (8)   NULL,
    [EFIN]          INT           NULL,
    [UserId]        INT           NULL,
    [fdate]         DATETIME      NULL,
    [req_cadr_fee]  INT           NULL,
    [cadr_pay_date] DATE          NULL,
    [cadr_pay_amt]  INT           NULL,
    [StatusId]      TINYINT       NULL,
    [StatusDate]    SMALLDATETIME CONSTRAINT [DF_tblCADMemberData_StatusDate] DEFAULT (getdate()) NULL,
    [CADRResult]    VARCHAR (MAX) NULL,
    [CADMemberId]   VARCHAR (25)  NULL,
    [AgentId]       AS            (([Account]+isnull(CONVERT([varchar](25),[UserId],(0)),''))+isnull(CONVERT([varchar](25),[EFIN],(0)),'')) PERSISTED,
    CONSTRAINT [PK_tblCADMemberData] PRIMARY KEY NONCLUSTERED ([pssn] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblCADMemberData]
    ON [dbo].[tblCADMemberData]([Account] ASC, [UserId] ASC, [EFIN] ASC, [pssn] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_tblCADMemberData]
    ON [dbo].[tblCADMemberData]([AgentId] ASC);


GO
CREATE TRIGGER [dbo].[trg_tblCADMemberData_delete]
   ON  [dbo].[tblCADMemberData]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON

	if exists(select * from deleted)
		insert [dbo].[tblCADMemberDataHist](
            [pssn]
        ,   [Account] 
        ,   [EFIN]
        ,   [UserId]
        ,   [fdate] 
        ,   [req_cadr_fee]
        ,   [cadr_pay_date] 
        ,   [cadr_pay_amt]
        ,   [StatusId]
        ,   [StatusDate] 
        ,   [CADRResult]
        ,   [CADMemberId]
        ,   [HistoryActionId]
        ,   [HistoryDate] 
		)
			select
                d.[pssn]
            ,   d.[Account] 
            ,   d.[EFIN]
            ,   d.[UserId]
            ,   d.[fdate] 
            ,   d.[req_cadr_fee]
            ,   d.[cadr_pay_date] 
            ,   d.[cadr_pay_amt]
            ,   d.[StatusId]
            ,   d.[StatusDate] 
            ,   d.[CADMemberId]
            ,   d.[CADRResult]
			,	3
			,	getdate()	
		from
			deleted d	

END


GO
create TRIGGER [dbo].[trg_tblCADMemberData_insert]
   ON  [dbo].[tblCADMemberData]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON

	if exists(select * from inserted) 
		insert [dbo].[tblCADMemberDataHist](
            [pssn]
        ,   [Account] 
        ,   [EFIN]
        ,   [UserId]
        ,   [fdate] 
        ,   [req_cadr_fee]
        ,   [cadr_pay_date] 
        ,   [cadr_pay_amt]
        ,   [StatusId]
        ,   [StatusDate] 
        ,   [CADRResult]
        ,   [CADMemberId]
        ,   [HistoryActionId]
        ,   [HistoryDate] 
		)
			select
                i.[pssn]
            ,   i.[Account] 
            ,   i.[EFIN]
            ,   i.[UserId]
            ,   i.[fdate] 
            ,   i.[req_cadr_fee]
            ,   i.[cadr_pay_date] 
            ,   i.[cadr_pay_amt]
            ,   i.[StatusId]
            ,   i.[StatusDate] 
            ,   i.[CADRResult]
            ,   i.[CADMemberId]
			,	1
			,	getdate()	
		from
			inserted i	

END


GO
create TRIGGER [dbo].[trg_tblCADMemberData_update]
   ON  [dbo].[tblCADMemberData]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON

	if exists(select * from inserted) 
		insert [dbo].[tblCADMemberDataHist](
            [pssn]
        ,   [Account] 
        ,   [EFIN]
        ,   [UserId]
        ,   [fdate] 
        ,   [req_cadr_fee]
        ,   [cadr_pay_date] 
        ,   [cadr_pay_amt]
        ,   [StatusId]
        ,   [StatusDate] 
        ,   [CADRResult]
        ,   [CADMemberId]
        ,   [HistoryActionId]
        ,   [HistoryDate] 
		)
			select
                i.[pssn]
            ,   i.[Account] 
            ,   i.[EFIN]
            ,   i.[UserId]
            ,   i.[fdate] 
            ,   i.[req_cadr_fee]
            ,   i.[cadr_pay_date] 
            ,   i.[cadr_pay_amt]
            ,   i.[StatusId]
            ,   i.[StatusDate] 
            ,   i.[CADRResult]
            ,   i.[CADMemberId]
			,	2
			,	getdate()	
		from
			inserted i	

END

