---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		jdaniel
-- Create date: 2020-09-03
-- Description:	Enroll ERO in ancillary product from the wallet
-- =============================================
CREATE PROCEDURE [dbo].[ke_walletSetUserAncillaryProduct] --'ZZZ', '71B3541BD8F34A1C9E52BD90AECE7DA8', 1.00
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
declare @rCount             int

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
                -- Reset the row count to 0
                set @rCount = 0

                -- Insert the tblUserAncillaryProduct record.
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
                    except
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
                        from
                            dbo.tblUserAncillaryProduct ap
                        where
                            ap.UserID = @userId
                            and ap.aprodid = @aprodId

                -- Add the rows affected to the current count.
                set @rCount = @rCount + @@rowcount                                   

                -- Insert the tblXlinkUserProducts record
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

                -- Add the rows affected to the current count.
                set @rCount = @rCount + @@rowcount  

                -- If both records were inserted, execute the publish tags procedure.
                if @rCount = 2
                    exec dbo.spPublishTags @UserId                                                     
                else                    
                    begin
                        raiserror(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d',11 , 1, @ProductTag, @Account, @UserId)                  
                        return
                    end
            end
    end try


    begin catch
        select 
            @account = w.account
        ,   @userId = w.userId
        from
            dbCrosslinkGlobal.dbo.tblWallet w
        where
            w.walletToken = @WalletToken

        raiserror(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d',11 , 1, @ProductTag, @Account, @UserId)                  
    end catch
    
    








    /*



select * from tblXlinkUserProducts where account = 'DOEJOH' and userId = 60525	

	DECLARE @aprodId int
	DECLARE @Account varchar(8)
	DECLARE @UserId int
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Lookup the aprodId of the tag
	select @aprodId=aprodId from tblAncillaryProduct where tag = @ProductTag;

	-- Lookup the user and account info from the wallet
	select @Account=account, @UserId=userid from dbCrosslinkGlobal.dbo.tblWallet where walletToken=@WalletToken


	IF @aprodId > 0 begin
		
		-- First check to see if we already have an entry for this user
		if exists(select a.userid from tblUserAncillaryProduct a 
			inner join tblXlinkUserProducts b on a.UserID=b.userID and a.ProductTag=b.tag
				where b.account=@Account and b.userID=@UserId and b.tag=@ProductTag) 
		begin
			-- Record exists so update it so we know the wallet intended on processing it
			update tblXlinkUserProducts set eroAddonFee=@AddOn, modifyDate=getdate(), modifyBy='wallet' where account=@Account and userid=@UserId and aprodId=@aprodId and tag=@ProductTag 

		end 
		else
		begin

			BEGIN TRAN
			-- Record does not exist so go ahead and add it in
			 insert into dbCrosslink21.dbo.tblUserAncillaryProduct (userID, aprodid, ProductTag, eroAddOn, autoAdd, autoAddFinancial, autoAddNonFinancial, agreeToParticipate, createdDate, createdBy)
											   values  (@UserId, @aprodId, @ProductTag, 1, 0, 0, 0,1, getdate(), 'wallet');


			insert into dbCrosslink21.dbo.tblXlinkUserProducts (userID, account, aprodId, tag, eroAddonFee, autoAddFinancial, autoAddNonFinancial, createDate, createBy, modifyDate, modifyBy)
											   values (@UserId, @Account, @aprodId, @ProductTag, @AddOn, 0, 0, getdate(), 'wallet', getdate(), 'wallet');


												
			COMMIT TRAN

			-- Call sp to publish records
			exec spPublishTags @UserId
		end 

	end 
	else
	begin 

		RAISERROR(N'Could not persist ERO Ancillary opt in for Product Tag: %s, Account: %s, UserID: %d', @ProductTag, @Account, @UserId)
	
	end 
    */
