CREATE TABLE [dbo].[tblStates] (
    [StateAbbr]  CHAR (2)     NOT NULL,
    [StateName]  VARCHAR (40) NOT NULL,
    [StateTaxes] BIT          CONSTRAINT [DF_tblStates_StateTaxes] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblStates] PRIMARY KEY CLUSTERED ([StateAbbr] ASC)
);

