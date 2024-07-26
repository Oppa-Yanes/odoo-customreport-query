SELECT
        ba.id,
	ba.name,
	ba.tanggal_ba,
	ba.tanggal_import,
	ba.state,
	ba.technical_code,
	--ba.department_id,
	dept.complete_name dept_name,
	ba.create_date,
	--ba.create_uid,
	regexp_replace(ru.login, '@.*$', '') create_by,
	--bal.employee_id,
	emp.nomor_induk_pegawai nip,
	emp.name emp_name,
	--bal.attendance_type_fp_id,
	attfp.code fp_type,
	--bal.attendance_type_ba_id,
	attba.code ba_type01,
	bal.attendance_type_ba_code ba_type02,
	TO_CHAR((bal.time_in * INTERVAL '1 hour')::interval, 'HH24:MI') time_in,
	TO_CHAR((bal.time_out * INTERVAL '1 hour')::interval, 'HH24:MI') time_out,
	TO_CHAR((fp.time_in * INTERVAL '1 hour')::interval, 'HH24:MI') fp_time_in,
	TO_CHAR((fp.time_out * INTERVAL '1 hour')::interval, 'HH24:MI') fp_time_out
FROM
	berita_acara_line bal
	LEFT JOIN berita_acara ba ON ba.id = bal.berita_acara_id
	LEFT JOIN hr_department dept ON dept.id = ba.department_id
	LEFT JOIN res_users ru ON ru.id = ba.write_uid
	LEFT JOIN hr_employee emp ON emp.id = bal.employee_id
	LEFT JOIN hr_attendance_type attfp ON attfp.id = bal.attendance_type_fp_id
	LEFT JOIN hr_attendance_type attba ON attba.id = bal.attendance_type_ba_id
	LEFT JOIN hr_import_attendance_line fp ON fp.employee_id = bal.employee_id AND fp.date_in = ba.tanggal_ba
WHERE
	ba.tanggal_ba = '2024-07-19'
ORDER BY
	ba.tanggal_ba,
	emp.name
;
