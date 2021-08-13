CREATE TABLE [dbo].[EFINContact] (
    [EfinContactID]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserID]             INT          NOT NULL,
    [ContactDescription] VARCHAR (25) NULL,
    [FirstName]          VARCHAR (15) NULL,
    [LastName]           VARCHAR (20) NULL,
    [CompanyName]        VARCHAR (35) NULL,
    [Address]            VARCHAR (50) NULL,
    [City]               VARCHAR (50) NULL,
    [State]              VARCHAR (2)  NULL,
    [Zip]                VARCHAR (10) NULL,
    [Email]              VARCHAR (75) NULL,
    [Phone]              VARCHAR (10) NULL,
    [Mobile]             VARCHAR (10) NULL,
    [Fax]                VARCHAR (10) NULL,
    [DOB]                DATETIME     NULL,
    [SSN]                VARCHAR (10) NULL,
    [Title]              VARCHAR (50) NULL,
    [IDNumber]           VARCHAR (50) NULL,
    [IDState]            VARCHAR (2)  NULL,
    CONSTRAINT [PK_EFINContact] PRIMARY KEY CLUSTERED ([EfinContactID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_EFINContact]
    ON [dbo].[EFINContact]([UserID] ASC);

