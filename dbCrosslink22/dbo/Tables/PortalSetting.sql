CREATE TABLE [dbo].[PortalSetting] (
    [SettingName] VARCHAR (20)  NOT NULL,
    [Active]      BIT           CONSTRAINT [DF_PortalSetting_Active] DEFAULT ((0)) NOT NULL,
    [editedBy]    VARCHAR (30)  CONSTRAINT [DF_PortalSetting__editedBy] DEFAULT (original_login()) NOT NULL,
    [editDate]    DATETIME      CONSTRAINT [DF_PortalSetting__editDate] DEFAULT (getdate()) NOT NULL,
    [description] VARCHAR (255) NULL,
    CONSTRAINT [PK_PortalSetting] PRIMARY KEY CLUSTERED ([SettingName] ASC)
);

