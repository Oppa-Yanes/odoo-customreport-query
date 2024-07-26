SELECT 
	pr.name no_pr,
	regexp_replace(rb.login, '@.*$', '') request_by,
	pr.create_date creation_date,
	es.name estate,
	pr.pr_type,
	pr.sifat,
	pr.origin doc_source,
	prrs.approve_by pr_approve_by,
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
	regexp_replace(poby.login, '@.*$', '') po_create_by,
	vd.name vendor_name,
	po.po_type,
	po.date_order po_date,
	po.purchase_status,
	po.state po_state,
	po.date_approve po_approve_date,
	rfqrs.approve_by rfq_approve_by,
	pors.approve_by po_approve_by
FROM
	purchase_request_line prl
	LEFT JOIN purchase_request pr ON pr.id = prl.request_id
	LEFT JOIN plantation_estate es ON es.id = pr.estate_id
	LEFT JOIN res_users rb ON rb.id = pr.requested_by
	LEFT JOIN uom_uom uom ON uom.id = prl.product_uom_id
	LEFT JOIN purchase_request_purchase_order_line_rel prpol ON prpol.purchase_request_line_id = prl.id
	LEFT JOIN purchase_order_line pol ON pol.id = prpol.purchase_order_line_id
	LEFT JOIN purchase_order po ON po.id = pol.order_id
	LEFT JOIN res_users poby ON poby.id = po.user_id
	LEFT JOIN res_partner vd ON vd.id = po.partner_id
	LEFT JOIN (
		SELECT rs.name, string_agg(regexp_replace(ru.login, '@.*$', '')
			||CASE WHEN rs.state='approved' THEN '('||TO_CHAR(rs.write_date,'dd-mm-yyyy')||')' ELSE '(waiting)' END,
			', ' ORDER BY rs.sequence) approve_by
		FROM approval_release_strategy rs LEFT JOIN res_users ru ON ru.id = rs.user_id
		GROUP BY rs.name
		) prrs ON prrs.name = pr.name
	LEFT JOIN (
		SELECT rs.name, string_agg(regexp_replace(ru.login, '@.*$', '')
			||CASE WHEN rs.state='approved' THEN '('||TO_CHAR(rs.write_date,'dd-mm-yyyy')||')' ELSE '(waiting)' END,
			', ' ORDER BY rs.sequence) approve_by
		FROM approval_release_strategy rs LEFT JOIN res_users ru ON ru.id = rs.user_id
		GROUP BY rs.name
		) rfqrs ON rfqrs.name = po.rfq_number
	LEFT JOIN (
		SELECT rs.name, string_agg(regexp_replace(ru.login, '@.*$', '')
			||CASE WHEN rs.state='approved' THEN '('||TO_CHAR(rs.write_date,'dd-mm-yyyy')||')' ELSE '(waiting)' END,
			', ' ORDER BY rs.sequence) approve_by
		FROM approval_release_strategy rs LEFT JOIN res_users ru ON ru.id = rs.user_id
		GROUP BY rs.name
		) pors ON pors.name = CASE WHEN po.name = rfq_number THEN NULL ELSE po.name END
WHERE
	pr.create_date BETWEEN '2024-01-01' AND '2024-07-09'
ORDER BY 
	pr.name
;
