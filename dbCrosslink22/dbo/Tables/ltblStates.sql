CREATE TABLE [dbo].[ltblStates] (
    [StateAbbr]                CHAR (2)     NOT NULL,
    [StateName]                VARCHAR (40) NULL,
    [ActualState]              BIT          NOT NULL,
    [IsLive]                   BIT          NOT NULL,
    [NR_IsLive]                BIT          NOT NULL,
    [Non_ELF]                  BIT          NOT NULL,
    [NR_Non_ELF]               BIT          NOT NULL,
    [DirectDeposit]            BIT          NOT NULL,
    [NR_DirectDeposit]         BIT          NOT NULL,
    [HasIncomeTax]             BIT          NOT NULL,
    [NonResident]              BIT          NOT NULL,
    [HelpID]                   INT          NULL,
    [Center]                   TINYINT      NULL,
    [Approval]                 DATETIME     NULL,
    [RequiredFedForSubmission] BIT          NULL,
    [releaseDate]              DATETIME     NULL,
    CONSTRAINT [PK_ltblStates] PRIMARY KEY CLUSTERED ([StateAbbr] ASC)
);

