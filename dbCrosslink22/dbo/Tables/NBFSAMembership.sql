CREATE TABLE [dbo].[NBFSAMembership] (
    [NBFSAMembershipId]  INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [GUID]               VARCHAR (32) NULL,
    [userid]             INT          NULL,
    [efin]               INT          NOT NULL,
    [ssn]                INT          NOT NULL,
    [MembershipID]       VARCHAR (32) NOT NULL,
    [NoticeDate]         DATETIME     CONSTRAINT [DF_NBFSAMembership_NoticeDate] DEFAULT (getdate()) NOT NULL,
    [EffectiveDate]      DATETIME     CONSTRAINT [DF_NBFSAMembership_EffectiveDate] DEFAULT (getdate()) NOT NULL,
    [FirstName]          VARCHAR (20) NOT NULL,
    [LastName]           VARCHAR (32) NULL,
    [MemberAddress1]     VARCHAR (50) NOT NULL,
    [MemberAddress2]     VARCHAR (50) NULL,
    [MemberAddressCity]  VARCHAR (30) NOT NULL,
    [MemberAddressState] VARCHAR (2)  NOT NULL,
    [MemberAddressZip]   VARCHAR (12) NULL,
    [EmailAddress]       VARCHAR (70) NULL,
    [MemberLevel]        VARCHAR (15) CONSTRAINT [DF_Table_1_Level] DEFAULT ('MEMBERONLY') NOT NULL,
    [sent]               BIT          CONSTRAINT [DF_NBFSAMembership_sent] DEFAULT ((0)) NOT NULL,
    [sentDate]           DATETIME     NULL,
    [sentFileName]       VARCHAR (50) NULL,
    CONSTRAINT [PK_NBFSAMembership] PRIMARY KEY NONCLUSTERED ([NBFSAMembershipId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_NBFSAMembership]
    ON [dbo].[NBFSAMembership]([sent] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_NBFSAMembership]
    ON [dbo].[NBFSAMembership]([sentFileName] ASC, [sentDate] ASC);


GO
CREATE NONCLUSTERED INDEX [ID2_NBFSAMembership]
    ON [dbo].[NBFSAMembership]([MembershipID] ASC);

