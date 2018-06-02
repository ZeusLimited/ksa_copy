create or replace PACKAGE BODY pcg_gkpz
AS
  -- Статусы лотов в ГКПЗ
  STATUS_NEW CONSTANT NUMBER := 15001;
  STATUS_UNDER_CONSIDERATION CONSTANT NUMBER := 15002;
  STATUS_CONSIDERED CONSTANT NUMBER := 15008;
  STATUS_AGREEMENT CONSTANT NUMBER := 15003;
  STATUS_CANCELLED CONSTANT NUMBER := 15004;
  STATUS_PRE_CONFIRM_SD CONSTANT NUMBER := 15005;
  STATUS_CONFIRM_SD CONSTANT NUMBER := 15006;

  PROCEDURE Change_Status (current_user in number, status_next in NUMBER) IS
    v_count NUMBER(38);
    sql_str VARCHAR2(1000);
    BEGIN
      -- Проверяем на наличие "посторонних" статусов в выбранных лотах.
      sql_str := 'select count(*)
      from plan_lots pl
      inner join users_plan_lots upl on (pl.id = upl.plan_lot_id)
      where upl.user_id = :current_user';

      IF status_next = STATUS_NEW THEN
        sql_str := sql_str || ' and pl.status_id not in (' || STATUS_UNDER_CONSIDERATION || ',' || STATUS_CONSIDERED || ')';
      ELSIF status_next = STATUS_UNDER_CONSIDERATION THEN
        sql_str := sql_str || ' and pl.status_id not in (' || STATUS_NEW || ',' || STATUS_AGREEMENT || ',' || STATUS_CONFIRM_SD || ')';
      ELSIF status_next = STATUS_CONSIDERED THEN
        sql_str := sql_str || ' and pl.status_id != ' || STATUS_UNDER_CONSIDERATION;
      ELSIF status_next = STATUS_PRE_CONFIRM_SD THEN
        sql_str := sql_str || ' and pl.status_id not in (' || STATUS_AGREEMENT || ',' || STATUS_CONFIRM_SD || ',' || STATUS_CANCELLED || ')';
      END IF;

      EXECUTE IMMEDIATE sql_str INTO v_count USING current_user;

      IF (v_count = 0) THEN

        -- Проводим тотальную переиндексацию
        UPDATE plan_lots
        SET version = version + 1
        WHERE guid in
              (SELECT guid FROM plan_lots WHERE id in (SELECT plan_lot_id FROM users_plan_lots WHERE user_id = current_user));

        -- Клонируем лоты
        INSERT INTO plan_lots (id, guid, version, gkpz_year, num_tender, num_lot, lot_name, department_id,
                               tender_type_id, tender_type_explanations, subject_type_id, etp_address_id,
                               announce_date, explanations_doc, point_clause, protocol_id, status_id, commission_id,
                               user_id, root_customer_id, additional_to, additional_num, sme_type_id, state, main_direction_id,
                               order1352_id, preselection_guid, regulation_item_id, created_at, updated_at)
        SELECT plan_lots_seq.nextval, guid, 0, gkpz_year, num_tender, num_lot, lot_name, department_id,
               tender_type_id, tender_type_explanations, subject_type_id, etp_address_id,
               announce_date, explanations_doc, point_clause, NULL, status_next, commission_id,
               current_user, root_customer_id, additional_to, additional_num, sme_type_id, state, main_direction_id,
               order1352_id, preselection_guid, regulation_item_id,
               cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        FROM plan_lots
        WHERE id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем контрагентов
        INSERT INTO plan_lot_contractors(id,plan_lot_id,contractor_id)
        SELECT plan_lot_contractors_seq.nextval,
          (select id from plan_lots l where l.version = 0 and l.guid = pl.guid), plc.contractor_id
        FROM plan_lot_contractors plc
        INNER JOIN plan_lots pl on (pl.id = plc.plan_lot_id)
        WHERE pl.id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем лимиты ПО
        INSERT INTO plan_annual_limits(id, plan_lot_id, year, cost, cost_nds, created_at, updated_at)
        SELECT plan_annual_limits_seq.nextval,
          (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
          pal.year, pal.cost, pal.cost_nds,
          cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        FROM plan_annual_limits pal
        INNER JOIN plan_lots pl on (pl.id = pal.plan_lot_id)
        WHERE pl.id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем файлы, привязанные к лоту
        INSERT INTO plan_lots_files (id, plan_lot_id, tender_file_id, note, file_type_id)
          SELECT plan_lots_files_seq.nextval, (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
                 tender_file_id, note, file_type_id
          FROM plan_lots_files plf
          INNER JOIN plan_lots pl on (plf.plan_lot_id = pl.id)
          WHERE plf.plan_lot_id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем спецификации
        INSERT INTO plan_specifications (id, plan_lot_id, guid, num_spec, name, qty, cost, cost_nds, cost_doc, unit_id,
                                         okdp_id, okved_id, direction_id, product_type_id, financing_id, customer_id,
                                         consumer_id, monitor_service_id, invest_project_id, delivery_date_begin,
                                         delivery_date_end, bp_item, requirements,
                                         potential_participants, bp_state_id, curator, tech_curator, note,
                                         created_at, updated_at)
        SELECT plan_specifications_seq.nextval, (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
                spec.guid, spec.num_spec, spec.name, spec.qty, spec.cost, spec.cost_nds, spec.cost_doc, spec.unit_id,
                spec.okdp_id, spec.okved_id, spec.direction_id, spec.product_type_id, spec.financing_id,
                spec.customer_id, spec.consumer_id, spec.monitor_service_id, spec.invest_project_id,
                spec.delivery_date_begin, spec.delivery_date_end, spec.bp_item, spec.requirements,
                spec.potential_participants, spec.bp_state_id, spec.curator, spec.tech_curator, spec.note,
                cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        From plan_specifications spec
        INNER JOIN plan_lots pl on (spec.plan_lot_id = pl.id)
        WHERE spec.plan_lot_id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем суммы освоения
        INSERT INTO plan_spec_amounts (id, plan_specification_id, year, amount_mastery, amount_mastery_nds,
                                       amount_finance, amount_finance_nds)
          SELECT plan_spec_amounts_seq.nextval,
            (select max(id) from plan_specifications s where s.guid = ps.guid group by guid),
            year, amount_mastery, amount_mastery_nds, amount_finance, amount_finance_nds
          FROM plan_spec_amounts psa
          INNER JOIN plan_specifications ps on (psa.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем адреса поставки
        INSERT INTO fias_plan_specifications (id, houseid, plan_specification_id, addr_aoid, fias_id)
          SELECT fias_plan_specifications_seq.nextval, houseid,
            (select max(id) from plan_specifications s where s.guid = ps.guid group by s.guid), addr_aoid, fias_id
          FROM fias_plan_specifications fsa
          INNER JOIN plan_specifications ps on (fsa.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем производственные подразделения
        INSERT INTO plan_spec_production_units(plan_specification_id, department_id)
          SELECT
            (select max(id) from plan_specifications s where s.guid = ps.guid group by guid),
            department_id
          FROM plan_spec_production_units pspu
          INNER JOIN plan_specifications ps on (pspu.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        COMMIT;

        -- Добавляем в выбранные все склонированые лоты
        INSERT INTO users_plan_lots(user_id, plan_lot_id)
        SELECT current_user, id
        FROM plan_lots l
        WHERE l.guid in
              (SELECT guid
               FROM plan_lots pl
               INNER JOIN users_plan_lots upl ON (pl.id = upl.plan_lot_id)
               WHERE upl.user_id = current_user)
              AND l.version = 0;

        -- Удаляем из списка выбраных лоты с которых клонировали
        DELETE FROM users_plan_lots
        WHERE plan_lot_id in
              (SELECT id
               FROM plan_lots l
               WHERE l.guid in
                     (SELECT guid
                      FROM plan_lots pl
                      INNER JOIN users_plan_lots upl ON (pl.id = upl.plan_lot_id)
                      WHERE upl.user_id = current_user)
                     AND l.version != 0);
        COMMIT;
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'В списке выбранных существуют лоты с инвалидным статусом');
      END IF;
    END; -- Change_Status

  PROCEDURE bind_lots_to_protocol(bind_protocol_id in number) IS
    current_user number;
    BEGIN

        SELECT user_id INTO current_user FROM protocol_plan_lots_tmp WHERE ROWNUM = 1;

        -- Проводим тотальную переиндексацию
        UPDATE plan_lots
        SET version = version + 1
        WHERE guid in
              (SELECT guid FROM plan_lots WHERE id in (SELECT plan_lot_id FROM protocol_plan_lots_tmp));

        -- Клонируем лоты
        INSERT INTO plan_lots (id, guid, version, gkpz_year, num_tender, num_lot, lot_name, department_id,
                               tender_type_id, tender_type_explanations, subject_type_id, etp_address_id,
                               announce_date, explanations_doc, point_clause, protocol_id, status_id, commission_id,
                               user_id, root_customer_id, additional_to, additional_num, sme_type_id, state, main_direction_id,
                               order1352_id, preselection_guid, regulation_item_id, created_at, updated_at)
        SELECT plan_lots_seq.nextval, guid, 0, gkpz_year, num_tender, num_lot, lot_name, department_id,
               tender_type_id, tender_type_explanations, subject_type_id, etp_address_id,
               announce_date, explanations_doc, point_clause, bind_protocol_id, t.status_id, commission_id,
               t.user_id, root_customer_id, additional_to, additional_num, sme_type_id, t.is_plan, main_direction_id,
               order1352_id, preselection_guid, regulation_item_id,
               cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        FROM plan_lots l
        inner join protocol_plan_lots_tmp t on (l.id = t.plan_lot_id);

        -- Клонируем контрагентов
        INSERT INTO plan_lot_contractors(id,plan_lot_id,contractor_id)
        SELECT plan_lot_contractors_seq.nextval,
          (select id from plan_lots l where l.version = 0 and l.guid = pl.guid), plc.contractor_id
        FROM plan_lot_contractors plc
        INNER JOIN plan_lots pl on (pl.id = plc.plan_lot_id)
        WHERE pl.id in (select plan_lot_id from protocol_plan_lots_tmp);

        -- Клонируем лимиты ПО
        INSERT INTO plan_annual_limits(id, plan_lot_id, year, cost, cost_nds, created_at, updated_at)
        SELECT plan_annual_limits_seq.nextval,
          (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
          pal.year, pal.cost, pal.cost_nds,
          cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        FROM plan_annual_limits pal
        INNER JOIN plan_lots pl on (pl.id = pal.plan_lot_id)
        WHERE pl.id in (select plan_lot_id from users_plan_lots where user_id = current_user);

        -- Клонируем файлы, привязанные к лоту
        INSERT INTO plan_lots_files (id, plan_lot_id, tender_file_id, note, file_type_id)
          SELECT plan_lots_files_seq.nextval, (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
                 tender_file_id, note, file_type_id
          FROM plan_lots_files plf
          INNER JOIN plan_lots pl on (plf.plan_lot_id = pl.id)
          WHERE plf.plan_lot_id in (select plan_lot_id from protocol_plan_lots_tmp);

        -- Клонируем спецификации
        INSERT INTO plan_specifications (id, plan_lot_id, guid, num_spec, name, qty, cost, cost_nds, cost_doc, unit_id,
                                         okdp_id, okved_id, direction_id, product_type_id, financing_id, customer_id,
                                         consumer_id, monitor_service_id, invest_project_id, delivery_date_begin,
                                         delivery_date_end, bp_item, requirements,
                                         potential_participants, bp_state_id, curator, tech_curator, note,
                                         created_at, updated_at)
        SELECT plan_specifications_seq.nextval, (select id from plan_lots l where l.version = 0 and l.guid = pl.guid),
                spec.guid, spec.num_spec, spec.name, spec.qty, spec.cost, spec.cost_nds, spec.cost_doc, spec.unit_id,
                spec.okdp_id, spec.okved_id, spec.direction_id, spec.product_type_id, spec.financing_id,
                spec.customer_id, spec.consumer_id, spec.monitor_service_id, spec.invest_project_id,
                spec.delivery_date_begin, spec.delivery_date_end, spec.bp_item, spec.requirements,
                spec.potential_participants, spec.bp_state_id, spec.curator, spec.tech_curator, spec.note,
                cast(systimestamp at time zone 'GMT' as date), cast(systimestamp at time zone 'GMT' as date)
        From plan_specifications spec
        INNER JOIN plan_lots pl on (spec.plan_lot_id = pl.id)
        WHERE spec.plan_lot_id in (select plan_lot_id from protocol_plan_lots_tmp);

        -- Клонируем суммы освоения
        INSERT INTO plan_spec_amounts (id, plan_specification_id, year, amount_mastery, amount_mastery_nds,
                                       amount_finance, amount_finance_nds)
          SELECT plan_spec_amounts_seq.nextval,
            (select max(id) from plan_specifications s where s.guid = ps.guid group by guid),
            year, amount_mastery, amount_mastery_nds, amount_finance, amount_finance_nds
          FROM plan_spec_amounts psa
          INNER JOIN plan_specifications ps on (psa.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from protocol_plan_lots_tmp);

        -- Клонируем адреса поставки
        INSERT INTO fias_plan_specifications (id, houseid, plan_specification_id, addr_aoid, fias_id)
          SELECT fias_plan_specifications_seq.nextval, houseid,
            (select max(id) from plan_specifications s where s.guid = ps.guid group by s.guid), addr_aoid, fias_id
          FROM fias_plan_specifications fsa
          INNER JOIN plan_specifications ps on (fsa.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from protocol_plan_lots_tmp);

        -- Клонируем производственные подразделения
        INSERT INTO plan_spec_production_units(plan_specification_id, department_id)
          SELECT
            (select max(id) from plan_specifications s where s.guid = ps.guid group by guid),
            department_id
          FROM plan_spec_production_units pspu
          INNER JOIN plan_specifications ps on (pspu.plan_specification_id = ps.id)
          WHERE ps.plan_lot_id in (select plan_lot_id from protocol_plan_lots_tmp);

         -- Удаляем из списка выбраных лоты с которых клонировали
       DELETE FROM users_plan_lots where user_id = current_user;

        -- Добавляем в выбранные все склонированые лоты
        INSERT INTO users_plan_lots(user_id, plan_lot_id)
        SELECT current_user, id
        FROM plan_lots l
        WHERE l.guid in
              (SELECT guid
               FROM plan_lots pl
               INNER JOIN protocol_plan_lots_tmp t ON (pl.id = t.plan_lot_id)
               )
              AND l.version = 0;
    END;
END;
