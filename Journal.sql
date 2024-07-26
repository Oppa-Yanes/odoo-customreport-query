SELECT
	CAST(aml.id AS VARCHAR) AS journal_item_id,
	aml.date AS transaction_date,
	aml.parent_state AS state,
	am.move_type,
	--CAST(aml.account_id AS VARCHAR) account_id,
	CAST(aa.code AS VARCHAR) account_code,
	aa.name AS account_name,
	aa.internal_group account_group,
	aa.internal_type account_type,
	aml.partner_id,
	rp.name AS partner_name,
	aml.name AS description,
	aml.debit,
	aml.credit,
	aml.balance,
	am.id AS move_id,
	am.name AS move_name,
	am.ref AS reference,
	am.payment_reference,
	am.invoice_type,
	am.sequence_prefix,
	aml.write_date update_date,
	regexp_replace(ru.login, '@.*$', '') update_by
FROM 
	account_move_line aml
	LEFT JOIN account_move am ON aml.move_id = am.id
	LEFT JOIN account_account aa ON aml.account_id = aa.id
	LEFT JOIN res_partner rp ON aml.partner_id = rp.id
	LEFT JOIN res_users ru ON ru.id = aml.write_uid
WHERE 
	aml.date >= '2024-06-01' AND aml.date <= '2024-06-02'
ORDER BY
	aml.id
;
