
CREATE PROC spMobileStateUpdatesByUser
	@season int,
	@user_id int
AS

/* replaces 2015 and prior query:
SELECT distinct pkg_id, sname FROM soft_user, terr 
WHERE code = pkg_id AND pkg_id IN 
(SELECT DISTINCT code FROM terr WHERE code <> 'XX') AND sname <> 
AND user_id = {0}
*/

SELECT DISTINCT sv.SoftwarePackageId as pkg_id, sname
from dbCrosslinkGlobal.dbo.tblSoftwareVersion sv 
inner join dbCrosslinkGlobal.dbo.terr t on code = sv.SoftwarePackageId
inner join dbCrosslinkGlobal.dbo.tblSoftwareUser u 
	on (sv.SoftwarePackageId = u.SoftwarePackageId and sv.Season = u.Season)
where sv.Season = @season
and sv.ReleaseStatus = 'R'
and UserId = @user_id
AND sname <> 'Massachusett'

