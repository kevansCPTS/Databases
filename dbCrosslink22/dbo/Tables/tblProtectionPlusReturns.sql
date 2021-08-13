CREATE TABLE [dbo].[tblProtectionPlusReturns] (
    [PrimarySSN]       INT           NULL,
    [UserID]           INT           NULL,
    [FilingStatus]     INT           NULL,
    [Account]          VARCHAR (8)   NULL,
    [Company]          VARCHAR (35)  NULL,
    [PrimaryFirstName] VARCHAR (255) NULL,
    [PrimaryLastName]  VARCHAR (255) NULL,
    [EFIN]             INT           NULL,
    [SubmissionID]     VARCHAR (20)  NULL,
    [BillingType]      VARCHAR (20)  NULL,
    [PaymentStatus]    VARCHAR (20)  NULL,
    [PaymentDate]      DATE          NULL
);


GO
CREATE CLUSTERED INDEX [CDX_tblProtectionPlusReturns]
    ON [dbo].[tblProtectionPlusReturns]([Account] ASC, [PrimarySSN] ASC);

