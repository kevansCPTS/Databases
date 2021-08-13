CREATE TABLE [dbo].[WebserviceAudit] (
    [webserviceAuditId] INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [bankCode]          VARCHAR (1) NULL,
    [recordType]        VARCHAR (1) NULL,
    [efin]              INT         NULL,
    [ssn]               INT         NULL,
    [sentSOAP]          XML         NULL,
    [recievedSOAP]      XML         NULL,
    [timestamp]         DATETIME    CONSTRAINT [DF_WebserviceAudit_timestamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WebserviceAudit] PRIMARY KEY CLUSTERED ([webserviceAuditId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_WebserviceAudit]
    ON [dbo].[WebserviceAudit]([ssn] ASC);


GO

/************************************************************************************************
Name: trgWebserviceAuditSSN

Purpose: Trigger to pull the ssn from the inserted xml and populate the ssn column in the table 
    for more efficient queries. 

Result Codes:
 0 success

Author: Ken Evans 02/06/2013

Changes/Update:
    None.

**************************************************************************************************/
CREATE TRIGGER [dbo].[trgWebserviceAuditSSN]
   ON  [dbo].[WebserviceAudit]
   AFTER INSERT
AS 
    
set nocount on

    begin try
        update wsa 
            --set wsa.ssn = convert(int,isnull(i.sentSOAP.value('(//*[local-name()="ssn"])[1]', 'varchar(9)'),i.sentSOAP.value('(//*[local-name()="ssn"])[2]', 'varchar(9)')))
            set wsa.ssn = convert(int,isnull(i.sentSOAP.value('(//*[local-name()="ssn"])[2]', 'varchar(9)'),i.sentSOAP.value('(//*[local-name()="ssn"])[1]', 'varchar(9)')))
        from    
            dbo.WebserviceAudit wsa join inserted i on wsa.webserviceAuditId = i.webserviceAuditId
    end try

    begin catch
        --Take no action
    end catch 



