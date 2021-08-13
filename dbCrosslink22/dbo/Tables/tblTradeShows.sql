CREATE TABLE [dbo].[tblTradeShows] (
    [ts_id]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ts_startDate] DATETIME     NULL,
    [ts_endDate]   DATETIME     NULL,
    [ts_city]      VARCHAR (50) NULL,
    [ts_hotel]     VARCHAR (50) NULL,
    [ts_date]      VARCHAR (50) NULL,
    CONSTRAINT [PK_tblTradeShows] PRIMARY KEY CLUSTERED ([ts_id] ASC)
);

