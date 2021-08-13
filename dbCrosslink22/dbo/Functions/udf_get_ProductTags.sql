CREATE FUNCTION [dbo].[udf_get_ProductTags] (
    @userId     int 
)
RETURNS 
    varchar(max)
as
    begin

        declare @pTags varchar(max)

        select 
            @pTags = 
                    (
                        select
                            case
                                when ap.eroAddon = 1 and aap.agreeToParticipate = 1 and isnull(up.eroAddonFee, 0) > 0 then '<' + ap.tag + 'A>' + convert(varchar(40), replace(floor(isnull(up.eroAddonFee,0)*100), '.00','')) + '</' + ap.tag + 'A>'
                                else '<' + ap.tag + 'A/>'
                            end +
                            case
                                when ap.basePriceAddon = 1 and aap.agreeToParticipate = 1 then '<' + ap.tag + 'B>' + convert(varchar(40), replace(floor((IsNull(ap.basePrice,0) + IsNull(aap.addonAmount,0))*100), '.00','')) + '</' + ap.tag + 'B>'
                                when ap.basePriceAddon = 0 and aap.agreeToParticipate = 1 then '<' + ap.tag + 'B>' + convert(varchar(40), replace(floor((IsNull(ap.basePrice,0))*100), '.00','')) + '</' + ap.tag + 'B>'
                                else '<' + ap.tag + 'B/>'
                            end +
                            case
                                when ap.autoAdd = 1 and ap.typeAvailability in(1,3) and up.autoAddFinancial = 1 and aap.agreeToParticipate = 1 then '<' + ap.tag + 'F>X</' + ap.tag + 'F>'
                                else '<' + ap.tag + 'F/>'
                            end +
                            case
                                when ap.autoAdd = 1 and ap.typeAvailability = 3 and up.autoAddNonFinancial = 1 and aap.agreeToParticipate = 1 then '<' + ap.tag + 'N>X</' + ap.tag + 'N>'
                                else '<' + ap.tag + 'N/>'
                            end + '<' + ap.tag + 'L>' +
                            case
                                when ap.eroAddon = 1 then '1' else '0'
                            end +
                            case
                                when ap.autoAdd = 1 and ap.typeAvailability in (1,3) and up.autoAddFinancial = 1 then '1' else '0'
                            end +
                            case
                                when ap.autoAdd = 1 and ap.typeAvailability in (2,3) and up.autoAddNonFinancial = 1 then '1' else '0'
                            end + '</' + ap.tag + 'L>' +
                            '<' + ap.tag + 'I>' + dbo.udf_getAncillaryProdBankApprovalTag(aap.aprodId)  + '</' + ap.tag + 'I>'
                        from 
                            dbo.tbluser u join dbo.tblAccountAncillaryProduct aap on u.account = aap.account
                                and u.[user_id] = @userId
	                        join dbo.tblAncillaryProduct ap on aap.aprodId = ap.aprodId
	                        left join dbo.tblXlinkUserProducts up on aap.aprodId = up.aprodId
	                            and u.[user_id] = up.userid
                        for 
                            xml path ('')
                    ) 

        set @pTags = replace(replace(isnull(@ptags,''),'&lt;','<'),'&gt;','>') 

        return @ptags
  

    end
