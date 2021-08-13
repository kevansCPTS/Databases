

CREATE procedure up_rtnOtherUserId --100,333333333 --521001000
    @userId     int
,   @ssn        int
as

declare @account varchar(8)

    set nocount on

    -- Get target account code
    select
        @account = u.account
    from
        dbCrosslinkGlobal.dbo.tblUser u 
    where
        u.[user_id] = @userId


    -- Return the list of other user IDs for the same account that have a return with the same SSN 
    select
        rm.UserID
    from
        dbo.tblReturnMaster rm join dbCrosslinkGlobal.dbo.tblUser u on rm.UserID = u.[user_id]
            and rm.PrimarySSN = @ssn
            and u.account = @account
            and rm.UserID != @userId
