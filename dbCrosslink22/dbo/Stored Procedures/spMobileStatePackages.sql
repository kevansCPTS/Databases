

CREATE PROC [dbo].[spMobileStatePackages]
	@season int,
	@state varchar(4)
AS

/* replaces 2015 and prior query:
SELECT file_name, pkg_ver, rel_date 
FROM soft_rel WHERE pkg_id = '{0}' AND file_name > ''
AND rel_stat = 'R' ORDER BY pkg_ver DESC
*/

select sv.[FileName] as file_name, sv.[Version] as pkg_ver, sv.ReleaseDate as rel_date
from dbCrosslinkGlobal.dbo.tblSoftwareVersion sv 
where sv.Season = @season
and sv.ReleaseStatus = 'R'
and sv.SoftwarePackageId = @state
order by sv.[Version] desc


