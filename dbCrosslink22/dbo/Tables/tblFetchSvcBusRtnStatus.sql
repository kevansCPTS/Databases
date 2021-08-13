CREATE TABLE [dbo].[tblFetchSvcBusRtnStatus] (
    [ChangeID]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PrimaryID]  CHAR (9)      NOT NULL,
    [StateID]    CHAR (2)      NOT NULL,
    [SubType]    CHAR (2)      NOT NULL,
    [UserID]     INT           NOT NULL,
    [ChangeDTTM] DATETIME2 (7) NOT NULL,
    PRIMARY KEY CLUSTERED ([ChangeID] ASC)
);

