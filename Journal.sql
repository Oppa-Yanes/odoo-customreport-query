SELECT 
    aml.id AS journal_item_id,
    aml.date AS transaction_date,
	aml.parent_state AS state,
    aml.account_id,
    aa.name AS account_name,
    aml.partner_id,
    rp.name AS partner_name,
    aml.name AS description,
    aml.debit,
    aml.credit,
    aml.balance,
    am.id AS move_id,
    am.name AS move_name,
    am.ref AS reference,
	aml.write_date update_date,
	regexp_replace(ru.login, '@.*$', '') update_by
FROM 
    account_move_line aml
	JOIN account_move am ON aml.move_id = am.id
	LEFT JOIN account_account aa ON aml.account_id = aa.id
	LEFT JOIN res_partner rp ON aml.partner_id = rp.id
	LEFT JOIN res_users ru ON ru.id = aml.write_uid
WHERE 
    aml.date >= '2024-06-01' AND aml.date <= '2024-06-02'
;
