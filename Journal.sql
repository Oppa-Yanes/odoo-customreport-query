SELECT 
	aml.date transaction_date,
	aml.parent_state AS state,
	CASE WHEN cc.id IS NULL THEN '' ELSE cc.code||' - '||cc.name END AS costcenter,
	--am.journal_id,
	CASE WHEN aj.id IS NULL THEN '' ELSE aj.code||' - '||aj.name END AS journal,
	--CAST(aml.id AS VARCHAR) AS journal_item_id,
	CASE WHEN aa.id IS NULL THEN '' ELSE aa.code||' - '||aa.name END AS account,
	--aa.internal_group account_group,
	--aa.internal_type account_type,
	--am.id move_id,
	--am.move_type,
	CASE WHEN am.name IS NULL THEN '' ELSE am.name END AS move_name,
	CASE WHEN am.ref IS NULL THEN '' ELSE am.ref END AS reference,
	CASE WHEN ct.code IS NULL THEN '' ELSE ct.code END AS allocation_code,
	CASE WHEN ca.id IS NULL THEN '' ELSE ca.code||' - '||ca.name END AS activity,
	CASE WHEN aml.name IS NULL THEN '' ELSE aml.name END AS description,
	--aml.partner_id,
	CASE WHEN rp.name IS NULL THEN '' ELSE rp.name END AS partner_name,
	CASE WHEN lp.code IS NULL THEN '' ELSE lp.code END AS planted_code,
	CASE WHEN pp.id IS NULL THEN '' ELSE pp.default_code||' - '||pp.name END AS product,
	CASE WHEN po.id IS NULL THEN '' ELSE po.name END AS po,	
	CASE WHEN ast.id IS NULL THEN '' ELSE ast.code||' - '||ast.name END AS asset,
	CASE WHEN bl.code IS NULL THEN '' ELSE bl.code END AS block_code,	
	CASE WHEN vra.id IS NULL THEN '' ELSE vra.code||' - '||vra.name END AS vra,
	CASE WHEN vra.type IS NULL THEN '' ELSE UPPER(vra.type) END AS vra_type,		
	CASE WHEN sts.id IS NULL THEN '' ELSE sts.code||' - '||sts.name END AS station,
	CASE WHEN div.id IS NULL THEN '' ELSE div.code||' - '||div.name END AS division,
	CASE WHEN div.mark IS NULL THEN '' ELSE div.mark END AS division_mark,			
	aml.debit,
	aml.credit,
	aml.balance,
	COALESCE(aa.is_transitory_account, FALSE) is_transitory_account,
	COALESCE(aa.depreciation_exp, FALSE) is_depreciation_exp,
	COALESCE(aml.is_advanced, FALSE) is_advanced,
	COALESCE(aml.is_landed_costs_line, FALSE) is_landed_cost,
	CASE WHEN am.payment_reference IS NULL THEN '' ELSE am.payment_reference END AS payment_reference,
	am.invoice_type,
	CASE WHEN am.sequence_prefix IS NULL THEN '' ELSE am.sequence_prefix END AS asequence_prefix,
	CASE WHEN ale.id IS NULL THEN '' ELSE ale.code||' - '||ale.name END AS allocation_to_estate,
	CASE WHEN alm.id IS NULL THEN '' ELSE alm.code||' - '||alm.name END AS allocation_to_mill,
	aml.write_date update_date,
	regexp_replace(ru.login, '@.*$', '') update_by
FROM 
	account_move_line aml
	LEFT JOIN account_move am ON aml.move_id = am.id
	LEFT JOIN account_account aa ON aml.account_id = aa.id
	LEFT JOIN account_journal aj ON aj.id = am.journal_id
	LEFT JOIN plantation_cost_center cc ON cc.id = aml.cost_center_id
	LEFT JOIN plantation_cost_type ct ON ct.id = aml.cost_allocation_id
	LEFT JOIN plantation_cost_activity ca ON ca.id = aml.cost_activity_id
	LEFT JOIN res_partner rp ON aml.partner_id = rp.id
	LEFT JOIN product_template pp ON pp.id = aml.product_id
	LEFT JOIN plantation_land_planted lp ON lp.id = cc.planted_area_id
	LEFT JOIN plantation_land_block bl ON bl.id = lp.block_id
	LEFT JOIN plantation_running vra ON vra.id = cc.running_id
	LEFT JOIN mill_station sts ON sts.id = cc.mill_station_id
	LEFT JOIN plantation_division div ON div.id = cc.divisi_id
	LEFT JOIN account_account ale ON ale.id = aa.allocation_kebun_id
	LEFT JOIN account_account alm ON alm.id = aa.allocation_pabrik_id
	LEFT JOIN purchase_order_line pol ON pol.id = aml.purchase_line_id
	LEFT JOIN purchase_order po ON po.id = pol.order_id
	LEFT JOIN account_asset ast ON ast.id = aml.account_asset_id
	LEFT JOIN res_users ru ON ru.id = aml.write_uid
WHERE 
	aml.date >= '2024-01-01' AND aml.date <= '2024-07-30'
ORDER BY
	am.journal_id,
	aml.id
;
