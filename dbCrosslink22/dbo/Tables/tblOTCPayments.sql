CREATE TABLE [dbo].[tblOTCPayments] (
    [PaymentGUID]  CHAR (32)      NOT NULL,
    [ReturnGUID]   CHAR (32)      NULL,
    [PrimaryId]    CHAR (9)       NULL,
    [FilingType]   CHAR (1)       NULL,
    [ReceivedDate] CHAR (8)       NULL,
    [Amount]       INT            NULL,
    [ReceivedFrom] VARCHAR (255)  NULL,
    [Method]       VARCHAR (255)  NULL,
    [Reference]    VARCHAR (255)  NULL,
    [ReceivedBy]   VARCHAR (80)   NULL,
    [UserID]       CHAR (6)       NULL,
    [Memo]         VARCHAR (1024) NULL,
    [recTS]        DATETIME2 (0)  NULL,
    [IdType]       CHAR (1)       NULL
);

