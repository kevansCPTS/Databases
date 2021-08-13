

CREATE PROCEDURE [dbo].[spInsertWebserviceSupUserID]
    @user_id int    
,   @account varchar(200)    
as
    IF NOT EXISTS(select 1 from WebserviceSupplementalUserID where User_ID = @user_id
                                                                and Account = @account)
    BEGIN
        INSERT INTO [dbo].[WebserviceSupplementalUserID]
                ([User_ID]
                ,[Account]
                ,[Created_Dt]
                ,[Updated_Dt])
            VALUES
                (@user_id
                ,@account
                ,GETDATE()
                ,GETDATE())
    END
