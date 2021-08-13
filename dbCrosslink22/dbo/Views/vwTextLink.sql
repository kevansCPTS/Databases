
CREATE VIEW [dbo].[vwTextLink]
AS
SELECT	t.pk_textlink_id,
		t.fk_textlink_source_id AS 'source_id',
		t.source_user_id,
		t.fk_textlink_process_id AS 'process_id',
		t.message_date,
		t.message_body,
		t.outbound,
		t.sent, 
        t.login_id,
        t.provider_id,
		ps.status as 'provider_status',
		t.provider_status_sent_to_client,
		e.pk_textlink_error_id as 'error_id',
		e.reason as 'error_reason',
		e.error_desc as 'error_desc',
        m.client_cell,
        m.client_name,
        t.return_guid,
		t.print_job_id,
		m.fk_textlink_provider_cell,
		m.business_return,
		t.provider_received_dttm,
		t.provider_queued_dttm,
		t.provider_sent_dttm,
		t.provider_delivery_dttm
FROM    dbo.tblTextLink t
		INNER JOIN dbo.tblTextLinkMap m ON t.fk_textlink_map_id = m.pk_textlink_map_id
		LEFT JOIN reftblTextlinkProviderStatus ps WITH (NOLOCK) on ps.pk_textlink_provider_status_id = t.fk_textlink_provider_status_id
		LEFT JOIN tblTextlinkProcess p WITH (NOLOCK) ON p.pk_textlink_process_id = t.fk_textlink_process_id
		LEFT JOIN reftblTextlinkError e WITH (NOLOCK) ON e.pk_textlink_error_id = t.fk_textlink_error_id

