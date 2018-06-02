class ReportsController < ApplicationController
  authorize_resource class: false

  before_action :rosstat_init, only: [:rosstat, :rosstat_additional]

  layout 'simple', only: [:rosstat, :rosstat_additional]

  def index; end

  def rep_form
    @name = params[:name]
  end

  def gkpz_explanation
    @param_report = ParamReport.new(params[:param_report], current_user)
    @report = RepGkpzExplanation.new(@param_report)
    @total = @report.total
    @gkpz_by_type = @report.by_type
    @high = @report.high
    respond_to do |format|
      format.xlsx do
        render_xlsx "reports/gkpz_explanation/main", "gkpz_explanation"
      end
      format.html do
        render "reports/gkpz_explanation/main",
               disposition: "attachment",
               content_type: "application/msword",
               layout: false,
               filename: "gkpz_explanation_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.docx"
      end
    end
  end

  def total_explanation
    respond_to do |format|
      format.xlsx do
        @param_report = ParamReport.new(params[:param_report], current_user)
        render_xlsx "reports/total_explanation/main", "total_explanation"
      end
    end
  end

  def kpi
    respond_to do |format|
      format.xlsx do
        @param_report = ParamReport.new(params[:param_report], current_user)
        render_xlsx "reports/kpi/main", "kpi"
      end
    end
  end

  def lots_by_winer_flat
    respond_to do |format|
      format.xlsx do
        @param_report = ParamReport.new(params[:param_report], current_user)
        render_xlsx "reports/lots_by_winer_flat/main", "lots_by_winer_flat"
      end
    end
  end

  def oos
    respond_to do |format|
      format.xlsx do
        @param_report = ParamReport.new(params[:param_report], current_user)
        render_xlsx "reports/oos/main", "oos"
      end
    end
  end

  def rosstat
    @report.bind_sql_lines = {}

    @captions = YAML.load(File.new('app/views/reports/rosstat/part1_captions.yml').read)
    b = binding

    @captions.each do |cap|
      cap['lines'].each_key do |key|
        @report.bind_sql_lines["l#{key}".to_sym] = ERB.new(File.new("#{@folder}/line#{key}.sql.erb").read).result(b)
      end
    end

    request.format = params[:param_report][:format]

    respond_to do |format|
      format.html { render "reports/rosstat/main" }
      format.xlsx { render_xlsx "reports/rosstat/main", "rosstat" }
    end
  end

  def rosstat_additional
    @col = params[:col].to_i
    @line = params[:line].to_i
    @for_additional = true
    sql = ERB.new(File.new("#{@folder}/line#{@line}.sql.erb").read).result(binding)
    @rows = @report.select_rows(sql)

    render "reports/rosstat/additional"
  end

  def competition
    @param_report = ParamReport.new(params[:param_report], current_user)
    @report = RepCompetition.new(@param_report)
    @folder = 'app/views/reports/competition/sql_rows'

    respond_to do |format|
      format.xlsx { render_xlsx "reports/competition/main", "competition" }
    end
  end

  def marina_30_10_2015
    @deps = [
      #2,         # РАО ЭС Востока
      4,         # ДГК
      1000007,   # ЛУР
      6,         # ДЭК
      5,         # ДРСК
      9,         # Камчатскэнерго
      8,         # Магаданэнерго
      1000011,   # Передвижная энергетика
      3,         # Сахалинэнерго
      7,         # Якутскэнерго
      906000,    # Южные ЭС Камчатки
      701000,    # Сахаэнерго
      702000,    # Теплоэнергосервис
      801000,    # Чукотэнерго
      1000019,   # Благовещенская ТЭЦ
      1000020,   # Сахалинская ГРЭС-2
      1000021,   # ТЭЦ в г. Советская Гавань
      1000022   # Якутская ГРЭС-2
    ]

    @select_cnt = 'select count(pl.id)'
    @select_sum = 'select sum(ps.cost_nds)'
    @from_sum = <<-SQL
      from
        (SELECT tpl.*, row_number() OVER (
        PARTITION BY tpl.guid ORDER BY tp.date_confirm DESC) AS ag_rn
        FROM plan_lots tpl
        INNER JOIN protocols tp ON tp.id = tpl.protocol_id
        WHERE tpl.status_id IN (15006)) pl
      left join (
        select
        tps.plan_lot_id, sum(tps.cost_nds) as cost_nds
        from plan_specifications tps
        group by tps.plan_lot_id
      ) ps on ps.plan_lot_id = pl.id
      left join dictionaries dir on dir.ref_id = pl.main_direction_id
      where pl.ag_rn = 1
      and pl.gkpz_year = 2016
      and pl.department_id = 2
      --and pl.announce_date <= to_date('30.06.2015', 'dd.mm.yyyy')
      and pl.root_customer_id in (%{customers})
    SQL
    @porog_price = <<-SQL
      and (
        (porog.min_price * 1000000 <= ps.cost_nds or porog.min_price is null)
        AND
        (ps.cost_nds < porog.max_price * 1000000 or porog.max_price is null)
      )
    SQL

    @from_porog = <<-SQL
      from
       (select null as min_price, 10 as max_price from dual union all
        select   10,   20 from dual union all
        select   20,   30 from dual union all
        select   30,   40 from dual union all
        select   40,   50 from dual union all
        select   50,   60 from dual union all
        select   60,   70 from dual union all
        select   70,   80 from dual union all
        select   80,   90 from dual union all
        select   90,  100 from dual union all
        select  100,  150 from dual union all
        select  150,  200 from dual union all
        select  200,  250 from dual union all
        select  250,  300 from dual union all
        select  300, null from dual) porog
      order by porog.min_price NULLS FIRST
    SQL

    render_xlsx "reports/temp/marina_30_10_2015/main", "temp"
  end

  private

  def render_xlsx(path_template, name_rep)
    render xlsx: path_template,
           template: path_template,
           disposition: "attachment",
           filename: "#{name_rep}_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
  end

  def rosstat_init
    @param_report = ParamReport.new(params[:param_report], current_user)
    @report = RepRosstat.new(@param_report)
    @folder = 'app/views/reports/rosstat/part1_sql'
  end
end
