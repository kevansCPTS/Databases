CREATE TABLE [dbo].[tblTextLinkMapArchive] (
    [pk_textlink_map_id_for_backup] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pk_textlink_map_id]            INT           NOT NULL,
    [client_cell]                   CHAR (10)     NOT NULL,
    [return_guid]                   CHAR (32)     NULL,
    [user_id]                       INT           NULL,
    [fk_textlink_carrier_id]        INT           NULL,
    [fk_textlink_provider_cell]     CHAR (10)     NOT NULL,
    [client_name]                   VARCHAR (200) NULL,
    [business_return]               BIT           CONSTRAINT [DF_tblTextLinkMapArchive_business_return] DEFAULT ((0)) NOT NULL,
    [print_guid]                    CHAR (32)     NULL,
    [fk_textlink_process_id]        INT           NULL,
    CONSTRAINT [PK_tblTextLinkMap_for_backup] PRIMARY KEY NONCLUSTERED ([pk_textlink_map_id_for_backup] ASC),
    CONSTRAINT [FK_tblTextLinkMapArchive_tblTextLinkCarrier] FOREIGN KEY ([fk_textlink_carrier_id]) REFERENCES [dbo].[tblTextLinkCarrier] ([pk_textlink_carrier_id]),
    CONSTRAINT [FK_tblTextLinkMapArchive_tblTextLinkProcess] FOREIGN KEY ([fk_textlink_process_id]) REFERENCES [dbo].[tblTextLinkProcess] ([pk_textlink_process_id]),
    CONSTRAINT [FK_tblTextLinkMapArchive_tblTextLinkProviderCell] FOREIGN KEY ([fk_textlink_provider_cell]) REFERENCES [dbo].[tblTextLinkProviderCell] ([pk_textlink_provider_cell])
);


GO
CREATE NONCLUSTERED INDEX [IX_user_id_tblTextLinkMapArchive]
    ON [dbo].[tblTextLinkMapArchive]([user_id] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblTextLinkMapArchive_cell_print_user]
    ON [dbo].[tblTextLinkMapArchive]([client_cell] ASC, [print_guid] ASC, [user_id] ASC) WHERE ([print_guid] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblTextLinkMapArchive_cell_process_user]
    ON [dbo].[tblTextLinkMapArchive]([client_cell] ASC, [fk_textlink_process_id] ASC, [user_id] ASC) WHERE ([return_guid] IS NULL AND [print_guid] IS NULL);


GO
CREATE NONCLUSTERED INDEX [UX_tblTextLinkMapArchive_cell_return_user]
    ON [dbo].[tblTextLinkMapArchive]([client_cell] ASC, [return_guid] ASC, [user_id] ASC) WHERE ([return_guid] IS NOT NULL);

