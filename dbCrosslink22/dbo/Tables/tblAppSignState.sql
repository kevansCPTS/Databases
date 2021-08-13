CREATE TABLE [dbo].[tblAppSignState] (
    [mobile_sig_status_id] INT           IDENTITY (1, 1) NOT NULL,
    [document_key]         INT           NULL,
    [beanstalk_id]         INT           NULL,
    [mobile_calc_status]   INT           NULL,
    [print_job_guid]       VARCHAR (200) NULL,
    [signature_url]        VARCHAR (200) NULL,
    [ssn]                  VARCHAR (20)  NOT NULL,
    [filing_status]        INT           NOT NULL,
    [user_id]              INT           NOT NULL,
    [CreatedDate]          DATETIME2 (7) CONSTRAINT [DF_tblAppSignState_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]         DATETIME2 (7) CONSTRAINT [DF_tblAppSignState_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblAppSignState] PRIMARY KEY CLUSTERED ([mobile_sig_status_id] ASC),
    CONSTRAINT [FK_tblAppSignState_reftblMobileCalcStatus] FOREIGN KEY ([mobile_calc_status]) REFERENCES [dbo].[reftblMobileCalcStatus] ([mobile_calc_status]),
    CONSTRAINT [FK_tblAppSignState_tblDocumentForRemoteSigRequest] FOREIGN KEY ([document_key]) REFERENCES [dbo].[tblDocumentForRemoteSigRequest] ([DocumentPk])
);

