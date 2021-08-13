
CREATE procedure [dbo].[up_getPaymentCardSummary] --'COLTIM', 33 100 --'GUTXIO'
    @account        varchar(8)
,   @userId     int             = null
as

set nocount on

DECLARE @True bit = 1, @False bit = 0

--Account
--Address
--City
--Company
--EFIN
--HasCCUserEFIN
--UserID
--WalletToken

    -- If the account is the only paramater provided, return only the users 
    -- that are not franchise owners or children for the account.   
    if (@userId is null)
            select
			upper(u.account) Account
			--,	pl.ProductCode
            ,   case when e.Efin is null then u.addr1 else e.[Address] end Address
            ,   case when e.Efin is null then u.city else e.City end City
            ,   case when e.Efin is null then u.company else e.Company end Company
            ,   isnull(e.Efin, 0) Efin
            ,   u.user_id UserID
			,	case when ci1.id is not null then @True else @False end HasCCAccount
			,	case when ci3.id is not null then @true else @False end HasCCUser
			,	case when ci2.id is not null then @True else @False end HasCCUserEFIN
			--,	case when (ci2.user_id >= 500000 and ci2.id is not null) or (ci3.user_id < 500000 and ci3.id is not null) then @True else @False end HasCCUserEFIN
			--,	1 HasCCUserEFIN
			--,	case when u.user_id < 500000 then deskw.walletToken else clow.walletToken end WalletToken
			,	efintoken.walletToken EFINToken
			,	usertoken.walletToken USERToken
            from
				dbCrosslinkGlobal.dbo.tblUser u
                left join efin e on e.UserID = u.[user_id] and e.Account = u.account
                    and e.Account = @account
                    and e.Deleted != 1
                left join dbo.FranchiseOwner fo on u.[user_id] = fo.UserID  
                left join dbo.FranchiseChild fc on u.[user_id] = fc.ChildUserID
				-- c1 has a credit card for the account, user = 0, efin = 0
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci1 on ci1.account_code = u.Account and ci1.user_type = 'A' and ci1.efin = 0 and ci1.user_id = 0 and ci1.primary_card = 1
				-- c2 has a credit card for the account, user and efin
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci2 on ci2.efin = e.Efin and ci2.user_id = u.user_id and ci2.account_code = u.Account and ci2.primary_card = 1
				-- c3 has a credit card for the account and user, efin = 0
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci3 on ci3.efin = 0 and ci3.user_id = u.user_id and ci3.account_code = u.Account and ci3.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblWallet efintoken on efintoken.account = u.Account and efintoken.efin = e.Efin and efintoken.userId = u.user_id
				left join dbCrosslinkGlobal.dbo.tblWallet usertoken on usertoken.account = u.Account and usertoken.userId = u.user_id and usertoken.Efin = 0
				left join dbCrosslinkGlobal.dbo.tblProductLicense pl on pl.UserId = u.user_id and pl.Season = dbo.getXlinkSeason() and pl.ProductCode = 'USTP' and pl.Account = u.account
				and (pl.UserId < 500000 or (pl.UserId >= 500000))-- and e.Efin is not null))
            where
                fo.UserID is null
                and fc.ParentUserID is null
				and (pl.ProductCode is not null or e.efin is not null)
				and u.account = @account
				order by u.user_id
    -- Otherwise, get ONLY the provided user and it's franchise children.
    else
            select
			upper(u.account) Account
			--,	pl.ProductCode
            ,   case when e.Efin is null then u.addr1 else e.[Address] end Address
            ,   case when e.Efin is null then u.city else e.City end City
            ,   case when e.Efin is null then u.company else e.Company end Company
            ,   isnull(e.Efin, 0) Efin
            ,   u.user_id UserID
			,	case when ci1.id is not null then @True else @False end HasCCAccount
			,	case when ci3.id is not null then @true else @False end HasCCUser
			,	case when ci2.id is not null then @True else @False end HasCCUserEFIN
			--,	case when (ci2.user_id >= 500000 and ci2.id is not null) or (ci3.user_id < 500000 and ci3.id is not null) then @True else @False end HasCCUserEFIN
			--,	1 HasCCUserEFIN
			--,	case when u.user_id < 500000 then deskw.walletToken else clow.walletToken end WalletToken
			,	efintoken.walletToken EFINToken
			,	usertoken.walletToken USERToken
            from
				dbCrosslinkGlobal.dbo.tblUser u
                left join efin e on e.UserID = u.[user_id] and e.Account = u.account
                    and e.Account = @account
                    and e.Deleted != 1
                join (
                        select distinct
                            ChildUserID UserId
                        from
                            FranchiseChild 
                        where
                            ParentUserID = @userId
                        union select
                            UserID
                        from
                            FranchiseOwner fo
                        where
                            UserID = @userId
                        union select
                            user_id UserID
                        from
                            tbluser us
                        where
                            user_id = @userId
                      ) fou on u.[user_id] = fou.UserId
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci1 on ci1.account_code = u.Account and ci1.user_type = 'A' and ci1.efin = 0 and ci1.user_id = 0 and ci1.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci2 on ci2.efin = e.Efin and ci2.user_id = u.user_id and ci2.account_code = u.Account and ci2.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci3 on ci3.efin = 0 and ci3.user_id = u.user_id and ci3.account_code = u.Account and ci3.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblWallet efintoken on efintoken.account = u.Account and efintoken.efin = e.Efin and efintoken.userId = u.user_id
				left join dbCrosslinkGlobal.dbo.tblWallet usertoken on usertoken.account = u.Account and usertoken.userId = u.user_id and usertoken.Efin = 0
				left join dbCrosslinkGlobal.dbo.tblProductLicense pl on pl.UserId = u.user_id and pl.Season = dbo.getXlinkSeason() and pl.ProductCode = 'USTP' and pl.Account = u.account
				and (pl.UserId < 500000 or (pl.UserId >= 500000))-- and e.Efin is not null))
				where (pl.ProductCode is not null or e.efin is not null) 
				and u.account = @account
				order by u.user_id

