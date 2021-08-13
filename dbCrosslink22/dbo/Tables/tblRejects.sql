CREATE TABLE [dbo].[tblRejects] (
    [rowID]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]           INT          NULL,
    [tran_key]       VARCHAR (1)  NULL,
    [tran_seq]       INT          NULL,
    [error_num]      SMALLINT     NULL,
    [state_id]       VARCHAR (2)  NULL,
    [form_seq]       VARCHAR (4)  NULL,
    [field_seq]      VARCHAR (4)  NULL,
    [state_id2]      VARCHAR (2)  NULL,
    [rej_code]       VARCHAR (4)  NULL,
    [user_id]        VARCHAR (6)  NULL,
    [user_dcnx]      VARCHAR (12) NULL,
    [rtn_id]         VARCHAR (9)  NULL,
    [irs_state_only] VARCHAR (2)  NULL,
    [touched]        BIT          NULL,
    [RejectDate]     DATETIME     CONSTRAINT [DF_tblRejects_RejectDate] DEFAULT (getdate()) NOT NULL,
    [pkg_id]         CHAR (2)     NULL,
    CONSTRAINT [PK__rejects] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblRejectsPssnPkgIdError]
    ON [dbo].[tblRejects]([pssn] ASC, [pkg_id] ASC, [error_num] ASC);


GO

-- =============================================
-- Author:		Josh Daniel
-- Create date: 10/18/2011
-- Description:	Trigger to update WebServiceDiff table table whenever a change
--				has been made
-- =============================================
Create TRIGGER [dbo].[tgrWebserviceDiff_tblRejects] 
   ON  [dbo].[tblRejects] 
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




