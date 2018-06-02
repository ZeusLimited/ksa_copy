CREATE OR REPLACE FUNCTION interval_business_date (begin_date in date, interval in number) return date IS
  v_result date;
BEGIN

  v_result := begin_date;

  FOR i IN 1..interval LOOP
    v_result := v_result + 1;
    IF TO_CHAR(v_result, 'D') = 6 THEN
      v_result := v_result + 2;
    ELSIF TO_CHAR(v_result, 'D') = 7 THEN
      v_result := v_result + 1;
    END IF;
  END LOOP;

  RETURN v_result;
END;
