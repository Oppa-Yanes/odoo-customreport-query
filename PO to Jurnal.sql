SELECT
	po.name,
	sp.name,
	aml.*
FROM
	purchase_order_line pol
	LEFT JOIN purchase_order po ON po.id = pol.order_id
	LEFT JOIN stock_move sm ON sm.purchase_line_id = pol.id AND sm.product_id = pol.product_id
	LEFT JOIN stock_picking sp ON sp.id = sm.picking_id 
	LEFT JOIN account_move_line aml ON aml.purchase_line_id = pol.id
	LEFT JOIN account_move am ON am.id = aml.move_id
WHERE
	po.state IN ('purchase', 'done')
	AND po.name = 'PO-1100/2403-00178'
;	
	
SELECT DISTINCT
	po.name,
	'GRN' po_status,
	CAST(aml.move_id AS VARCHAR) journal_move_id,	
	CAST(aml.id AS VARCHAR) journal_item_id,
	aml.date journal_date,
	aml.parent_state AS state,
	CAST(aa.code AS VARCHAR) account_code,
        aa.name AS account_name,
	aa.internal_group account_group,
	aa.internal_type account_type,
        --aml.partner_id,
        --rp.name AS partner_name,
        aml.name AS description,
        aml.debit,
        aml.credit,
        aml.balance,
	am.move_type
	--sp.name,
FROM
	purchase_order_line pol
	LEFT JOIN purchase_order po ON po.id = pol.order_id
	LEFT JOIN account_move_line base_aml ON base_aml.purchase_line_id = pol.id
	LEFT JOIN account_move_line aml ON aml.move_id = base_aml.move_id
	LEFT JOIN account_move am ON am.id = aml.move_id
	LEFT JOIN account_account aa ON aml.account_id = aa.id
WHERE
	po.state IN ('purchase', 'done')
	AND aml.id IS NOT NULL
	AND po.name = 'PO-1100/2401-00034'
;
