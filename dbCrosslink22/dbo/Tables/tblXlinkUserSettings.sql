﻿CREATE TABLE [dbo].[tblXlinkUserSettings] (
    [usersettings_id]                         INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [master_id]                               INT          NULL,
    [create_date]                             DATETIME     CONSTRAINT [DF_tblXlinkUserSettings_create_date] DEFAULT (getdate()) NULL,
    [edit_date]                               DATETIME     CONSTRAINT [DF_tblXlinkUserSettings_edit_date] DEFAULT (getdate()) NULL,
    [publish_date]                            DATETIME     NULL,
    [user_id]                                 INT          NULL,
    [account_id]                              VARCHAR (8)  NULL,
    [transmit_password]                       VARCHAR (20) NULL,
    [authorization_level]                     INT          NULL,
    [name]                                    VARCHAR (35) NULL,
    [phone]                                   VARCHAR (10) NULL,
    [location]                                VARCHAR (40) NULL,
    [fax]                                     VARCHAR (10) NULL,
    [email]                                   VARCHAR (50) NULL,
    [billing_schedule]                        INT          NULL,
    [bank_choice]                             CHAR (1)     NULL,
    [group_id]                                INT          NULL,
    [svcB_fee]                                MONEY        CONSTRAINT [DF_tblXlinkUserSettings_svcB_fee] DEFAULT ((0)) NULL,
    [protection_plus_fee]                     MONEY        CONSTRAINT [DF_tblXlinkUserSettings_protection_plus_fee] DEFAULT ((0)) NULL,
    [auto_add_audit_protection]               CHAR (1)     NULL,
    [ef_forms_only]                           CHAR (1)     NULL,
    [sales_tax]                               MONEY        NULL,
    [default_rate]                            MONEY        NULL,
    [tax_prep_discount]                       MONEY        NULL,
    [disable_invoicing]                       CHAR (1)     NULL,
    [collect_on_billing]                      CHAR (1)     NULL,
    [EFFee]                                   MONEY        CONSTRAINT [DF_tblXlinkUserSettings_EFFee] DEFAULT ((0)) NULL,
    [DPFee]                                   MONEY        CONSTRAINT [DF_tblXlinkUserSettings_DPFee] DEFAULT ((0)) NULL,
    [transmitter_fee]                         MONEY        CONSTRAINT [DF_tblXlinkUserSettings_transmitter_fee] DEFAULT ((0)) NULL,
    [main_office_review]                      CHAR (1)     NULL,
    [main_office_copy]                        CHAR (1)     NULL,
    [lock_returns]                            CHAR (1)     NULL,
    [fed_system_messages]                     CHAR (1)     NULL,
    [fed_reject_messages]                     CHAR (1)     NULL,
    [state_messages]                          CHAR (1)     NULL,
    [check_print]                             CHAR (1)     NULL,
    [crosslink_1040]                          VARCHAR (20) NULL,
    [state_return_printing]                   VARCHAR (20) NULL,
    [protection_plus]                         VARCHAR (20) NULL,
    [central_site_archive]                    VARCHAR (20) NULL,
    [transmit_type]                           CHAR (1)     NULL,
    [site_id]                                 VARCHAR (35) NULL,
    [prior_setup]                             CHAR (1)     NULL,
    [prior_billing]                           CHAR (1)     NULL,
    [prior_data]                              CHAR (1)     NULL,
    [prior_logins]                            CHAR (1)     NULL,
    [admin_password]                          VARCHAR (35) NULL,
    [enc_key]                                 VARCHAR (35) NULL,
    [lock_flag]                               CHAR (1)     NULL,
    [mef_flag]                                CHAR (1)     NULL,
    [textlink_messaging]                      VARCHAR (20) NULL,
    [franchiseuser_id]                        INT          NULL,
    [prior_appointments]                      CHAR (1)     NULL,
    [chk_userid]                              INT          NULL,
    [prior_franchise_user_id]                 INT          NULL,
    [self_prepared_fee]                       MONEY        NULL,
    [office_info1]                            VARCHAR (35) NULL,
    [office_info2]                            VARCHAR (35) NULL,
    [office_info3]                            VARCHAR (35) NULL,
    [office_info4]                            VARCHAR (35) NULL,
    [main_office_copy_docs]                   CHAR (1)     NULL,
    [hidden]                                  BIT          CONSTRAINT [DF_hidden] DEFAULT ((0)) NOT NULL,
    [bus_billing_schedule]                    INT          NULL,
    [auto_add_cadr_plus]                      CHAR (1)     NULL,
    [auto_add_audit_protection_non_financial] CHAR (1)     NULL,
    [no_prior_year_bal]                       CHAR (1)     NULL,
    [auto_add_iProtect]                       CHAR (1)     NULL,
    [turn_off_disbursements]                  CHAR (1)     NULL,
    [dont_bill_schda]                         CHAR (1)     NULL,
    [prevent_transmit_balance_due]            CHAR (1)     NULL,
    [password_recovery_email]                 VARCHAR (50) NULL,
    [password_recovery_phone]                 VARCHAR (10) NULL,
    [no_prior_year_prep]                      CHAR (1)     NULL,
    [disable_invoice_warning]                 CHAR (1)     NULL,
    [validate_prior_year_bal]                 CHAR (1)     NULL,
    CONSTRAINT [PK_tblXlinkUserSettings] PRIMARY KEY CLUSTERED ([usersettings_id] ASC),
    CONSTRAINT [UN_tblXlinkUserSettings] UNIQUE NONCLUSTERED ([user_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblXlinkUserSettings]
    ON [dbo].[tblXlinkUserSettings]([account_id] ASC);


GO
CREATE NONCLUSTERED INDEX [ID2_tblXlinkUserSettings]
    ON [dbo].[tblXlinkUserSettings]([franchiseuser_id] ASC);

