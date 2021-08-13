CREATE TABLE [dbo].[tblPPRBaseFee] (
    [prod_cd]         VARCHAR (4)   NOT NULL,
    [fedBaseFee]      MONEY         NULL,
    [stateBaseFee]    MONEY         NULL,
    [busFedBaseFee]   MONEY         NULL,
    [busStateBaseFee] MONEY         NULL,
    [createDate]      DATETIME2 (7) NOT NULL,
    CONSTRAINT [PK_tblPPRBaseFee] PRIMARY KEY CLUSTERED ([prod_cd] ASC)
);

