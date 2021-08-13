

/************************************************************************************************
Name: up_getRushAppGuid

Purpose: To determine is a valid rush card application exists and return its guid after updating with 
    the supplied parameters. If it does not, create one with the supplied parameters and return the 
    newly created guid as a result and output parameter.


Called By:

Parameters: 
  1   @retId      int
  2   @FirstName varchar(32)
  3   @MiddleName varchar(32)
  4   @LastName varchar(32)
  5   @SSN varchar(9)
  6   @HomeTelephone varchar
  7   @CellTelephone varchar
  8   @Email varchar(64)
  9   @Address1 varchar(64)
  10  @Address2 varchar(64)
  11  @City varchar(32)
  12  @State varchar(2)
  13  @Zip varchar(10)
  14  @DateOfBirth datetime
  15  @TermsAndConditionsAccepted bit
  16  @StatusID int
  17  @Status varchar
  18  @ValidationTypes varchar
  19  @NotificationType int
  20  @NotificationSource varchar
  21  @efin int
  22  @rcaGuid varchar(38) output

Result Codes:
 0 success

Author: Ken Evans 12/03/2012

Changes/Update:

    KJE - 12/19/2012:
        Added @efin as an input parameter and included it in the corresponding insert and updates 
        int the procedure. 
    

**************************************************************************************************/
CREATE procedure [dbo].[up_getRushAppGuid]
    @retId      int
,   @FirstName varchar(32)
,   @MiddleName varchar(32)
,   @LastName varchar(32)
,   @SSN varchar(9)
,   @HomeTelephone varchar (max)
,   @CellTelephone varchar (max)
,   @Email varchar(64)
,   @Address1 varchar(64)
,   @Address2 varchar(64)
,   @City varchar(32)
,   @State varchar(2)
,   @Zip varchar(10)
,   @DateOfBirth datetime
,   @TermsAndConditionsAccepted bit
,   @StatusID int
,   @Status varchar (max)
,   @ValidationTypes varchar (max)
,   @NotificationType int
,   @NotificationSource varchar(max)
,   @efin   int
,   @rcaGuid varchar(38) output
as

declare @guid varchar(38)

set nocount on; 

    -- get existing guid for non-declined (if it exists)
    select
        @guid = ra.[GUID]
    from
        dbo.RushCardApplication ra
    where
        ra.[Status] != 'Declined'
        and ReturnId = @retId


    print @Status
    print @ValidationTypes



    -- if there is an existing record, return the guid, otherwise insert a new record and return that guid.
    if (@guid is null)
        begin 
            insert dbo.RushCardApplication(
                FirstName
            ,   MiddleName 
            ,   LastName 
            ,   SSN 
            ,   HomeTelephone 
            ,   CellTelephone 
            ,   Email 
            ,   Address1 
            ,   Address2 
            ,   City 
            ,   [State] 
            ,   Zip 
            ,   DateOfBirth
            ,   TermsAndConditionsAccepted 
            ,   StatusID 
            ,   [Status] 
            ,   ValidationTypes 
            ,   [GUID]
            ,   NotificationType 
            ,   NotificationSource 
            ,   ReturnId
            ,   Efin 
            )
                select
                    @FirstName
                ,   @MiddleName 
                ,   @LastName 
                ,   @SSN 
                ,   @HomeTelephone 
                ,   @CellTelephone 
                ,   @Email 
                ,   @Address1 
                ,   @Address2 
                ,   @City 
                ,   @State 
                ,   @Zip 
                ,   @DateOfBirth
                ,   @TermsAndConditionsAccepted 
                ,   @StatusID 
                ,   @Status 
                ,   @ValidationTypes 
                ,   newid()
                ,   @NotificationType 
                ,   @NotificationSource 
                ,   @retId 
                ,   @efin
            select
                @guid = ra.[guid]
            from
                dbo.RushCardApplication ra
            where
                ra.RushCardApplicationId = scope_identity()
        end
    else
        begin
            update ra
                set ra.FirstName = @FirstName
            ,   ra.MiddleName = @MiddleName
            ,   ra.LastName = @LastName
            ,   ra.SSN = @SSN 
            ,   ra.HomeTelephone = @HomeTelephone 
            ,   ra.CellTelephone = @CellTelephone 
            ,   ra.Email = @Email 
            ,   ra.Address1 = @Address1 
            ,   ra.Address2 = @Address2
            ,   ra.City = @City 
            ,   ra.[State] = @State 
            ,   ra.Zip = @Zip 
            ,   ra.DateOfBirth = @DateOfBirth
            ,   ra.TermsAndConditionsAccepted = @TermsAndConditionsAccepted
            ,   ra.StatusID = @StatusID 
            ,   ra.[Status] = @Status 
            ,   ra.ValidationTypes = @ValidationTypes 
            ,   ra.NotificationType = @NotificationType 
            ,   ra.NotificationSource = @NotificationSource 
            ,   ra.Efin = @efin
            from 
                dbo.RushCardApplication ra
            where
                ra.ReturnId = @retId
        end
    
    -- return the guid.
    set @rcaGuid = @guid

    select
        @guid [GUID]        


