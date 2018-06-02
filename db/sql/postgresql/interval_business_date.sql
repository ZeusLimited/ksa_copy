CREATE OR REPLACE FUNCTION interval_business_date(date, int) RETURNS DATE AS
$$
DECLARE v_result date;
BEGIN
  v_result := $1;

  FOR i IN 1..$2 LOOP
    v_result := v_result + 1;
    CASE extract('dow' from v_result)
    WHEN 6 THEN v_result := v_result + 2;
    WHEN 0 THEN v_result := v_result + 1;
    ELSE null;
    END CASE;
  END LOOP;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;