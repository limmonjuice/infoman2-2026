-- Activity 1
CREATE OR REPLACE FUNCTION public.get_flight_duration(p_flight_id integer)
RETURNS INTERVAL AS $$
DECLARE
    v_flight_duration INTERVAL;
BEGIN
    SELECT arrival_time - departure_time
    INTO v_flight_duration
    FROM flights
    WHERE flight_id = p_flight_id;

    RETURN v_flight_duration;
END;
$$ LANGUAGE plpgsql;


-- Activity 2
CREATE OR REPLACE FUNCTION get_price_category(p_flight_id integer)
RETURNS TEXT AS $$
DECLARE
        v_price NUMERIC;
BEGIN
        SELECT base_price
        INTO v_price
        FROM flights
        WHERE flight_id = p_flight_id;

        IF v_price < 300.00 THEN
                RETURN 'Budget';
        ELSIF v_price >= 300 AND v_price <= 800 THEN
                RETURN 'Standard';
        ELSE
                RETURN 'Premium';
        END IF;
END;
$$ LANGUAGE plpgsql;