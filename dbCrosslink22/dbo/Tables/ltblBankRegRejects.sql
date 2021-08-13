CREATE TABLE [dbo].[ltblBankRegRejects] (
    [ID]                INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Bank]              CHAR (1)      NOT NULL,
    [RejectCode]        CHAR (5)      NOT NULL,
    [RejectDescription] VARCHAR (350) NOT NULL,
    CONSTRAINT [PK_ltblBankRegRejects] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_ltblBankRegRejects_28_270624007__K2_K3_4]
    ON [dbo].[ltblBankRegRejects]([Bank] ASC, [RejectCode] ASC)
    INCLUDE([RejectDescription]);

