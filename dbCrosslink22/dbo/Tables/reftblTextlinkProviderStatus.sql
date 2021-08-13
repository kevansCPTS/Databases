CREATE TABLE [dbo].[reftblTextlinkProviderStatus] (
    [pk_textlink_provider_status_id] INT          IDENTITY (1, 1) NOT NULL,
    [status]                         VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_reftblTextlinkProviderStatus] PRIMARY KEY CLUSTERED ([pk_textlink_provider_status_id] ASC),
    CONSTRAINT [IX_reftblTextlinkProviderStatus_Status_Unique] UNIQUE NONCLUSTERED ([status] ASC)
);

