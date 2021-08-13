
CREATE procedure [dbo].[up_selectedBank]
	@efin				int
,	@season				smallint
,	@selectedBank		char(1)			output
as

declare	@sqlstr nvarchar(255)

set nocount on

	set @sqlstr = 'select @sbank = e.selectedbank from dbCrosslink' + right(@season,2) + '.dbo.efin e where e.efin = @efin'

	begin try
		exec sp_executesql @sqlstr, N'@efin int, @sbank char(1) output',@efin = @efin, @sbank = @selectedBank output
	end try 

	begin catch 
		print 'Invalid season provided.'
		return 1
	end catch



