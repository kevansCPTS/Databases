CREATE TABLE [dbo].[tblPPRFeeMarkUp] (
    [account]        VARCHAR (8) NOT NULL,
    [userId]         INT         NOT NULL,
    [efin]           INT         CONSTRAINT [DF_tblPPRFeeMarkUp_efin] DEFAULT ((0)) NOT NULL,
    [prod_cd]        VARCHAR (4) NOT NULL,
    [fedMarkUp]      MONEY       CONSTRAINT [DF_tblPPRFeeMarkUp_fedMarkUp] DEFAULT ((0)) NOT NULL,
    [stateMarkUp]    MONEY       CONSTRAINT [DF_tblPPRFeeMarkUp_stateMarkUp] DEFAULT ((0)) NOT NULL,
    [busFedMarkUp]   MONEY       CONSTRAINT [DF_tblPPRFeeMarkUp_busFedMarkUp] DEFAULT ((0)) NOT NULL,
    [busStateMarkUp] MONEY       CONSTRAINT [DF_tblPPRFeeMarkUp_busStateMarkUp] DEFAULT ((0)) NOT NULL,
    [createDate]     DATETIME    CONSTRAINT [DF_tblPPRFeeMarkUp_createDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblPPRFeeMarkUp] PRIMARY KEY CLUSTERED ([account] ASC, [userId] ASC, [efin] ASC, [prod_cd] ASC)
);

