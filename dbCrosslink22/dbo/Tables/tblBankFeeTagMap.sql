CREATE TABLE [dbo].[tblBankFeeTagMap] (
    [bankId]     CHAR (1)     NOT NULL,
    [aprodId]    INT          NOT NULL,
    [bankTag]    CHAR (16)    NOT NULL,
    [createDate] DATETIME     CONSTRAINT [DF_tblBankFeeTagMap_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]   VARCHAR (50) CONSTRAINT [DF_tblBankFeeTagMap_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate] DATETIME     CONSTRAINT [DF_tblBankFeeTagMap_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]   VARCHAR (50) CONSTRAINT [DF_tblBankFeeTagMap_modifyBy] DEFAULT (original_login()) NOT NULL,
    CONSTRAINT [PK_tblBankFeeTagMap] PRIMARY KEY CLUSTERED ([bankId] ASC, [aprodId] ASC, [bankTag] ASC),
    CONSTRAINT [FK_tblBankFeeTagMap_tblAncillaryProduct] FOREIGN KEY ([aprodId]) REFERENCES [dbo].[tblAncillaryProduct] ([aprodId])
);


GO
    CREATE trigger [dbo].[trg_tblBankFeeTagMap_Modify]
    on 
        [dbo].[tblBankFeeTagMap]
    for
        update
    as
        update bftm      
            set bftm.modifyDate = getdate()
        ,   bftm.modifyBy = SYSTEM_USER
        from
            tblBankFeeTagMap bftm join inserted i on bftm.bankId = i.bankId
                and bftm.aprodId = i.aprodId
                and bftm.bankTag = i.bankTag












