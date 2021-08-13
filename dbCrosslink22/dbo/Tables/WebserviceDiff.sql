CREATE TABLE [dbo].[WebserviceDiff] (
    [pssn]                   INT      NOT NULL,
    [timestamp]              DATETIME NULL,
    [atomDelivered]          BIT      CONSTRAINT [DF_ATOMDiff_delivered] DEFAULT ((0)) NOT NULL,
    [atomDeliveredDate]      DATETIME NULL,
    [irsStatusDelivered]     BIT      CONSTRAINT [DF_WebserviceDiff_irsStatusDelivered] DEFAULT ((0)) NOT NULL,
    [irsStatusDeliveredDate] DATETIME NULL,
    CONSTRAINT [PK_WebserviceDiff] PRIMARY KEY CLUSTERED ([pssn] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID2_WebserviceDiff]
    ON [dbo].[WebserviceDiff]([timestamp] ASC)
    INCLUDE([pssn]);

