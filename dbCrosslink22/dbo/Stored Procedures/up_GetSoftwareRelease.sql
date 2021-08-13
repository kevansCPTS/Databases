
--exec up_GetSoftwareRelease

-- ==========================================================================
-- Author:		Jay Willis
-- Create date: 12/27/2019
-- 12/27/2019	Get the MSO and Desktop State Releases

-- Author:		Chuck Robertson
-- Modified date: 12/27/2019
-- 12/27/2019	Get the season from default season function
-- ==========================================================================
CREATE PROC [dbo].[up_GetSoftwareRelease]
AS
	SET NOCOUNT ON


select	1 as MSO, 
		0 as Business, 
		s.StateAbbr, 
		s.StateName, 
		case when releaseDate is null then 'Pending'
			 else convert(char(10), releaseDate, 110) 
		end 'ReleaseDate'
from ltblstates s
join tblStates st
on s.StateAbbr = st.StateAbbr
where ActualState = 1
and st.StateTaxes = 1

union

select 
	0 as MSO
,	case when len(sv.SoftwarePackageId) = 3 then '1' else '0' end as Business
,	s.StateAbbr
,	s.StateName
,		case when sv.ReleaseDate is null then 'Pending'
			 when sv.ReleaseDate is not null and sv.ReleaseStatus = 'R' then convert(varchar(10), sv.ReleaseDate, 110) 
		end 'ReleaseDate'
from ltblStates s
left join dbcrosslinkGlobal..tblSoftwareVersion sv on left(sv.SoftwarePackageId,2) = s.StateAbbr and sv.season = dbo.getxlinkseason() and sv.Version  = 1
where (s.StateAbbr not in (select StateAbbr from tblStates where StateTaxes = 0) or len(sv.SoftwarePackageId) = 3)
and ActualState = 1
--where s.StateTaxes = 1
order by
    MSO, StateName, Business
