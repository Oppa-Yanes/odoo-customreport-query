SELECT
	ou.code company_code,
	est.code estate_code,
	est.name estate_name,
	lp.code,
	lp.active,
	bl.code block,
	div.name division,	
	lp.state,
	bl.topograph_id,
	bl.soil_id,
	COALESCE(lp.block_plasma, FALSE) plasma,
	COALESCE(lp.is_dummy, FALSE) dummy,
	COALESCE(est.is_nursery, FALSE) nursery,
	lp.planted_date,
	lp.plant_immature_age immature_age,
	lp.mature_date,
	lp.plant_mature_age mature_age,
	bl.block_area,
	lp.area_coefficient coefficient,
	lp.planted_area,
	lp.plant_total,
	lp.maturate_time_norm,
	lp.maturate_time_norm_uom
FROM
	plantation_land_planted lp
	LEFT JOIN plantation_land_block bl ON bl.id = lp.block_id

-- totalan

WITH aresta AS (
	SELECT
		ou.code company_code,
		est.code estate_code,
		est.name estate_name,
		lp.code,
		lp.active,
		bl.code block,
		div.name division,
		lp.state,
		bl.topograph_id,
		bl.soil_id,
		COALESCE(lp.block_plasma, FALSE) plasma,
		COALESCE(lp.is_dummy, FALSE) dummy,
		COALESCE(est.is_nursery, FALSE) nursery,
		lp.planted_date,
		lp.plant_immature_age immature_age,
		lp.mature_date,
		lp.plant_mature_age mature_age,
		COALESCE(bl.block_area, 0) block_area,
		COALESCE(lp.area_coefficient, 0) coefficient,
		COALESCE(lp.planted_area, 0) planted_area,
		COALESCE(lp.plant_total, 0) plant_total,
		lp.maturate_time_norm,
		lp.maturate_time_norm_uom
	FROM
		plantation_land_planted lp
		LEFT JOIN plantation_land_block bl ON bl.id = lp.block_id
		LEFT JOIN operating_unit ou on ou.id = lp.operating_unit_id 
		LEFT JOIN plantation_estate est ON est.id = bl.estate_id
		LEFT JOIN plantation_division div ON div.id = bl.division_id
)
SELECT
	company_code,
	estate_name,
	state,
	SUM(planted_area) planted_area,
	SUM(plant_total) planted_total,
	SUM(plant_total) / SUM(planted_area) sph
FROM
	aresta
GROUP BY
	company_code,
	estate_name,
	state
;
	LEFT JOIN operating_unit ou on ou.id = lp.operating_unit_id 
	LEFT JOIN plantation_estate est ON est.id = bl.estate_id
	LEFT JOIN plantation_division div ON div.id = bl.division_id
;
