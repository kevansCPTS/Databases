CREATE TABLE [dbo].[tblTextLinkMap] (
    [pk_textlink_map_id]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [client_cell]               CHAR (10)     NOT NULL,
    [return_guid]               CHAR (32)     NULL,
    [fk_textlink_carrier_id]    INT           NULL,
    [fk_textlink_provider_cell] CHAR (10)     NOT NULL,
    [client_name]               VARCHAR (200) NULL,
    [print_guid]                CHAR (32)     NULL,
    [fk_textlink_process_id]    INT           NULL,
    [fk_textlink_source_id]     CHAR (1)      NULL,
    [source_user_id]            VARCHAR (25)  NULL,
    [business_return]           BIT           CONSTRAINT [DF_tblTextLinkMap_business_return] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTextLinkMap] PRIMARY KEY CLUSTERED ([pk_textlink_map_id] ASC),
    CONSTRAINT [FK_tblTextLinkMap_reftblTextlinkSource] FOREIGN KEY ([fk_textlink_source_id]) REFERENCES [dbo].[reftblTextlinkSource] ([pk_textlink_source_id]),
    CONSTRAINT [FK_tblTextLinkMap_tblTextLinkCarrier] FOREIGN KEY ([fk_textlink_carrier_id]) REFERENCES [dbo].[tblTextLinkCarrier] ([pk_textlink_carrier_id]),
    CONSTRAINT [FK_tblTextLinkMap_tblTextLinkProcess] FOREIGN KEY ([fk_textlink_process_id]) REFERENCES [dbo].[tblTextLinkProcess] ([pk_textlink_process_id]),
    CONSTRAINT [FK_tblTextLinkMap_tblTextLinkProviderCell] FOREIGN KEY ([fk_textlink_provider_cell]) REFERENCES [dbo].[tblTextLinkProviderCell] ([pk_textlink_provider_cell])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblTextLinkMap_cell_provider_cell]
    ON [dbo].[tblTextLinkMap]([client_cell] ASC, [fk_textlink_provider_cell] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTextLinkMap_source_id_source_user_id]
    ON [dbo].[tblTextLinkMap]([fk_textlink_source_id] ASC, [source_user_id] ASC);

