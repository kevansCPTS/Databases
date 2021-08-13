CREATE TABLE [dbo].[tblAncillaryProduct] (
    [aprodId]                       INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [groupId]                       INT             NOT NULL,
    [tag]                           CHAR (3)        NOT NULL,
    [name]                          VARCHAR (255)   NULL,
    [company]                       VARCHAR (255)   NULL,
    [basePrice]                     MONEY           CONSTRAINT [DF_tblAncillaryProduct_basePrice] DEFAULT ((0)) NOT NULL,
    [basePriceAddon]                BIT             CONSTRAINT [DF_tblAncillaryProduct_basePriceAddOn] DEFAULT ((0)) NOT NULL,
    [eroAddon]                      BIT             NOT NULL,
    [desktop]                       BIT             CONSTRAINT [DF_tblAncillaryProduct_desktop] DEFAULT ((0)) NOT NULL,
    [mso]                           BIT             CONSTRAINT [DF_tblAncillaryProduct_mso] DEFAULT ((0)) NOT NULL,
    [typeAvailability]              TINYINT         CONSTRAINT [DF_tblAncillaryProduct_typeAvailability] DEFAULT ((0)) NOT NULL,
    [autoAdd]                       BIT             CONSTRAINT [DF_tblAncillaryProduct_typeAutoAdd] DEFAULT ((0)) NOT NULL,
    [comment]                       VARCHAR (255)   NULL,
    [createDate]                    DATETIME        CONSTRAINT [DF_tblAncillaryProduct_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]                      VARCHAR (50)    CONSTRAINT [DF_tblAncillaryProduct_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate]                    DATETIME        CONSTRAINT [DF_tblAncillaryProduct_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]                      VARCHAR (50)    CONSTRAINT [DF_tblAncillaryProduct_modifyBy] DEFAULT (original_login()) NOT NULL,
    [showAgreement]                 BIT             CONSTRAINT [DF_tblAncillaryProduct__showAgreement] DEFAULT ((0)) NOT NULL,
    [agreementImage]                VARBINARY (MAX) NULL,
    [agreementFileType]             VARCHAR (3)     NULL,
    [agreementHeader]               VARCHAR (100)   NULL,
    [agreementDescription]          VARCHAR (4000)  NULL,
    [baseEROAddOn]                  MONEY           NULL,
    [requireUserApproval]           BIT             CONSTRAINT [DF_tblAncillaryProduct_requireUserApproval] DEFAULT ((0)) NOT NULL,
    [doesNotRequireAccountApproval] BIT             CONSTRAINT [DF_tblAncillaryProduct_doesNotRequireAccountApproval] DEFAULT ((0)) NOT NULL,
    [maxEroAddonFee]                MONEY           NULL,
    CONSTRAINT [PK_tblAncillaryProduct] PRIMARY KEY CLUSTERED ([aprodId] ASC),
    CONSTRAINT [FK_tblAncillaryProduct_tblAncillaryProductGroup] FOREIGN KEY ([groupId]) REFERENCES [dbo].[tblAncillaryProductGroup] ([groupId])
);


GO
    CREATE trigger [dbo].[trg_tblAncillaryProduct_Modify]
    on 
        [dbo].[tblAncillaryProduct]
    for
        update
    as
        update ap      
            set ap.modifyDate = isnull(i.modifyDate,getdate())
        ,   ap.modifyBy = isnull(i.modifyBy,SYSTEM_USER)
        from
            tblAncillaryProduct ap join inserted i on ap.aprodId = i.aprodId
                and i.modifyBy is null
                    or i.modifyDate is null
                













