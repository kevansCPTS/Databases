CREATE TABLE [dbo].[tblTaxReturn] (
    [primId]   INT           NOT NULL,
    [fetchSeq] CHAR (4)      NOT NULL,
    [userId]   INT           NULL,
    [fran_id]  INT           NULL,
    [sb_id]    INT           NULL,
    [recTs]    DATETIME2 (0) NULL,
    [xmlData]  XML           NULL,
    CONSTRAINT [PK_tblTaxReturn] PRIMARY KEY CLUSTERED ([primId] ASC, [fetchSeq] DESC)
);

