CREATE TABLE [dbo].[WebserviceSupplementalUserID] (
    [User_ID]       INT           NOT NULL,
    [Account]       VARCHAR (200) NOT NULL,
    [Created_Dt]    DATETIME      NOT NULL,
    [Updated_Dt]    DATETIME      NULL,
    [For_Client_ID] VARCHAR (200) NULL,
    CONSTRAINT [PK_WebserviceSupplementalUserID] PRIMARY KEY CLUSTERED ([User_ID] ASC),
    CONSTRAINT [WSSupUserID_Unique_UserID_Account] UNIQUE NONCLUSTERED ([User_ID] ASC, [Account] ASC)
);

