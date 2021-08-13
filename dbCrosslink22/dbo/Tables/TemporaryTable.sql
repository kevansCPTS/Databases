CREATE TABLE [dbo].[TemporaryTable] (
    [SSN]        INT           NOT NULL,
    [FORM]       CHAR (4)      NOT NULL,
    [FORM_KEY]   CHAR (4)      NOT NULL,
    [FORM_VALUE] VARCHAR (250) NOT NULL
);


GO
CREATE CLUSTERED INDEX [ClusteredIndex-20160720-114951]
    ON [dbo].[TemporaryTable]([SSN] ASC, [FORM] ASC, [FORM_KEY] ASC, [FORM_VALUE] ASC);

