SELECT 
	pr.name no_pr,
	rb.login request_by,
	pr.create_date creation_date,
	es.name estate,
	pr.pr_type,
	pr.sifat,
	pr.origin doc_source,
	prrs.state pr_state,
	rsru.login pr_approve_by,
	prrs.create_date pr_approve_date,
	prl.name product_name,
	prl.product_qty pr_qty,
	uom.name uom,
	prl.date_required,
	prl.estimated_cost,
	pol.product_qty po_qty,
	pol.price_unit po_price_unit,
	pol.price_subtotal po_price_subtotal,
	pol.price_total po_price_total,
	pol.price_tax po_price_tax,
	pol.qty_received,
	pol.qty_to_invoice,
	pol.qty_invoiced,
	po.rfq_number,
	po.name po_number,
	vd.name vendor_name,
	po.po_type,
	po.date_order po_date,
	po.purchase_status,
	po.state po_state,
	po.date_approve po_approve_date,
	pors.approve_by po_approve_by
FROM
	purchase_request_line prl
	LEFT JOIN purchase_request pr ON pr.id = prl.request_id
	LEFT JOIN plantation_estate es ON es.id = pr.estate_id
	LEFT JOIN res_users rb ON rb.id = pr.requested_by
	LEFT JOIN approval_release_strategy prrs ON prrs.name = pr.name
	LEFT JOIN res_users rsru ON rsru.id = prrs.user_id
	LEFT JOIN uom_uom uom ON uom.id = prl.product_uom_id
	LEFT JOIN purchase_request_purchase_order_line_rel prpol ON prpol.purchase_request_line_id = prl.id
	LEFT JOIN purchase_order_line pol ON pol.id = prpol.purchase_order_line_id
	LEFT JOIN purchase_order po ON po.id = pol.order_id
	LEFT JOIN res_partner vd ON vd.id = po.partner_id
	LEFT JOIN (
		SELECT rs.name, string_agg(ru.login||'('||rs.state||')', ', ' ORDER BY rs.sequence) approve_by
		FROM approval_release_strategy rs LEFT JOIN res_users ru ON ru.id = rs.user_id
		GROUP BY rs.name
		) pors ON pors.name = po.name
WHERE
	pr.create_date BETWEEN '2024-06-01' AND '2024-06-30'
ORDER BY 
	pr.name
;
