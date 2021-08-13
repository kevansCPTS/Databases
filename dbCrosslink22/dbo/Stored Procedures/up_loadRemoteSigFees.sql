CREATE procedure [dbo].[up_loadRemoteSigFees]
as

declare @season         smallint = '20' + right(db_name(),2)
declare @sqlStr         nvarchar(255)
declare @nodeNameRMSB   nvarchar(10)
declare @nodeNameRMSA   nvarchar(10)


create table #msoESig(
    returnId            varchar(255)
,   userId              int
,   efin                int
,   sigType             tinyint
,   dateCaptured        date
,   requestPk           int
,   documentPk          int
,   sigSeq              tinyint
,   RMSB                money
,   RMSA                money
)

    set nocount on

    set @nodeNameRMSB = 'RMSB'
    set @nodeNameRMSA = 'RMSA'

    -- Load new remote signature fees from desktop
    insert dbCrosslinkGlobal.dbo.tblRemoteSignatureFee(
        [season]
    ,   [returnGuid]
    ,   [userId]
    ,   [signatureType]
    ,   [deliveredDate]
    ,   [signaturePk]
    ,   [documentPk]
    ,   [basePrice]
    ,   [eroAddonFee]
    ,   [billableAddOnFee]
    )
        select 
            @season
        ,   rSig.TaxReturnGUID
        ,   rSig.UserId
        ,   rSig.SignatureType
        ,   rSig.DateDelivered
        ,   rSig.SignaturePk
        ,   rSig.DocumentPk
        ,   rsig.basePrice
        ,   rsig.eroAddonFee
        ,   rsig.billableAddOnFee
        from
            (
                select 
                    dsr.TaxReturnGUID
                ,   dsr.UserId
                ,   rs.SignatureType
                ,   rs.DateDelivered
                ,   rs.SignaturePk
                ,   rs.DocumentPk
                --,   dsr.[xmldata].value('(/REMOTEMETADATA/RMSB)[1]', 'int') basePrice --RMSB
                --,   isnull(dsr.[xmldata].value('(/REMOTEMETADATA/RMSA)[1]', 'int'),0) eroAddonFee --RMSA
                ,   convert(decimal(16,4),dsr.[xmldata].value('(/REMOTEMETADATA/RMSB)[1]', 'int') / 100.00) basePrice --RMSB
                ,   convert(decimal(16,4),isnull(dsr.[xmldata].value('(/REMOTEMETADATA/RMSA)[1]', 'int'),0) / 100.00) eroAddonFee --RMSA
                ,   case 
                        when c.service_bureau = 'X' and aap.agreeToTerms = 1 and aap.agreeToParticipate = 1 then 1
                        else 0
                    end billableAddOnFee
                ,   row_number() over ( partition by dsr.TaxReturnGUID, rs.SignatureType order by rs.DocumentPk asc) AS 'sigSeq'    
                from
                    dbo.tblTaxPayerRemoteSignature rs join dbo.tblDocumentForRemoteSigRequest dsr on rs.DocumentPk = dsr.DocumentPk
                        and rs.DateDelivered is not null
                        and rs.SignatureType in(1,2,7) -- Primary, Spouce and Business
                    join dbCrosslinkGlobal.dbo.tblUser u on dsr.UserId = u.[user_id]
                    join dbCrosslinkGlobal.dbo.customer c on u.account = c.account
                        and c.testCustomer = 0
                    left join dbo.tblAccountAncillaryProduct aap on c.account = aap.account
                        and aap.tag = 'RMS'
                    left join dbCrosslinkGlobal.dbo.tblRemoteSignatureFee rsf on dsr.TaxReturnGUID = rsf.returnGuid
                        and rs.SignatureType = rsf.signatureType
                        and rsf.season = @season
                where
                    rsf.rsId is null
                    and dsr.[xmldata].exist(N'//.[local-name()=sql:variable("@nodeNameRMSB")]') = 1
                    and isnumeric(dsr.[xmldata].value('(/REMOTEMETADATA/RMSB)[1]', 'varchar(10)')) = 1
                    and (dsr.[xmldata].exist(N'//.[local-name()=sql:variable("@nodeNameRMSA")]') = 0
                            or (dsr.[xmldata].exist(N'//.[local-name()=sql:variable("@nodeNameRMSA")]') = 1
                                and isnumeric(dsr.[xmldata].value('(/REMOTEMETADATA/RMSA)[1]', 'varchar(10)')) = 1))
            ) rSig left join dbCrosslinkGlobal.dbo.tblRemoteSignatureFee rsf on rSig.TaxReturnGUID = rsf.returnGuid
                and rSig.SignatureType = rsf.signatureType
                and rsf.season = @season
        where
            rsf.rsId is null
            and rSig.sigSeq = 1
            and isnull(rsig.basePrice,0) > 0 




    -- Load new remote signature fees from MSO

    -- pull from the correct MSO instance
    if left(@@SERVERNAME,2) = 'DE' 
        --set @sqlStr = 'exec DEVDB_MSO.Taxbrain' + right(db_name(),2) + '.dbo.up_getRemoteSignatureForBilling'
        set @sqlStr = 'select * from [DEVDB_MSO].Taxbrain' + right(db_name(),2) + '.dbo.vw_remoteSignatureBilling'

    if left(@@SERVERNAME,2) = 'QA' 
        --set @sqlStr = 'exec QADB_MSO.Taxbrain' + right(db_name(),2) + '.dbo.up_getRemoteSignatureForBilling'
        set @sqlStr = 'select * from [QADB_MSO].Taxbrain' + right(db_name(),2) + '.dbo.vw_remoteSignatureBilling'

    if left(@@SERVERNAME,2) = 'PR' 
        --set @sqlStr = 'exec [SRV-MSOSQL].Taxbrain' + right(db_name(),2) + '.dbo.up_getRemoteSignatureForBilling'
        set @sqlStr = 'select * from [SRV-MSOSQL].Taxbrain' + right(db_name(),2) + '.dbo.vw_remoteSignatureBilling'

