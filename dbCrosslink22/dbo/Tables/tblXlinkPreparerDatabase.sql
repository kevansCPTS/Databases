CREATE TABLE [dbo].[tblXlinkPreparerDatabase] (
    [preparer_id]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]        DATETIME     CONSTRAINT [DF_tblPreparerDatabase_create_date] DEFAULT (getdate()) NULL,
    [edit_date]          DATETIME     CONSTRAINT [DF_tblPreparerDatabase_edit_date] DEFAULT (getdate()) NULL,
    [publish_date]       DATETIME     NULL,
    [account_id]         VARCHAR (8)  NULL,
    [user_id]            INT          NULL,
    [shortcut_id]        VARCHAR (7)  NULL,
    [preparer_name]      VARCHAR (35) NULL,
    [self_employed]      CHAR (1)     NULL,
    [firm_name]          VARCHAR (35) NULL,
    [ein]                CHAR (9)     NULL,
    [address]            VARCHAR (35) NULL,
    [city]               VARCHAR (20) NULL,
    [state]              CHAR (2)     NULL,
    [zip]                VARCHAR (9)  NULL,
    [office_phone]       CHAR (10)    NULL,
    [efin]               CHAR (6)     NULL,
    [state_code_1]       CHAR (2)     NULL,
    [state_id_1]         VARCHAR (14) NULL,
    [state_code_2]       CHAR (2)     NULL,
    [state_id_2]         VARCHAR (14) NULL,
    [ptin]               CHAR (9)     NULL,
    [ssn]                CHAR (9)     NULL,
    [third_party_pin]    VARCHAR (5)  NULL,
    [email]              VARCHAR (55) NULL,
    [preparer_type]      VARCHAR (5)  NULL,
    [cell_phone]         CHAR (10)    NULL,
    [cell_phone_carrier] VARCHAR (35) NULL,
    [franchiseuser_id]   INT          NULL,
    [caf]                CHAR (9)     NULL,
    [default_pin]        VARCHAR (5)  NULL,
    CONSTRAINT [PK_tblPreparerDatabase] PRIMARY KEY CLUSTERED ([preparer_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblXlinkPreparerDatabase]
    ON [dbo].[tblXlinkPreparerDatabase]([account_id] ASC, [user_id] ASC);

