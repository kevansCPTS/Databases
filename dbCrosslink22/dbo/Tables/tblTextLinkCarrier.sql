CREATE TABLE [dbo].[tblTextLinkCarrier] (
    [pk_textlink_carrier_id] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [carrier_name]           VARCHAR (50) NOT NULL,
    [domain]                 VARCHAR (50) NULL,
    CONSTRAINT [PK_tblTextLinkCarrier] PRIMARY KEY CLUSTERED ([pk_textlink_carrier_id] ASC)
);

