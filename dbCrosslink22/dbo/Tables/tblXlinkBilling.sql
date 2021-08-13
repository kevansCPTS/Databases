CREATE TABLE [dbo].[tblXlinkBilling] (
    [billing_id]       INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [state_id]         CHAR (2)    NULL,
    [form_id]          VARCHAR (7) NULL,
    [form_type]        CHAR (1)    NULL,
    [account_id]       VARCHAR (8) NULL,
    [form_price]       MONEY       NULL,
    [schedule_id]      INT         NULL,
    [franchiseuser_id] INT         NULL,
    [xmltagname]       VARCHAR (6) NULL,
    CONSTRAINT [PK_tblXlinkBilling] PRIMARY KEY CLUSTERED ([billing_id] ASC),
    CONSTRAINT [UN_tblXlinkBilling] UNIQUE NONCLUSTERED ([form_id] ASC, [account_id] ASC, [schedule_id] ASC, [franchiseuser_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblXlinkBilling_account_id_schedule_id_form_id_form_price_franchiseuser_id]
    ON [dbo].[tblXlinkBilling]([account_id] ASC, [schedule_id] ASC)
    INCLUDE([form_price], [franchiseuser_id], [form_id]);

