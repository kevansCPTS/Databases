CREATE TABLE [dbo].[tblSizeLog] (
    [LogDate]    SMALLDATETIME NULL,
    [schemaName] VARCHAR (10)  NULL,
    [tableName]  VARCHAR (255) NULL,
    [row_Count]  BIGINT        NULL,
    [dataKb]     BIGINT        NULL,
    [indexKb]    BIGINT        NULL,
    [unusedKb]   BIGINT        NULL,
    [totalKb]    BIGINT        NULL
);

