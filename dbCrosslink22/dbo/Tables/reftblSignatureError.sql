CREATE TABLE [dbo].[reftblSignatureError] (
    [remotesig_error_code] INT           IDENTITY (1, 1) NOT NULL,
    [error_name]           VARCHAR (40)  NOT NULL,
    [error_message]        VARCHAR (400) NOT NULL,
    [created_dttm]         DATETIME      NOT NULL,
    [updated_dttm]         DATETIME      NOT NULL,
    CONSTRAINT [PK_reftblSignatureError] PRIMARY KEY CLUSTERED ([remotesig_error_code] ASC)
);

