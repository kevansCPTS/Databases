CREATE procedure up_MobileReportCallLog --19584, null --,'RIVEDG'
	@userId		int				= null
,	@account	varchar(8)		= null
as

declare @errstr		varchar(1000)
 
declare @ulist table (
	userId		int
)

	set nocount on

	-- check to see that the parameters are correct
	if (@userId is null and @account is null) or (@userId is not null and @account is not null) 
		begin
            set @errstr = 'You must provide either an account code or a user Id to execute the procedure.'      
            raiserror(@errstr,11,1)                   
            return
		end 

	-- populate the user table variable for the account parameter 
	if @account is not null 
		insert @ulist
			select
				u.[user_id] userId
			from
				(
					select
						u1.[user_id]
					from
						dbCrosslinkGlobal.dbo.tblUser u1
					where
						u1.account = @account
						and u1.[status] = 'L'
				) u left join (
								select
									fc.ChildUserID userId	
								from
									dbo.FranchiseChild fc
								union select
									fo.UserID
								from
									dbo.FranchiseOwner fo
								) f on u.[user_id] = f.userId
			where
				f.userId is null

	-- populate the user table variable for the user parameter 
	if @userId is not null
		insert @ulist
			select distinct
				fc.ChildUserID userId
			from
				dbo.FranchiseChild fc join dbCrosslinkGlobal.dbo.tblUser u on fc.ChildUserID = u.[user_id]
					and fc.ParentUserID = @userId
					and u.[status] = 'L'
			union select
				@userId

	-- gernerate the result set.
	select
		cl.seq_no
	,	cl.[user_id]
	,	cl.ver
	,	cl.[time]
	from
		(
			select
				cl1.seq_no
			,	cl1.[user_id]
			,	cl1.ver
			,	cl1.dt_mm + '/' + cl1.dt_dd + '-' + cl1.dt_hh + ':' + cl1.dt_mi [time]
			,	row_number() over ( partition by cl1.[user_id] order by cl1.seq_no desc) AS 'RowNumber'
			from
				dbo.call_log cl1 join @ulist u on cl1.[user_id] = u.userId
					and cl1.stat = 'L'
		) cl
	where
		cl.RowNumber = 1
