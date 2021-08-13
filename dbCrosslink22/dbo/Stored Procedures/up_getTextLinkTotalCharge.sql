
CREATE procedure [dbo].[up_getTextLinkTotalCharge]
as

    set nocount on

    select
        b.UserID
    ,   b.EFIN
    ,   b.signatureCount - isnull(rsc.charged_signatures,0) signatureCount
    ,   convert(decimal(16,4), (b.signatureCount - isnull(rsc.charged_signatures,0))) totalCharge
    --,   (SELECT b.signatureCount - (SELECT SUM(charged_signatures) from [dbCreditService].[dbo].[tblRemoteSignatureCharges] where user_id = b.UserID and efin = b.EFIN and status = 'success')) as signatureCount
    --,   convert(decimal(16,4), (SELECT b.signatureCount - (SELECT SUM(charged_signatures) from [dbCreditService].[dbo].[tblRemoteSignatureCharges] where user_id = b.UserID and efin = b.EFIN and status = 'success'))) totalCharge
    ,   ci.payment_account_id
    ,   payment_reference_number
    ,   network_transaction_id
    from
        dbCrosslinkGlobal.dbo.tblCardInformation ci join (
                                                            select 
                                                                rm.UserID
                                                            ,   rm.EFIN
                                                            ,   count(*) signatureCount
                                                            from
                                                                dbo.tblReturnMaster rm join (
                                                                                                select distinct  
                                                                                                    dsr.TaxReturnGUID
                                                                                                from
                                                                                                    dbo.tblTextLink tl join dbo.tblTextLinkMap tlm on tl.fk_textlink_map_id = tlm.pk_textlink_map_id
                                                                                                        and tl.print_job_id is not null
                                                                                                        and (tl.message_body like '%signature%'
                                                                                                            or tl.message_body like '%sigreq%')
                                                                                                    join dbo.tblDocumentForRemoteSigRequest dsr on tlm.print_guid = dsr.UniqueId
                                                                                                    join dbo.tblTaxPayerRemoteSignature rs on dsr.DocumentPk = rs.DocumentPk
                                                                                            ) a on rm.[GUID] = a.TaxReturnGUID
                                                            group by
                                                                rm.UserID
                                                            ,   rm.EFIN
                                                         ) b on ci.payment_reference_number = right('000000' + cast(USERID as varchar(6)), 6) + right('000000' + cast(EFIN as varchar(6)), 6)
            and ci.[status] = 1 
        left join (
                    select
                        rsc1.[user_id]
                    ,   rsc1.efin
                    ,   sum(rsc1.charged_signatures) charged_signatures
                    from
                        dbCreditService.dbo.tblRemoteSignatureCharges rsc1 
                    where
                        rsc1.[status] = 'success'
                    group by
                        rsc1.[user_id]
                    ,   rsc1.efin
                    ) rsc on b.userID = rsc.[user_id]
            and b.EFIN = rsc.efin
    where
        b.signatureCount - isnull(rsc.charged_signatures,0) > 0