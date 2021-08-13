---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		jdaniel
-- Create date: 2020-09-03
-- Description:	Enroll ERO in ancillary product from the wallet
-- =============================================
CREATE PROCEDURE [dbo].[up_walletSetUserAncillaryProduct] --'ZZZ', '71B3541BD8F34A1C9E52BD90AECE7DA8', 1.00
	-- Add the parameters for the stored procedure here
	@productTag char(3),
	@walletToken    char(32),
	@addOn		money

AS

declare @aprodId            int
declare @account            varchar(8)
declare @userId             int
declare @errStr             varchar(255)
declare @cDate              datetime2               = getdate()
declare @uapInsert          bit
declare @xupInsert          bit

    set nocount on

    -- Bail if no ancillary product is found for the provided tag.
	select 
        @aprodId = ap.aprodId 
    from 
        dbo.tblAncillaryProduct ap
    where 
        ap.tag = @productTag
    
    if @aprodId is null
        begin
            set @errstr = 'No valid ancillary product for the specified product tag (' + @productTag + ').'      
            raiserror(@errstr,11,1) 
            return
        end   


    begin try

        -- Get the wallet ID for the provided wallet token.
        select 
            @account = w.account
        ,   @userId = w.userId
        from
            dbCrosslinkGlobal.dbo.tblWallet w
        where
            w.walletToken = @WalletToken

        -- Try to update the tblXlinkUserProducts record for the ancilary product given.
        update up 
            set up.eroAddonFee = @AddOn
        ,   up.modifyDate = getdate()
        ,   up.modifyBy = 'wallet' 
        from 
            dbo.tblXlinkUserProducts up join dbCrosslinkGlobal.dbo.tblWallet w on up.account = w.account 
                and up.userID = w.userId
                and w.walletToken = @WalletToken
                and up.tag = @ProductTag

        -- If the update did not apply to an existing record - try creating the records.
        if @@ROWCOUNT = 0
            begin

                set @uapInsert = 0

                -- Insert the tblUserAncillaryProduct record if it does not exist.
                if not exists(select up.userId from dbo.tblUserAncillaryProduct up where up.UserID = @userId and up.aprodid = @aprodId)
                    begin
                        insert dbo.tblUserAncillaryProduct(
                            userID
                        ,   aprodid
                        ,   ProductTag
                        ,   eroAddOn
                        ,   autoAdd
                        ,   autoAddFinancial
                        ,   autoAddNonFinancial
                        ,   agreeToParticipate
                        ,   createdDate
                        ,   createdBy
                        )
                            select
                                @UserId
                            ,   @aprodId
                            ,   @ProductTag
                            ,   1
                            ,   0
                            ,   0
                            ,   0
                            ,   1
                            ,   @cDate
                            ,   'wallet'

                        if @@rowcount = 1 
                            set @uapInsert = 1
                        else 
                            begin
                                raiserror(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d',11 , 1, @ProductTag, @Account, @UserId)                  
                                return
                            end
                    end


                set @xupInsert = 0

                -- Insert the tblXlinkUserProducts record
                if not exists(select xup.userId from dbo.tblXlinkUserProducts xup where xup.UserID = @userId and xup.aprodid = @aprodId)
                    begin
                        insert dbo.tblXlinkUserProducts(
                            userID
                        ,   account
                        ,   aprodId
                        ,   tag
                        ,   eroAddonFee
                        ,   autoAddFinancial
                        ,   autoAddNonFinancial
                        ,   createDate
                        ,   createBy
                        ,   modifyDate
                        ,   modifyBy
                        )
                            select
                                @UserId
                            ,   @Account
                            ,   @aprodId
                            ,   @ProductTag
                            ,   @AddOn
                            ,   0
                            ,   0
                            ,   @cDate
                            ,   'wallet'
                            ,   @cDate
                            ,   'wallet'

                        if @@rowcount = 1 
                            set @xupInsert = 1
                        else 
                            begin
                                -- If the process inserted the tblUserAncillaryProduct record - remove it. 
                                if @uapInsert = 1
                                    delete uap from dbo.tblUserAncillaryProduct uap where uap.UserID = @userId and uap.aprodid = @aprodId
                                raiserror(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d',11 , 1, @ProductTag, @Account, @UserId)                  
                                return
                            end
                    end
            end
            -- Generate the updated tag messages.
            exec dbo.spPublishTags @UserId                                                     

    end try


    begin catch
        declare @errMsg nvarchar(4000)

        set @errMsg = error_message()

        raiserror(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d - Error message: %s',11 , 1, @ProductTag, @Account, @UserId, @errMsg)                  
    end catch
    
    


/*
                insert dbo.tblXlinkUserProducts(
                    userID
                ,   account
                ,   aprodId
                ,   tag
                ,   eroAddonFee
                ,   autoAddFinancial
                ,   autoAddNonFinancial
                ,   createDate
                ,   createBy
                ,   modifyDate
                ,   modifyBy
                )
                    select
                        @UserId
                    ,   @Account
                    ,   @aprodId
                    ,   @ProductTag
                    ,   @AddOn
                    ,   0
                    ,   0
                    ,   @cDate
                    ,   'wallet'
                    ,   @cDate
                    ,   'wallet'
                    except
                        select
                            @UserId
                        ,   @Account
                        ,   @aprodId
                        ,   @ProductTag
                        ,   @AddOn
                        ,   0
                        ,   0
                        ,   @cDate
                        ,   'wallet'
                        ,   @cDate
                        ,   'wallet'
                        from
                            dbo.tblXlinkUserProducts up
                        where 
                            up.userID = @userId
                            and up.aprodId = @aprodId  
*/






