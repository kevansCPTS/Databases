CREATE TABLE [dbo].[tblXlinkCustomCharges] (
    [charge_id]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [account_id]       VARCHAR (8)  NOT NULL,
    [charge_name_1]    VARCHAR (15) NULL,
    [charge_amount_1]  MONEY        NULL,
    [charge_name_2]    VARCHAR (15) NULL,
    [charge_amount_2]  MONEY        NULL,
    [charge_name_3]    VARCHAR (15) NULL,
    [charge_amount_3]  MONEY        NULL,
    [charge_name_4]    VARCHAR (15) NULL,
    [charge_amount_4]  MONEY        NULL,
    [charge_name_5]    VARCHAR (15) NULL,
    [charge_amount_5]  MONEY        NULL,
    [schedule_id]      INT          NOT NULL,
    [franchiseuser_id] INT          NULL,
    [charge_name_6]    VARCHAR (15) NULL,
    [charge_amount_6]  MONEY        NULL,
    [charge_name_7]    VARCHAR (15) NULL,
    [charge_amount_7]  MONEY        NULL,
    [charge_name_8]    VARCHAR (15) NULL,
    [charge_amount_8]  MONEY        NULL,
    [charge_name_9]    VARCHAR (15) NULL,
    [charge_amount_9]  MONEY        NULL,
    [charge_name_10]   VARCHAR (15) NULL,
    [charge_amount_10] MONEY        NULL,
    CONSTRAINT [UN_tblXlinkCustomCharges] PRIMARY KEY NONCLUSTERED ([charge_id] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblXlinkCustomCharges]
    ON [dbo].[tblXlinkCustomCharges]([account_id] ASC, [schedule_id] ASC);

