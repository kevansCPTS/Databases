CREATE TABLE [dbo].[tblTaxmastFee] (
    [pssn]       INT          NOT NULL,
    [aprodId]    INT          NOT NULL,
    [tag]        CHAR (3)     NOT NULL,
    [feeType]    TINYINT      NOT NULL,
    [bfTranId]   INT          NULL,
    [reqAmount]  MONEY        CONSTRAINT [DF_tblTaxmastFee_reqAmount] DEFAULT ((0)) NOT NULL,
    [payAmount]  MONEY        CONSTRAINT [DF_tblTaxmastFee_payAmount] DEFAULT ((0)) NOT NULL,
    [payDate]    DATE         NULL,
    [createDate] DATETIME     CONSTRAINT [DF_tblTaxmastFee_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]   VARCHAR (50) CONSTRAINT [DF_tblTaxmastFee_createBy] DEFAULT (original_login()) NOT NULL,
    [modifyDate] DATETIME     CONSTRAINT [DF_tblTaxmastFee_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]   VARCHAR (50) CONSTRAINT [DF_tblTaxmastFee_modifyBy] DEFAULT (original_login()) NOT NULL,
    CONSTRAINT [PK_tblTaxmastFee] PRIMARY KEY CLUSTERED ([pssn] ASC, [aprodId] ASC, [feeType] ASC),
    CONSTRAINT [FK_tblTaxmastFee_tblAncillaryProduct] FOREIGN KEY ([aprodId]) REFERENCES [dbo].[tblAncillaryProduct] ([aprodId])
);


GO
CREATE trigger [dbo].[trg_tblTaxmastFee_Modify]
    on 
        dbo.tblTaxmastFee
    for
        update
    as
        update tf      
            set tf.modifyDate = getdate()
        ,   tf.modifyBy = SYSTEM_USER
        from
            tblTaxmastFee tf join inserted i on tf.pssn = i.pssn 
                and tf.aprodId = tf.aprodId
