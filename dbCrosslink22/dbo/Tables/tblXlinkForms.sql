CREATE TABLE [dbo].[tblXlinkForms] (
    [form_id]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [state]           CHAR (2)      NULL,
    [form_type]       CHAR (1)      NULL,
    [form_cd]         CHAR (6)      NULL,
    [form_short_name] VARCHAR (12)  NULL,
    [form_long_name]  VARCHAR (100) NULL,
    [form_group]      VARCHAR (4)   NULL,
    CONSTRAINT [PK_tblXlinkForms] PRIMARY KEY CLUSTERED ([form_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [UN_tblXlinkForms]
    ON [dbo].[tblXlinkForms]([form_cd] ASC, [state] ASC, [form_type] ASC, [form_group] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);

