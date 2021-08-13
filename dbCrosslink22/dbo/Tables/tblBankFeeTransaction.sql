CREATE TABLE [dbo].[tblBankFeeTransaction] (
    [bfTranId]   INT           IDENTITY (1, 1) NOT NULL,
    [bankId]     CHAR (1)      NOT NULL,
    [bankTranId] VARCHAR (255) NOT NULL,
    [bankTag]    CHAR (16)     NOT NULL,
    [payAmount]  MONEY         NULL,
    [payDate]    DATE          NULL,
    [createDate] DATE          CONSTRAINT [DF_tblBankFeeTransaction_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]   VARCHAR (50)  CONSTRAINT [DF_tblBankFeeTransaction_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate] DATE          CONSTRAINT [DF_tblBankFeeTransaction_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]   VARCHAR (50)  CONSTRAINT [DF_tblBankFeeTransaction_modifyBy] DEFAULT (original_login()) NOT NULL,
    CONSTRAINT [PK_tblBankFeeTransaction] PRIMARY KEY CLUSTERED ([bfTranId] ASC)
);


GO
    CREATE trigger [dbo].[trg_tblBankFeeTransaction_Modify]
    on 
        [dbo].[tblBankFeeTransaction]
    for
        update
    as
        update bft      
            set bft.modifyDate = getdate()
        ,   bft.modifyBy = SYSTEM_USER
        from
            tblBankFeeTransaction bft join inserted i on bft.bfTranId = i.bfTranId












