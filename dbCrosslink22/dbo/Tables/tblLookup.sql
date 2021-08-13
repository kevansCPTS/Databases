CREATE TABLE [dbo].[tblLookup] (
    [LookupID]          INT          NOT NULL,
    [LookupTypeID]      INT          NOT NULL,
    [LookupValue]       VARCHAR (20) NOT NULL,
    [LookupDescription] VARCHAR (50) NOT NULL,
    [SortOrder]         SMALLINT     CONSTRAINT [DF_tblLookup_SortOrder] DEFAULT ((0)) NOT NULL,
    [Active]            BIT          CONSTRAINT [DF_tblLookup_Active] DEFAULT ((1)) NOT NULL,
    [CreatedBy]         VARCHAR (50) CONSTRAINT [DF_tblLookup_CreatedBy] DEFAULT (suser_name()) NOT NULL,
    [CreatedDate]       DATETIME     CONSTRAINT [DF_tblLookup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]        VARCHAR (50) CONSTRAINT [DF_tblLookup_ModifiedBy] DEFAULT (suser_sname()) NULL,
    [ModifiedDate]      DATETIME     NULL,
    CONSTRAINT [PK_tblLookupItem] PRIMARY KEY CLUSTERED ([LookupID] ASC, [LookupTypeID] ASC)
);

