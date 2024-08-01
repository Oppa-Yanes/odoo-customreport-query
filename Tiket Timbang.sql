SELECT * FROM weighbridge_ticket 
WHERE ticket_no = 'SA120240704070' OR ticket_no = 'SA120240704008';

SELECT * FROM weighbridge_ticket 
WHERE vendor_bill_id IS NULL LIMIT 100;

UPDATE
	weighbridge_ticket
SET
	state = 'valid',
	invoiced = NULL,
	account_move_tbs_id = NULL,
	vendor_bill_id = NULL
WHERE
	ticket_no = 'SA120240704008';

