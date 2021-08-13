CREATE TABLE [dbo].[tblFetchSvcRtnStatus] (
    [ChangeID]             INT           IDENTITY (1, 1) NOT NULL,
    [PrimarySSN]           INT           NOT NULL,
    [FilingStatus]         TINYINT       NOT NULL,
    [UserID]               INT           NOT NULL,
    [ChangeDTTM]           DATETIME2 (7) NOT NULL,
    [IsReturnMasterRecord] BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([ChangeID] ASC)
);