/*
INSERT INTO [dbCrosslink13].[dbo].[RushCardApplication] (
    [FirstName] 
,   [MiddleName] 
,   [LastName] 
,   [SSN] 
,   [HomeTelephone] 
,   [CellTelephone] 
,   [Email] 
,   [Address1] 
,   [Address2] 
,   [City] 
,   [State] 
,   [Zip] 
,   [DateOfBirth] 
,   [TermsAndConditionsAccepted] 
,   [StatusID] 
,   [Status] 
,   [ValidationTypes] 
,   [GUID] 
,   [NotificationType] 
,   [NotificationSource] 
,   [returnId] ) 
VALUES ('paulo' ,null ,'borges' ,'400000123' ,'209-555-1111' ,'209-675-0475' ,'pborges475@gmail.com' ,'655 fds' ,'123 fake st' ,'los banos' ,'CA' ,'93635' ,'12/12/1990' ,'0' ,'1' ,'Initialized' ,'what do i put here?' , newid() ,'0' ,'5555555555' ,'1171');

SELECT guid from [dbCrosslink13].[dbo].[RushCardApplication] where RushCardApplicationId = SCOPE_IDENTITY() 


INSERT INTO [dbCrosslink13].[dbo].[RushCardApplication]
,   ([ApplicationId]
,   ,[ApplicationDate]
,   ,[FirstName]
,   ,[MiddleName]
,   ,[LastName]
,   ,[SSN]
,   ,[HomeTelephone]
,   ,[CellTelephone]
,   ,[Email]
,   ,[Address1]
,   ,[Address2]
,   ,[City]
,   ,[State]
,   ,[Zip]
,   ,[DateOfBirth]
,   ,[Sex]
,   ,[PlasticType]
,   ,[PreferredLanguage]
,   ,[FeePlan]
,   ,[TermsAndConditionsAccepted]
,   ,[StatusID]
,   ,[Status]
,   ,[HeardAbout]
,   ,[PromoCode]
,   ,[ReferAFriendCode]
,   ,[SourceIP]
,   ,[CardNumber]
,   ,[CardVerificationCode]
,   ,[SubmitterName]
,   ,[PartnerReferrer]
,   ,[StatusUrl]
,   ,[RTN]
,   ,[DAN]
,   ,[ValidationTypes]
,   ,[GUID]
,   ,[NotificationType]
,   ,[NotificationSource]
,   ,[ReturnId])
     VALUES
    ApplicationId int
,   ApplicationDate datetimeoffset(7)
,   FirstName varchar(32)
,   MiddleName varchar(32)
,   LastName varchar(32)
,   SSN varchar(9)
,   HomeTelephone varchar
,   CellTelephone varchar
,   Email varchar(64)
,   Address1 varchar(64)
,   Address2 varchar(64)
,   City varchar(32)
,   State varchar(2)
,   Zip varchar(10)
,   DateOfBirth datetime
,   Sex varchar(1)
,   PlasticType varchar
,   PreferredLanguage varchar
,   FeePlan varchar
,   TermsAndConditionsAccepted bit
,   StatusID int
,   Status varchar
,   HeardAbout varchar
,   PromoCode varchar
,   ReferAFriendCode varchar
,   SourceIP varchar
,   CardNumber varchar(16)
,   CardVerificationCode int
,   SubmitterName varchar
,   PartnerReferrer varchar
,   StatusUrl varchar
,   RTN int
,   DAN varchar
,   ValidationTypes varchar
,   GUID varchar
,   NotificationType int
,   NotificationSource varchar
,   ReturnId int
GO

*/





