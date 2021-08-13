CREATE TABLE [dbo].[tblXlinkUserLogins] (
    [userlogin_id]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]           DATETIME     CONSTRAINT [DF_tblXlinkUserLogins_create_date] DEFAULT (getdate()) NULL,
    [edit_date]             DATETIME     CONSTRAINT [DF_tblXlinkUserLogins_edit_date] DEFAULT (getdate()) NULL,
    [publish_date]          DATETIME     NULL,
    [account_id]            VARCHAR (8)  NULL,
    [user_id]               INT          NULL,
    [login_id]              VARCHAR (50) NULL,
    [login_name]            VARCHAR (35) NULL,
    [login_password]        VARCHAR (16) NULL,
    [change_password]       CHAR (1)     CONSTRAINT [DF_tblXlinkUserLogins_change_password] DEFAULT ('') NULL,
    [hide_work_in_progress] CHAR (1)     NULL,
    [access_level]          INT          NULL,
    [shortcut_id]           VARCHAR (7)  NULL,
    [bank_id_code]          VARCHAR (5)  NULL,
    [RBIN]                  VARCHAR (8)  NULL,
    [franchiseuser_id]      INT          NULL,
    [display_short_form]    CHAR (1)     NULL,
    [training_returns_only] CHAR (1)     NULL,
    [show_fees_in_transmit] CHAR (1)     NULL,
    [disabled]              BIT          CONSTRAINT [DF_tblXlinkUserLogins_disabled] DEFAULT ((0)) NOT NULL,
    [email]                 VARCHAR (50) NULL,
    [cell_phone]            VARCHAR (10) NULL,
    CONSTRAINT [PK_tblXlinkUserLogins] PRIMARY KEY CLUSTERED ([userlogin_id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UN_user_id_login_id]
    ON [dbo].[tblXlinkUserLogins]([user_id] ASC, [login_id] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);

