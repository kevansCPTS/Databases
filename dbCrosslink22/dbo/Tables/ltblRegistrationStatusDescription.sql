CREATE TABLE [dbo].[ltblRegistrationStatusDescription] (
    [Registered]       CHAR (1)     NOT NULL,
    [Description]      VARCHAR (25) NOT NULL,
    [SendToEFINMaster] BIT          CONSTRAINT [DF_ltblRegistrationStatusDescription_SendToEFINMaster] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ltblRegistrationStatusDescription] PRIMARY KEY CLUSTERED ([Registered] ASC)
);

