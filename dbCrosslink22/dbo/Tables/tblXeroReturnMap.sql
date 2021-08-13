CREATE TABLE [dbo].[tblXeroReturnMap] (
    [userId]     INT           NOT NULL,
    [efin]       INT           NOT NULL,
    [pssn]       INT           NOT NULL,
    [returnGuid] VARCHAR (36)  NOT NULL,
    [mapType]    TINYINT       NOT NULL,
    [mapId]      VARCHAR (36)  NOT NULL,
    [createDate] DATETIME2 (7) CONSTRAINT [DF_tblXeroReturnMap_createDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblXeroReturnMap] PRIMARY KEY CLUSTERED ([userId] ASC, [efin] ASC, [pssn] ASC, [returnGuid] ASC, [mapType] ASC)
);

