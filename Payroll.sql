-- CEK ATTENDANCE YANG KOSONG
SELECT
	a.id,
	a.attendance_type_id,
	c.name
FROM
	plantation_timesheet a
	LEFT JOIN hr_work_entry_type b ON b.id = a.attendance_type_id
	LEFT JOIN plantation_daily_activity c ON c.id = a.daily_activity_id
WHERE
	a.attendance_type_id IS NULL
;

-- CEK BKM
SELECT
	emp.nomor_induk_pegawai nip,
	emp.name emp_name,	
	c.*
FROM
	plantation_daily_activity a
	--LEFT JOIN plantation_daily_activity_employee b ON b.bkm_id = a.id
	LEFT JOIN plantation_timesheet c ON c.daily_activity_id = a.id
	LEFT JOIN hr_employee emp ON emp.id = c.employee_id
WHERE
	a.name = 'BKMP/24/07/21446'
ORDER BY
	emp.name
;
