SELECT * FROM uom_uom WHERE name = 'L';
SELECT * FROM product_template WHERE name = 'VAYEGO 200 SC';
SELECT * FROM product_product WHERE product_tmpl_id = 224;


UPDATE product_template SET uom_id = 11, uom_po_id =11 WHERE id = 224;
-- product_product SET uom_id = 11 WHERE id = <product_product_id>;
UPDATE stock_move SET product_uom = 11 WHERE product_id = 224;
UPDATE stock_move_line SET product_uom_id = 11 WHERE product_id = 224;
UPDATE purchase_order_line SET product_uom = 11 WHERE product_id = 224;
UPDATE sale_order_line SET product_uom = 11 WHERE product_id = 224;
UPDATE stock_inventory_line SET product_uom_id = 11 WHERE product_id = 224;

