CREATE TABLE [dbo].[tblXlinkReferralDatabase] (
    [referral_id]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME     CONSTRAINT [DF_tblXlinkReferralDatabase_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME     CONSTRAINT [DF_tblXlinkReferralDatabase_update_date] DEFAULT (getdate()) NULL,
    [publish_date]     DATETIME     NULL,
    [account_id]       VARCHAR (8)  NULL,
    [user_id]          INT          NULL,
    [seq_num]          INT          NOT NULL,
    [referral]         VARCHAR (11) NOT NULL,
    [franchiseuser_id] INT          NULL,
    CONSTRAINT [PK_tblXlinkReferralDatabase] PRIMARY KEY CLUSTERED ([referral_id] ASC)
);

