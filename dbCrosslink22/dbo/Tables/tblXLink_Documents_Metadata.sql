CREATE TABLE [dbo].[tblXLink_Documents_Metadata] (
    [documents_metadata_id] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Season]                SMALLINT       NULL,
    [document_guid]         NVARCHAR (40)  NULL,
    [return_guid]           NVARCHAR (40)  NULL,
    [primary_id]            INT            NULL,
    [secondary_id]          INT            NULL,
    [document_description]  NVARCHAR (255) NULL,
    [form_name]             NVARCHAR (50)  NULL,
    [document_type]         CHAR (1)       NULL,
    [document_date]         CHAR (8)       NULL,
    [document_time]         CHAR (8)       NULL,
    [document_metadata]     XML            NULL,
    [status]                SMALLINT       NULL,
    [create_date]           DATETIME2 (7)  NULL,
    [modified_date]         DATETIME2 (7)  NULL,
    [deleted_date]          DATETIME2 (7)  NULL,
    [createdby_login_id]    INT            NULL,
    [modifiedby_login_id]   INT            NULL,
    [eSign]                 CHAR (1)       NULL,
    [remote_sign]           CHAR (1)       NULL,
    CONSTRAINT [PK_tblXLink_Documents_Metadata] PRIMARY KEY CLUSTERED ([documents_metadata_id] ASC)
);

