create or replace function log_product_changes()
returns trigger as $$
begin
    IF TG_OP = 'INSERT' THEN
        INSERT INTO products_audit(product_id,change_type,new_name,new_price)
        VALUES(NEW.product_id, 'INSERT', NEW.name, NEW.price);
	
    return new;

    ELSIF TG_OP = 'DELETE' THEN
	INSERT INTO products_audit(product_id, change_type, old_name, old_price)
	VALUES(OLD.product_id, 'DELETE', OLD.name, OLD.price);

    return old;

    ELSIF TG_OP = 'UPDATE' THEN
	IF NEW.name IS DISTINCT FROM OLD.name OR
	NEW.price IS DISTINCT FROM OLD.price THEN
	    INSERT INTO products_audit(product_id, change_type, old_name, new_name, old_price, 	   	    new_price)
	    VALUES(OLD.product_id, 'UPDATE', OLD.name, NEW.name, OLD.price, NEW.price);
	END IF;
    	return NEW;
    END IF;
    return null;
end;
$$ language plpgsql;


		