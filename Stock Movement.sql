WITH stock_movement AS (
	SELECT
		wh.code wh_code,
		wh.name wh_name,
		sml.product_id,
		pt.default_code product_code,
		pt.name product_name,
		pc.name product_category,
		sml.date,
		sml.reference,
		sld.complete_name sent_from,
		sl.complete_name sent_to,
		sml.qty_done receive_qty,
		0 sent_qty,
		uom.name uom,
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
		wh.code wh_code,
		wh.name wh_name,
		sml.product_id,
		pt.default_code product_code,
		pt.name product_name,
		pc.name product_category,
		sml.date,
		sml.reference,
		sl.complete_name sent_from,
		sld.complete_name sent_to,
		0 receive_qty,
		sml.qty_done sent_qty,
		uom.name uom,
		COALESCE(svl.unit_cost,0)  unit_price
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
	sm.wh_code,
	sm.product_name,
	sm.date
;
