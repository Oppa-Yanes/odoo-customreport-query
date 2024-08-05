SELECT * FROM weighbridge_ticket 
WHERE ticket_no = 'SA120240704070' OR ticket_no = 'SA120240704008';

SELECT 
	wb.*
FROM
	weighbridge_ticket wb
	LEFT JOIN account_move am ON am.id = wb.vendor_bill_id
	--LEFT JOIN account_move_line aml ON aml.move_id = am.id
WHERE 
	wb.ticket_no = 'SA120240800105';
;

UPDATE
	weighbridge_ticket
SET
	deduction_weight = 202,
	weight = net_weight - deduction_weight,
	state = 'valid',
	invoiced = NULL,
	account_move_tbs_id = NULL,
	vendor_bill_id = NULL
WHERE
	ticket_no = 'SA120240800105'
;
