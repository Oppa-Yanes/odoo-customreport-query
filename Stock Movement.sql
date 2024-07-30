WITH stock_movement AS (
	SELECT
		CASE WHEN wh.id IS NULL THEN '' ELSE wh.code||' '||wh.name END AS warehouse,
		sml.product_id::TEXT product_id,
		CASE WHEN pt.id IS NULL THEN '' ELSE pt.default_code||' '||pt.name END AS product,
		COALESCE(pc.name, '') product_category,
		sml.date,
		COALESCE(sml.reference, '') reference,
		COALESCE(sld.complete_name, '') sent_from,
		COALESCE(sl.complete_name, '') sent_to,
		COALESCE(sml.qty_done, 0) receive_qty,
		0 sent_qty,
		COALESCE(uom.name, '') uom,
		COALESCE(svl.unit_cost,0) unit_price
	FROM
		stock_warehouse wh
		LEFT JOIN stock_location sl ON sl.id = wh.lot_stock_id
		LEFT JOIN stock_move_line sml ON sml.location_dest_id = wh.lot_stock_id
		LEFT JOIN stock_valuation_layer svl ON svl.product_id = sml.product_id AND svl.stock_move_id = sml.move_id
		LEFT JOIN stock_location sld ON sld.id = sml.location_id
		LEFT JOIN product_product pp ON pp.id = sml.product_id
		LEFT JOIN product_template pt ON pt.id = pp.product_tmpl_id
		LEFT JOIN product_category pc ON pc.id = pt.categ_id
		LEFT JOIN uom_uom uom ON uom.id = pt.uom_id
	WHERE
		wh.active
		AND sml.state = 'done'
	UNION ALL
	SELECT
		CASE WHEN wh.id IS NULL THEN '' ELSE wh.code||' '||wh.name END AS warehouse,
		sml.product_id::TEXT product_id,
		CASE WHEN pt.id IS NULL THEN '' ELSE pt.default_code||' '||pt.name END AS product,
		COALESCE(pc.name, '') product_category,
		sml.date,
		COALESCE(sml.reference, '') reference,
		COALESCE(sld.complete_name, '') sent_from,
		COALESCE(sl.complete_name, '') sent_to,
		0 receive_qty,
		COALESCE(sml.qty_done, 0) sent_qty,
		COALESCE(uom.name, '') uom,
		COALESCE(svl.unit_cost,0) unit_price
	FROM
		stock_warehouse wh
		LEFT JOIN stock_location sl ON sl.id = wh.lot_stock_id
		LEFT JOIN stock_move_line sml ON sml.location_id = wh.lot_stock_id
		LEFT JOIN stock_valuation_layer svl ON svl.product_id = sml.product_id AND svl.stock_move_id = sml.move_id
		LEFT JOIN stock_location sld ON sld.id = sml.location_dest_id
		LEFT JOIN product_product pp ON pp.id = sml.product_id
		LEFT JOIN product_template pt ON pt.id = pp.product_tmpl_id
		LEFT JOIN product_category pc ON pc.id = pt.categ_id
		LEFT JOIN uom_uom uom ON uom.id = pt.uom_id
	WHERE
		wh.active
		AND sml.state = 'done'
)
SELECT
	sm.*
FROM
	stock_movement sm
--WHERE
--	sm.product_id = '233'
ORDER BY
	sm.warehouse,
	sm.product,
	sm.date
;
