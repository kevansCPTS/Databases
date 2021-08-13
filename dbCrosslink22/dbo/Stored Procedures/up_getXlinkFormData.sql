
/************************************************************************************************
Name: up_getXlinkFormData

Purpose: Procedure to transform and extract the populated form data and merge it into the 
    complete form list based on the criteria provided.



Called By:

Parameters: 
    1 @state                char(2)
    2 @ftype                char(1)
    3 @account              varchar(8)
    4 @schedId              int
    5 @franchiseUserId      int


Result Codes:
    0 success

Author: Ken Evans 12/13/2012

Changes/Update:
    01/17/2013 - KJE
        Renamed the following output columns:
            val1 to per_item
            val2 to base_qty
            val3 to base_price
            




**************************************************************************************************/
CREATE procedure [dbo].[up_getXlinkFormData] --'AL','F','PETZ01',3,null   --@state = 'CA',@ftype = 'F',@account = 'PETZ01',@schedId = 36
    @state char(2)
,   @ftype char(1)
,	@fgroup varchar(4)
,   @account varchar(8)
,   @schedId int
,   @franchiseUserId int = null
as

declare @pvtBilling table (
    form_id                 varchar(6)
,   stateCode               char(2)
,   formType                char(1)
,   account_id              varchar(8)
,   schedule_id             int
,   franchiseuser_id        int
--,   val1                    decimal(16,2)
--,   val2                    decimal(16,2)
--,   val3                    decimal(16,2)
,   per_item                decimal(16,2)
,   base_qty                decimal(16,2)
,   base_price              decimal(16,2)
)

    set nocount on

    insert @pvtBilling
        select
            pvt.Form_ID
        ,   pvt.state_id
        ,   pvt.form_type
        ,   pvt.account_id
        ,   pvt.schedule_id
        ,   pvt.franchiseuser_id
        ,   pvt.[1] per_item
        ,   pvt.[2] base_qty
        ,   pvt.[3] base_price
        from
            (select
                left(xlb.form_id,6) Form_ID
            ,   xlb.state_id
            ,   xlb.form_type
            ,   xlb.account_id
            ,   xlb.form_price
            ,   xlb.schedule_id
            ,   xlb.franchiseuser_id
            ,   case right(xlb.form_id,1)
                    when '1' then 1  
                    when '4' then 1  
                    when '7' then 1  
                    when '2' then 2  
                    when '5' then 2  
                    when '8' then 2  
                    when '3' then 3  
                    when '6' then 3  
                    when '9' then 3  
                end posId
            from
                [tblXlinkBilling] xlb
            where
                xlb.state_id = @state
                and xlb.account_id = @account
                and xlb.form_type = @ftype
                and xlb.schedule_id = @schedId
                and isnull(xlb.franchiseuser_id,0) = isnull(@franchiseUserId,0)
            ) a
            pivot
                (
                    max(form_price)
                    for
                    posId in([1],[2],[3])
                ) pvt


    select
        xlf.form_id
    ,   xlf.[state]
    ,   xlf.form_type
	,	xlf.form_group
    ,   xlf.form_cd
    ,   xlf.form_short_name
    ,   xlf.form_long_name
    ,   pb.account_id
    ,   pb.schedule_id
    ,   pb.franchiseuser_id
    ,   pb.per_item
    ,   pb.base_qty
    ,   pb.base_price
    ,   case LEFT(xlf.form_type, 1)
            when 'F' then xlf.form_cd + '1'
            when 'W' then xlf.form_cd + '4'
            when 'L' then xlf.form_cd + '7'
            else null       
        end per_item_id
    ,   case LEFT(xlf.form_type, 1)
            when 'F' then xlf.form_cd + '2'
            when 'W' then xlf.form_cd + '5'
            when 'L' then xlf.form_cd + '8'
            else null       
        end base_qty_id 
    ,   case LEFT(xlf.form_type, 1)
            when 'F' then xlf.form_cd + '3'
            when 'W' then xlf.form_cd + '6'
            when 'L' then xlf.form_cd + '9'
            else null       
        end base_price_id 
    from
        [tblXlinkForms] xlf left join @pvtBilling pb on xlf.form_cd = pb.form_id
    where
        xlf.[state] = @state
        and xlf.form_type = @ftype
		and xlf.form_group = @fgroup
    order by
        xlf.form_type
    ,   xlf.form_id




