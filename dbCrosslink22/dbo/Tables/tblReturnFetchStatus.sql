CREATE TABLE [dbo].[tblReturnFetchStatus] (
    [PrimarySSN]       INT           NOT NULL,
    [FilingStatus]     TINYINT       NOT NULL,
    [UserID]           INT           NOT NULL,
    [ModifiedDate]     DATETIME2 (7) NOT NULL,
    [FromReturnMaster] BIT           NOT NULL,
    CONSTRAINT [PK_tblReturnFetchStatus] PRIMARY KEY CLUSTERED ([PrimarySSN] ASC, [FilingStatus] ASC, [UserID] ASC, [FromReturnMaster] ASC)
);

