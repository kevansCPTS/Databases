CREATE TABLE [dbo].[BillableProtectionPlusReturn] (
    [RowID]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PrimarySSN]   INT          NOT NULL,
    [FilingStatus] TINYINT      NOT NULL,
    [UserID]       INT          NOT NULL,
    [RecordDate]   DATETIME     CONSTRAINT [DF_BillableProtectionPlusReturns_RecordDate] DEFAULT (getdate()) NOT NULL,
    [StatusID]     INT          CONSTRAINT [DF_BillableProtectionPlusReturns_StatusID] DEFAULT ((1)) NOT NULL,
    [StatusDate]   DATETIME     CONSTRAINT [DF_BillableProtectionPlusReturns_StatusDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]    VARCHAR (50) NOT NULL,
    [OrderNumber]  INT          NULL,
    [ExportedDate] DATETIME     NULL,
    CONSTRAINT [PK_BillableProtectionPlusReturns] PRIMARY KEY CLUSTERED ([PrimarySSN] ASC, [FilingStatus] ASC, [UserID] ASC)
);

