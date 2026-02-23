--trigger function

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

--trigger definition
create trigger products_audit_trigger
after insert or update or delete on products
for each row
execute function log_product_changes();


--bonus challenge

--trigger function
create or replace function set_last_modified()
returns trigger as $$
begin
    NEW.last_modified = NOW();
    return NEW;
end;
$$ language plpgsql;


--trigger definition
create trigger products_last_modified_trigger
before update on products
for each row
execute function set_last_modified();

--why is before is the correct choice?

--before is the right choice because it modifies NEW.last_modified 
--before the row is saved. In a BEFORE trigger, PostgreSQL 
--applies any changes made to NEW, so the updated timestamp is stored with the row.

--test
UPDATE products
SET price = price + 10
WHERE product_id = 1;



		