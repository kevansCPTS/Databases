CREATE TABLE [dbo].[tblAncillaryProductGroup] (
    [groupId]         INT           IDENTITY (1, 1) NOT NULL,
    [name]            VARCHAR (255) NULL,
    [exclusiveSelect] BIT           CONSTRAINT [DF_tblAncillaryProductGroup_exclusiveSelect] DEFAULT ((0)) NOT NULL,
    [createDate]      DATETIME      CONSTRAINT [DF_tblAncillaryProductGroup_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]        VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductGroup_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate]      DATETIME      CONSTRAINT [DF_tblAncillaryProductGroup_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]        VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductGroup_modifyBy] DEFAULT (original_login()) NOT NULL,
    CONSTRAINT [PK_tblAncillaryProductGroup] PRIMARY KEY CLUSTERED ([groupId] ASC)
);


GO
    CREATE trigger [dbo].[trg_tblAncillaryProductGroup_Modify]
    on 
        [dbo].[tblAncillaryProductGroup]
    for
        update
    as
        update apg      
            set apg.modifyDate = getdate()
        ,   apg.modifyBy = SYSTEM_USER
        from
            tblAncillaryProductGroup apg join inserted i on apg.groupId = i.groupId













