-- Produksi TBS

WITH 
target_tbs_olah AS (
	SELECT b.year tahun,
		UNNEST(array['01','02','03','04','05','06','07','08','09','10','11','12']) AS bulan,
    	UNNEST(array[a.target_januari, a.target_februari, a.target_maret, a.target_april,
					a.target_mei, a.target_juni, a.target_juli, a.target_agustus,
					a.target_september, a.target_oktober, a.target_november, a.target_desember
		]) AS target
	FROM 
		hit_mill_target_olah_after_import_to_item_line a
		LEFT JOIN hit_mill_target_olah_after_import_to b ON b.id = a.import_to_id
	WHERE
		a.target like 'TBS Olah'
		AND a.import_to_id IS NOT NULL
),
actual_tbs_olah AS (
	SELECT 
		TO_CHAR(b.datetime_production, 'yyyy') tahun,
		TO_CHAR(b.datetime_production, 'mm') bulan,
		SUM(a.daily) aktual
	FROM
		hit_mill_dailyreport_produksi_tbs_line a
		LEFT JOIN hit_mill_dailyreport_produksi b ON b.id = a.produksi_id
	WHERE
		a.uraian = 'TBS Olah'
	GROUP BY 
		TO_CHAR(b.datetime_production, 'yyyy'),
		TO_CHAR(b.datetime_production, 'mm')
)
SELECT
	a.tahun,
	a.bulan,
	COALESCE(a.target, 0) target,
	COALESCE(b.aktual, 0) aktual
FROM
	target_tbs_olah a
	LEFT JOIN actual_tbs_olah b ON b.tahun = a.tahun AND b.bulan = a.bulan
ORDER BY
	a.tahun,
	b.bulan
;

-----

WITH pbat AS (
  SELECT 
    pbat.budget_year::text AS tahun, 
    --RIGHT('0'||ltrim(pbat.budget_month::text),2) AS bulan, 
	LTRIM(pbat.budget_month, '0') AS bulan, 
    CASE
		WHEN pe.name ~~ '%MUSI%' THEN 'MME' 
		WHEN pe.name ~~ '%LEMATANG%' THEN 'LME' 
		WHEN pe.name ~~ 'PLASMA%' AND pe.name ~~ '%1' THEN 'PAM1' 
		WHEN pe.name ~~ 'PLASMA%' AND pe.name ~~ '%2' THEN 'PAM2' 
		ELSE NULL::text
	END AS estate,
	pe.name AS estate_name,
    COALESCE(pbat.budget_berat,0) AS budget_berat,
	COALESCE(pbat.budget_janjang,0) AS budget_janjang
  FROM 
    plantation_budget_allocation_temporary pbat 
    LEFT JOIN plantation_estate pe ON pe.id = pbat.estate_id 
)
SELECT
  	pbat.tahun,
	pbat.bulan,
	pbat.estate,
	pbat.estate_name,
	SUM(pbat.budget_berat) AS budget_berat,
	SUM(pbat.budget_janjang) AS budget_janjang,
	SUM(pbat.budget_berat) / SUM(pbat.budget_janjang) AS bjr
FROM
	pbat pbat
GROUP BY 
    pbat.tahun, 
	pbat.bulan,
	pbat.estate,
	pbat.estate_name
ORDER BY 
    pbat.tahun, 
	RIGHT('0'||ltrim(pbat.bulan),2),
	pbat.estate
;

-- Produksi TBS, akt vs budget

WITH bp AS (
	WITH bp AS (
		SELECT 
    		bp.budget_year::text AS tahun,
			LTRIM(bp.budget_month, '0') AS bulan, 
    		CASE
				WHEN est.name ~~ '%MUSI%' THEN 'MME' 
				WHEN est.name ~~ '%LEMATANG%' THEN 'LME' 
				WHEN est.name ~~ 'PLASMA%' AND est.name ~~ '%1' THEN 'PAM1' 
				WHEN est.name ~~ 'PLASMA%' AND est.name ~~ '%2' THEN 'PAM2' 
				ELSE NULL::text
			END AS estate,
			est.name AS estate_name,
    		COALESCE(bp.budget_berat,0) AS budget_berat,
			COALESCE(bp.budget_janjang,0) AS budget_janjang
  		FROM 
    		plantation_budget_allocation bp 
    		LEFT JOIN plantation_estate est ON est.id = bp.estate_id 
	)
	SELECT
  		bp.tahun,
		bp.bulan,
		bp.estate,
		bp.estate_name,
		SUM(bp.budget_berat) AS budget_berat,
		SUM(bp.budget_janjang) AS budget_janjang,
		SUM(bp.budget_berat) / SUM(bp.budget_janjang) AS bjr
	FROM
		bp
	GROUP BY 
    	bp.tahun, 
		bp.bulan,
		bp.estate,
		bp.estate_name
	),
WITH ap AS (
	WITH ap AS (
		SELECT
  			DATE_PART('year', wb.date_in) AS tahun, 
  			DATE_PART('month', wb.date_in) AS bulan, 
  			CASE
				WHEN est.name ~~ '%MUSI%' THEN 'MME' 
				WHEN est.name ~~ '%LEMATANG%' THEN 'LME' 
				WHEN est.name ~~ 'PLASMA%' AND est.name ~~ '%1' THEN 'PAM1' 
				WHEN est.name ~~ 'PLASMA%' AND est.name ~~ '%2' THEN 'PAM2' 
				ELSE NULL::text
  			END AS estate,
			est.name AS estate_name,
    		COALESCE(wb.weight,0) AS realisasi_berat
		FROM
			weighbridge_ticket wb
			LEFT JOIN weighbridge_ticket_raw raw ON raw.weighbridge_ticket_id = wb.id
  			LEFT JOIN plantation_division div ON div.id = wb.plantation_division_id 
  			LEFT JOIN plantation_estate est ON est.id = div.estate_id 
		WHERE
			wb.transaction_type_id = 86
			AND wb.state = 'valid'
			AND raw.status_delete = '0'
	)
	SELECT
  		ap.tahun,
		ap.bulan,
		ap.estate,
		ap.estate_name,
		SUM(ap.realisasi_berat) AS realisasi_berat
	FROM
		ap
	GROUP BY 
    	ap.tahun, 
		ap.bulan,
		ap.estate,
		ap.estate_name
)
SELECT
  	bp.tahun,
	bp.bulan,
	bp.estate,
	bp.estate_name,
	bp.budget_berat,
	bp.budget_janjang,
	bp.bjr
FROM
	bp
ORDER BY
  	bp.tahun,
	bp.bulan,
	bp.estate
;