--exec QADB_MSO.Taxbrain21.dbo.up_getRemoteSignatureForBilling

    insert #msoESig
        exec sp_executeSql @sqlStr


    -- Load new remote signature fees from MSO
    insert dbCrosslinkGlobal.dbo.tblRemoteSignatureFee(
        [season]
    ,   [returnGuid]
    ,   [userId]
    ,   [efin]
    ,   [signatureType]
    ,   [deliveredDate]
    ,   [signaturePk]
    ,   [documentPk]
    ,   [basePrice]
    ,   [eroAddonFee]
    ,   [billableAddOnFee]
    )
        select 
            @season
        ,   rSig.TaxReturnGUID
        ,   rSig.UserId
        ,   rsig.efin
        ,   rSig.SignatureType
        ,   rSig.dateCaptured
        ,   rSig.SignaturePk
        ,   rSig.DocumentPk
        ,   rSig.RMSB basePrice
        ,   rSig.RMSA addonFee
        ,   rsig.billableAddOnFee
        from
            (
                select 
                    m.returnId TaxReturnGUID
                ,   m.UserId
                ,   m.efin
                ,   m.sigType SignatureType
                ,   m.dateCaptured
                ,   m.requestPk SignaturePk
                ,   m.documentPk DocumentPk
                ,   m.sigSeq 
                ,   m.RMSB
                ,   m.RMSA 
                ,   case 
                        when c.service_bureau = 'X' and aap.agreeToTerms = 1 and aap.agreeToParticipate = 1 then 1
                        else 0
                    end billableAddOnFee
                from
                    #msoESig m join dbCrosslinkGlobal.dbo.tblUser u on m.UserId = u.[user_id]
                    join dbCrosslinkGlobal.dbo.customer c on u.account = c.account
                        and c.testCustomer = 0
                    left join dbo.tblAccountAncillaryProduct aap on c.account = aap.account
                        and aap.tag = 'RMS'
                    left join dbCrosslinkGlobal.dbo.tblRemoteSignatureFee rsf on m.returnId = rsf.returnGuid
                        and m.sigType = rsf.signatureType
                where
                    rsf.rsId is null
            ) rSig left join dbCrosslinkGlobal.dbo.tblRemoteSignatureFee rsf on rSig.TaxReturnGUID = rsf.returnGuid
                and rSig.SignatureType = rsf.signatureType
                and rsf.season = @season
        where
            rSig.sigSeq = 1
            and rsf.rsId is null


    drop table #msoESig



