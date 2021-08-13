CREATE procedure ke_clonePortalUser1 --22, 24
    @sUserId            int
,   @tUserId            int

as

declare @fran table(
	parentId				int
,	childId					int
)

declare @fcount             int
declare @badUsers			bit
declare @errstr             nvarchar(2048)
declare @result             xml

    set nocount on

    -- Check for the users being in the same franchise teir, or not at all
	insert @fran
		select
			fc.ParentUserID
		,	fc.ChildUserID
		from
			dbo.FranchiseChild fc
		where
			fc.ChildUserID in (@sUserId,@tUserId) 
		union select
			fo.UserID ParentUserID
		,   fo.UserID ChildUserID
		from
			dbo.FranchiseOwner fo
		where
			fo.UserID in (@sUserId,@tUserId) 

		set @fcount = @@ROWCOUNT

		if @fcount = 0
			set @badUsers = 0
		else if @fcount = 1
			set @badUsers = 1
		else if @fcount = 2
			begin
				select
					@fcount = count(distinct f.parentId)
				from	
					@fran f

				if @fcount != 1
					set @badUsers = 1
			end

	-- bail if the users are not in the same tier or both are not in the franchise tables   
    if @fcount != 0 and @fcount !=1
        begin
            set @errstr = 'The source UserId (' + convert(varchar(25),@sUserId) + ') and the target UserId (' +  convert(varchar(25),@tUserId) + ') are not in the same franchise tier.'  
            raiserror(@errstr,11,1)                   
            return          
        end



--select @fcount fCount