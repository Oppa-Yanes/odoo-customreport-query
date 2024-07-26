WITH initial_balance AS (
    SELECT 
        sml.product_id,
        SUM(CASE WHEN sml.date < '2024-01-01' AND sl.usage != 'internal' AND sld.usage = 'internal' THEN sml.qty_done ELSE 0 END) 
		- SUM(CASE WHEN sml.date < '2024-01-01' AND sl.usage = 'internal' AND sld.usage != 'internal' THEN sml.qty_done ELSE 0 END) AS initial_balance
    FROM
	    stock_move_line sml
            JOIN stock_location sl ON sml.location_id = sl.id
		    JOIN stock_location sld ON sml.location_dest_id = sld.id
        WHERE 
            sml.state = 'done'
        GROUP BY 
            sml.product_id
    ),
movements AS (
    SELECT 
        sml.product_id,
        SUM(CASE WHEN sml.date BETWEEN '2024-01-01' AND '2024-07-15' AND sl.usage != 'internal' AND sld.usage = 'internal' THEN sml.qty_done ELSE 0 END) AS movements_in,
        SUM(CASE WHEN sml.date BETWEEN '2024-01-01' AND '2024-07-15' AND sl.usage = 'internal' AND sld.usage != 'internal' THEN sml.qty_done ELSE 0 END) AS movements_out
    FROM
		stock_move_line sml
    	JOIN stock_location sl ON sml.location_id = sl.id
		JOIN stock_location sld ON sml.location_dest_id = sld.id
    WHERE 
        sml.state = 'done'
    GROUP BY 
        sml.product_id
    ),
last_unit_price AS (
    SELECT 
        sml.product_id,
        MAX(sml.date) AS last_move_date,
        (ARRAY_AGG(svl.unit_cost ORDER BY sml.date DESC))[1] AS last_unit_price
    FROM
		stock_valuation_layer svl
		LEFT JOIN stock_move_line sml ON sml.move_id = svl.stock_move_id
    WHERE 
		sml.date <= '2024-07-15' 
    GROUP BY 
        sml.product_id
    ),
last_good_receive AS (
    SELECT 
        sml.product_id, 
        MAX(sml.date) AS last_receive_date,
        (ARRAY_AGG(sml.reference ORDER BY sml.date DESC))[1] AS last_receive_document
    FROM
		stock_move_line sml
    	JOIN stock_location sl ON sml.location_id = sl.id
		JOIN stock_location sld ON sml.location_dest_id = sld.id
    WHERE 
        sml.state = 'done' 
		AND sl.usage != 'internal' 
		AND sld.usage = 'internal' 
		AND sml.date <= '2024-07-15' 
    GROUP BY 
        sml.product_id
    ),
last_good_issue AS (
    SELECT 
        sml.product_id, 
        MAX(sml.date) AS last_issue_date,
        (ARRAY_AGG(sml.reference ORDER BY sml.date DESC))[1] AS last_issue_document
    FROM
		stock_move_line sml
    	JOIN stock_location sl ON sml.location_id = sl.id
		JOIN stock_location sld ON sml.location_dest_id = sld.id
    WHERE 
        sml.state = 'done' 
		AND sl.usage = 'internal' 
		AND sld.usage != 'internal' 
		AND sml.date <= '2024-07-15' 
    GROUP BY 
        sml.product_id
    )
SELECT 
    p.id AS product_id,
    pt.name AS product_name,
    COALESCE(ib.initial_balance, 0) AS initial_balance,
    COALESCE(mv.movements_in, 0) AS movements_in,
    COALESCE(mv.movements_out, 0) AS movements_out,
	COALESCE(ib.initial_balance, 0) + COALESCE(mv.movements_in, 0) - COALESCE(mv.movements_out, 0) AS ending_balance,
	COALESCE(lup.last_unit_price, 0) AS unit_price,
	(COALESCE(ib.initial_balance, 0) + COALESCE(mv.movements_in, 0) - COALESCE(mv.movements_out, 0)) * COALESCE(lup.last_unit_price, 0) AS value,
    lgr.last_receive_document,
    lgr.last_receive_date,
    lgi.last_issue_document,
	lgi.last_issue_date
FROM 
    product_product p
	LEFT JOIN product_template pt ON pt.id = p.id
	LEFT JOIN initial_balance ib ON p.id = ib.product_id
	LEFT JOIN movements mv ON p.id = mv.product_id
	LEFT JOIN last_unit_price lup ON p.id = lup.product_id
	LEFT JOIN last_good_issue lgi ON p.id = lgi.product_id
	LEFT JOIN last_good_receive lgr ON p.id = lgr.product_id
ORDER BY 
    pt.name
;
