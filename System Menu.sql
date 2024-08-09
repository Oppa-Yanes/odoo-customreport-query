SELECT
	mn1.id, 
	mn1.name, 
	mn1.parent_id, 
	mn1.sequence,
	mn2.name parent_name
FROM
	ir_ui_menu mn1
	LEFT JOIN ir_ui_menu mn2 ON mn2.parent_id = mn1.id 
WHERE
	mn1.active
	--AND LOWER(mn1.name) = 'plantation'
ORDER BY
	mn1.parent_id NULLS FIRST,
	mn1.sequence,
	mn1.name,
	mn2.sequence
;
