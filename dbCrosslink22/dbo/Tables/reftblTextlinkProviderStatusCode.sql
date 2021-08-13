CREATE TABLE [dbo].[reftblTextlinkProviderStatusCode] (
    [pk_textlink_provider_status_code_id] INT           NOT NULL,
    [code_desc]                           VARCHAR (MAX) NULL,
    CONSTRAINT [PK_reftblTextlinkProviderStatusCode] PRIMARY KEY CLUSTERED ([pk_textlink_provider_status_code_id] ASC)
);

