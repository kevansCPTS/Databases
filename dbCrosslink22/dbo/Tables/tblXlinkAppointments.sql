CREATE TABLE [dbo].[tblXlinkAppointments] (
    [appointmentID]   UNIQUEIDENTIFIER CONSTRAINT [DF_tblXlinkAppointments_appointmentID] DEFAULT (newid()) NOT NULL,
    [UserID]          INT              NOT NULL,
    [LoginID]         VARCHAR (8)      NOT NULL,
    [LoginName]       VARCHAR (32)     NULL,
    [Subject]         VARCHAR (255)    NOT NULL,
    [AppointmentDate] DATETIME         NOT NULL,
    [Duration]        INT              NOT NULL,
    [Reminder]        INT              NOT NULL,
    [ClientName]      VARCHAR (50)     NULL,
    [Address]         VARCHAR (35)     NULL,
    [City]            VARCHAR (35)     NULL,
    [State]           VARCHAR (2)      NULL,
    [Zip]             VARCHAR (12)     NULL,
    [HomePhone]       VARCHAR (10)     NULL,
    [WorkPhone]       VARCHAR (10)     NULL,
    [EmailAddress]    VARCHAR (75)     NULL,
    [Notes]           VARCHAR (2000)   NULL,
    [Delivered]       BIT              CONSTRAINT [DF_tblXlinkAppointments_Delivered] DEFAULT ((0)) NOT NULL,
    [LastUpdated]     DATETIME2 (7)    CONSTRAINT [DF_tblXlinkAppointments_LastUpdated] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_tblXlinkAppointments_1] PRIMARY KEY CLUSTERED ([appointmentID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CDX_tblXlinkAppointments]
    ON [dbo].[tblXlinkAppointments]([UserID] ASC, [LoginID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserID_LastUpdated]
    ON [dbo].[tblXlinkAppointments]([UserID] ASC, [LastUpdated] ASC);


GO
-- =============================================
-- Author:		Steve Trautman
-- Create date: 02/15/2016
-- Description:	After Update trigger to update the LastUpdated column
-- =============================================
CREATE TRIGGER trgAfterUpdate 
   ON tblXlinkAppointments 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE a
	SET a.LastUpdated = sysutcdatetime()
	FROM tblXlinkAppointments AS a 
	INNER JOIN INSERTED AS i 
	ON a.appointmentID = i.appointmentID;

END
