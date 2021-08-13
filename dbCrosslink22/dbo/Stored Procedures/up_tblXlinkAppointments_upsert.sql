create procedure up_tblXlinkAppointments_upsert
	@appointmentID uniqueidentifier
,   @UserID int
,   @LoginID varchar(8)
,   @LoginName varchar(32)
,   @Subject varchar(255)
,   @AppointmentDate datetime
,   @Duration int
,   @Reminder int
,   @ClientName varchar(50)
,   @Address varchar(35)
,   @City varchar(35) 
,   @State varchar(2)
,   @Zip varchar(12)
,   @HomePhone varchar(10)
,   @WorkPhone varchar(10) 
,   @EmailAddress varchar(75) 
,   @Notes varchar(2000)
,   @Delivered bit
as

set nocount on


    update xa
        set xa.LoginID = @LoginID
    ,   xa.UserID = @UserID
    ,   xa.LoginName = @LoginName
    ,   xa.[Subject] = @Subject
    ,   xa.AppointmentDate = @AppointmentDate
    ,   xa.Duration = @Duration
    ,   xa.Reminder = @Reminder
    ,   xa.ClientName = @ClientName
    ,   xa.[Address] = @Address
    ,   xa.City = @City
    ,   xa.[State] = @State
    ,   xa.Zip = @Zip
    ,   xa.HomePhone = @HomePhone
    ,   xa.WorkPhone = @WorkPhone
    ,   xa.EmailAddress = @EmailAddress
    ,   xa.Notes = @Notes
    ,   xa.Delivered = @Delivered

    from
        dbo.tblXlinkAppointments xa
    where
        xa.appointmentID = @appointmentID


    if @@rowcount = 0
        insert [dbo].[tblXlinkAppointments](
            [appointmentID]
        ,   [UserID]
        ,   [LoginID]
        ,   [LoginName]
        ,   [Subject]
        ,   [AppointmentDate]
        ,   [Duration]
        ,   [Reminder]
        ,   [ClientName]
        ,   [Address]
        ,   [City]
        ,   [State]
        ,   [Zip]
        ,   [HomePhone]
        ,   [WorkPhone]
        ,   [EmailAddress]
        ,   [Notes]
        ,   [Delivered])
            values(
	            @appointmentID 
            ,   @UserID 
            ,   @LoginID
            ,   @LoginName
            ,   @Subject
            ,   @AppointmentDate 
            ,   @Duration
            ,   @Reminder 
            ,   @ClientName 
            ,   @Address
            ,   @City 
            ,   @State
            ,   @Zip 
            ,   @HomePhone
            ,   @WorkPhone
            ,   @EmailAddress
            ,   @Notes
            ,   @Delivered) 
