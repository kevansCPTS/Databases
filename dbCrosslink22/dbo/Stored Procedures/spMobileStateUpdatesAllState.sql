
CREATE PROC spMobileStateUpdatesAllState
	@season int
AS

/* replaces 2015 and prior query:
SELECT distinct pkg_id, sname FROM soft_rel, terr 
WHERE code = pkg_id AND pkg_id IN 
(SELECT DISTINCT code FROM terr WHERE code <> 'XX') AND sname <> 'Massachusett'
*/

select distinct SoftwarePackageId as pkg_id, sname
from dbCrosslinkGlobal.dbo.tblSoftwareVersion sv 
inner join dbCrosslinkGlobal.dbo.terr t on code = SoftwarePackageId
where sv.Season = @season
and sv.ReleaseStatus = 'R'
AND sname <> 'Massachusett'

