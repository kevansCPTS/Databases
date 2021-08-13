CREATE TABLE [dbo].[tblStamast] (
    [pssn]           INT           NOT NULL,
    [user_id]        INT           NULL,
    [state_spec]     INT           NULL,
    [sb_id]          INT           NULL,
    [stsb_spec]      INT           NULL,
    [fran_id]        INT           NULL,
    [stfran_spec]    INT           NULL,
    [archive_no]     INT           NULL,
    [efin]           INT           NULL,
    [dcn]            INT           NULL,
    [user_dcnx]      CHAR (12)     NULL,
    [rtn_id]         INT           NULL,
    [login_id]       INT           NULL,
    [prim_name_ctrl] CHAR (4)      NULL,
    [sec_name_ctrl]  CHAR (4)      NULL,
    [sssn]           INT           NULL,
    [mef_err]        INT           NULL,
    [irs_seq]        CHAR (9)      NULL,
    [state_id]       CHAR (2)      NOT NULL,
    [state_flag]     CHAR (1)      NULL,
    [state_ralf]     CHAR (1)      NULL,
    [timestamp]      CHAR (19)     NULL,
    [state_rfnd]     INT           NULL,
    [state_bdue]     INT           NULL,
    [state_agi]      INT           NULL,
    [submitType]     CHAR (25)     NULL,
    [schemaVersion]  CHAR (50)     NULL,
    [state_ack]      CHAR (1)      NULL,
    [state_ack_rfnd] INT           NULL,
    [state_eftc]     CHAR (1)      NULL,
    [state_ackd]     CHAR (8)      NULL,
    [submissionID]   CHAR (20)     NULL,
    [postMark]       CHAR (25)     NULL,
    [rejCount]       SMALLINT      NULL,
    [fedcopy]        CHAR (1)      NULL,
    [guid]           CHAR (32)     NULL,
    [filing_stat]    CHAR (1)      NULL,
    [fetchSeq]       CHAR (4)      NULL,
    [recTS]          DATETIME2 (0) NULL,
    [state_acky]     CHAR (4)      NULL,
    [formType1040]   CHAR (1)      NULL,
    [onlineType]     CHAR (1)      NULL,
    [subtype]        CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [alertcnt]       SMALLINT      NULL,
    [ststatcnt]      SMALLINT      NULL,
    [ldate]          DATETIME      CONSTRAINT [DF_tblStamast_ldate] DEFAULT (getdate()) NULL,
    [govCode]        CHAR (4)      NULL,
    [flvl]           CHAR (4)      NULL,
    [RowVer]         ROWVERSION    NOT NULL,
    [nRowVer]        AS            (CONVERT([bigint],[RowVer],0)) PERSISTED,
    CONSTRAINT [PK_tblStamast] PRIMARY KEY CLUSTERED ([pssn] ASC, [state_id] ASC, [subtype] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblStamast]
    ON [dbo].[tblStamast]([submissionID] ASC);


GO
CREATE NONCLUSTERED INDEX [state_mast]
    ON [dbo].[tblStamast]([pssn] ASC, [state_id] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);


GO
CREATE NONCLUSTERED INDEX [IX_tblStamast_nRowVer]
    ON [dbo].[tblStamast]([nRowVer] DESC)
    INCLUDE([pssn]);


GO
-- =============================================
-- Author:		Josh Daniel
-- Create date: 10/18/2011
-- Description:	Trigger to update WebServiceDiff table table whenever a change
--				has been made
-- =============================================
Create TRIGGER [dbo].[tgrWebserviceDiff_Stamast] 
   ON  dbo.tblStamast 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @stamp datetime
    
    Set @stamp = getDate();
    
		
		
	update a set a.atomDelivered=0,a.irsstatusdelivered=0, a.timestamp=@stamp
		from WebserviceDiff a inner join inserted b on a.pssn=b.pssn where b.pssn is not null

		if(@@ROWCOUNT = 0)
		begin

			insert into WebserviceDiff (pssn,timestamp) 
				select pssn, @stamp from inserted where pssn is not null
    
		end

END
