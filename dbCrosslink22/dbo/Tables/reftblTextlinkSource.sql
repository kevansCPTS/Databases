CREATE TABLE [dbo].[reftblTextlinkSource] (
    [pk_textlink_source_id] CHAR (1)     NOT NULL,
    [source]                VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_reftblTextlinkSource] PRIMARY KEY CLUSTERED ([pk_textlink_source_id] ASC),
    CONSTRAINT [IX_reftblTextlinkSource_Source_Unique] UNIQUE NONCLUSTERED ([source] ASC)
);

