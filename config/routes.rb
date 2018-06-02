require 'sidekiq/web'

Rails.application.routes.draw do
  unless Rails.env.development?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.variable_size_secure_compare(username, 'sidekiq') &
        ActiveSupport::SecurityUtils.variable_size_secure_compare(password, 'Constantine')
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'

  resources :registration_companies, only: %i[new create]

  resources :orders
  resources :okdp_sme_etps
  def report(name, get_methods = [:options, :show])
    get_methods.each do |get_method|
      if get_method == :show
        get "#{name}/#{get_method}", defaults: { format: 'xlsx' }
      else
        get "#{name}/#{get_method}"
      end
    end
  end

  namespace :reports do
    namespace :gkpz do
      report 'gkpz'
      report 'gkpz_niokr'
      report 'gkpz_oos'
      report 'explanation_single_source'
      report 'checklist'
      report 'gkpz_explanation'
      report 'plan_oos_etp'
      report 'gkpz_oos_new'
      report 'plan_eis_inivp'
      report 'gkpz_oos_common'
    end
    namespace :reglament do
      report 'current_result'
      report 'total_explanation'
      report 'invest_result'
      report 'intermediate_form'
      report 'high_tech_result'
      report 'tender_types_result'
      report 'sme_table'
      report 'mounthly_analysis', [:options, :show, :detail]
      report 'consolidated_analysis'
      report 'invest_session'
      report 'presentation_tables'
      report 'hundred_millions_tenders'
    end
    namespace :minenergo do
      report 'arm51632'
      report 'arm51633'
      report 'arm51635'
    end
    namespace :pui do
      report 'current_operation'
      report 'effect_operation'
    end
    namespace :other do
      report 'overdue_contract'
      report 'template_generation'
      report 'rosstat', [:options, :show, :detail]
      report 'eis_tenders_result', [:options, :show]
      report 'summary_result'
      report 'execute_gkpz', [:options, :show, :detail]
      report 'execute_gkpz_imp', [:options, :show, :detail]
      report 'tenders_result', [:options, :show]
      report 'start_form'
      report 'expected_economic_effect'
      report 'tender_bidders'
      report 'plan_starts'
      report 'purchase_from_sme', [:options, :show, :detail]
      report 'vostek_tenders'
      report 'lot_by_winer'
      report 'inovation_product', [:options, :show, :detail]
      report 'inovation_product_amount', [:options, :show, :detail]
      report 'lot_by_winner_flat'
      report 'success_story', [:options, :show, :detail]
      report 'agents_commission'
      report 'tenders_efficiency'
      report 'tenders_efficiency_v2'
      report 'execute_plan', [:options, :show]
      report 'economic_result', [:options, :show]
      report 'terms_violation'
    end
  end

  namespace :account do
    resource :profile, controller: :profile, only: [:show, :edit, :update] do
      member do
        get :from_ldap
        patch :update_photo
        get :edit_password
        patch :update_password
      end
    end
    resource :settings, controller: :settings, only: [:show, :edit, :update, :create]
    resources :subscribes, only: :index do
      collection do
        get 'new_list'
        post 'create_list'
        get 'edit_list'
        post 'update_list'
        delete 'delete_list'
        post 'push_to_session'
        post 'pop_from_session'
      end
    end
    resources :subscribe_notifications, only: :index do
      post :send_now, on: :collection
    end
  end

  post 'control_plan_lots/create_list', to: 'control_plan_lots#create_list', as: :create_list_control_plan_lots
  delete 'control_plan_lots/delete_list', to: 'control_plan_lots#delete_list', as: :delete_list_control_plan_lots

  resources :histories, only: :index
  resources :cart_lots, only: [:index, :create, :destroy] do
    delete 'clear', on: :collection
  end

  get 'import_plan_lots/example', to: 'import_plan_lots#example', as: :import_plan_lots_example

  resources :tender_type_rules, only: [:index] do
    get 'edit_all', on: :collection
    patch 'update_all', on: :collection
  end

  resources :user_plan_lots, only: [:index] do
    collection do
      post "select_list"
      post "unselect_list"
      post "unselect_all"
    end
  end

  concern :declensionable do
    resource :declension, only: [:create, :edit, :update]
  end

  resources :content_offers

  get 'docs', to: 'docs#index', as: :docs
  get 'docs/structure', to: 'docs#structure', as: :structure_docs
  get 'reports', to: 'reports#index', as: :reports

  resources :contractors do
    collection do
      get 'search'
      get 'search_potential_bidders'
      get 'search_bidders'
      get 'search_parents'
      get 'search_reports'
      get 'info'
      get 'info_from_1c'
      get 'find_by_inn'
    end
    patch 'change_status', on: :member
    get 'tenders', on: :member
    resource :rename, controller: :contractors_rename, only: [:new, :create]
    resources :documents, controller: :contractor_documents, only: [:index] do
      collection do
        get 'edit_all'
        patch 'update_all'
      end
    end
  end

  resources :contacts

  resources :unregulated, only: [:new, :create, :edit, :update]

  resources :tenders do
    member do
      get 'copy'
      get "show_bidder_requirements"
      get "edit_bidder_requirements"
      patch "update_bidder_requirements"
      get "show_offer_requirements"
      get "edit_offer_requirements"
      patch "update_offer_requirements"
      patch "public"
      patch "add_zzc"
      get 'contracts'
      get 'show_standard_form', defaults: { format: :docx }
    end
    collection do
      get 'export_excel'
      get "new_from_copy"
      post "create_from_copy"
      get "new_from_frame"
      post "create_from_frame"
      get 'search_b2b_classifiers'
      get 'get_b2b_classifier'
    end

    resource :tender_data_map, only: [:show, :edit, :update]

    resources :tender_documents, only: [:index] do
      collection do
        get 'edit_all'
        patch 'update_all'
      end
    end

    resources :lots do
      get 'frame_info', on: :member
    end

    resources :experts, only: [:index] do
      collection do
        get 'edits'
        patch 'updates'
      end
    end
    resources :expert_opinions, only: [:index] do
      member do
        get 'edit_draft'
        get 'show_draft'
        post 'update_draft'
      end
    end
    resources :rebid_protocols do
      get 'reference', on: :member
      post 'present_members', on: :collection
    end
    resources :review_protocols do
      member do
        patch 'pre_confirm'
        patch 'confirm'
        patch 'revoke_confirm'
        patch 'cancel_confirm'
        patch 'update_confirm_date'
      end
    end
    resources :winner_protocols do
      member do
        patch 'pre_confirm'
        patch 'confirm'
        patch 'revoke_confirm'
        patch 'cancel_confirm'
        patch 'sign'
        patch 'revoke_sign'
        patch 'update_confirm_date'
      end
    end

    resources :result_protocols do
      member do
        patch 'sign'
        patch 'revoke_sign'
      end
    end
    resources :doc_takers, only: [:create, :destroy, :index]
    resources :tender_requests
    resources :bidders do
      resources :offers do
        collection do
          get 'control'
          post 'add'
          post 'pickup'
        end
      end
      collection do
        get 'map_by_lot'
        get 'map_pivot'
      end
      member do
        get 'all_files_as_one'
        get 'file_exists'
      end
    end
    resources :covers
    resources :open_protocols, except: [:index] do
      get 'reference', on: :member
      post 'present_members', on: :collection
    end
  end

  resources :offers, only: [] do
    resource :contract_expired, only: [:edit, :update]
    resource :contract do
      collection do
        get 'additional_search'
        get 'additional_info'
      end
    end
  end

  resources :contracts, only: [] do
    resource :contract_termination, except: [:index]
    resources :sub_contractors
    resources :contract_reductions
  end

  resources :criterions
  resources :pages

  resources :tasks do
    collection do
      get 'change_priority'
      post 'sort'
    end
  end

  resources :invest_projects do
    collection do
      post 'filter_rows_for_select'
      get 'filter_invest_names'
    end
  end

  %i[okdp okveds].each do |ns|
    namespace ns do
      %w[index show nodes_for_filter nodes_for_parent].each do |action|
        get action, action: action
      end
    end
  end
  get 'okdp/reform_old_value', to: 'okdp#reform_old_value', as: 'okdp_reform_old_value'

  resources :units do
    get 'search', on: :collection
  end

  resources :eis_plan_lots, only: :update

  resources :plan_lots do
    member do
      get 'edit_without_history'
      get 'preselection_info'
      patch 'update_without_history'
      delete 'destroy_version'
    end
    collection do
      get 'export_excel'
      get 'export_excel_lot'
      get 'preselection_search'
      get 'additional_search'
      get 'additional_info'
      get 'search_edit_list'
      get 'search_all'
      get 'edit_plan_specifications'
      get 'copy_plan_specifications'
      get 'reset'
      get 'import_excel'
      post 'import'
      get 'import_lots'
      post 'upload_excel'
      post 'next_free_number'
      patch 'submit_approval'
      patch 'return_for_revision'
      patch 'destroy_current_version_user'
      patch 'agree'
      patch 'pre_confirm_sd'
      patch 'cancel_pre_confirm_sd'
      get 'reform_okveds'
      delete 'destroy_all'
    end
  end

  get '/plan_lot_history/:guid', to: 'plan_lots#history_lot', as: 'history_plan_lot'
  get '/plan_lot_history_full/:guid', to: 'plan_lots#history_lot_full', as: 'history_full_plan_lot'
  get '/plan_spec_history/:guid', to: 'plan_lots#history_spec', as: 'history_plan_spec'

  get 'plan_lot_non_executions/:guid', to: 'plan_lot_non_executions#index', as: 'plan_lot_non_execution'
  post 'plan_lot_non_executions/:guid', to: 'plan_lot_non_executions#create', as: 'create_plan_lot_non_execution'

  resources :fias, only: [:show, :create]

  resources :protocol_users

  resources :commission_users
  resources :commissions do
    concerns :declensionable
    get 'for_organizer', on: :collection
  end
  resources :local_time_zones, concerns: :declensionable

  resources :tender_files, only: [:create, :index]
  resources :page_files, only: [:create, :destroy]

  devise_for :users,
             path_names: { sign_in: "login", sign_out: "logout" },
             controllers: { registrations: "registrations" }

  resources :user, controller: "user", except: [:new, :create] do
    get 'search', on: :collection
    get 'info', on: :collection
  end

  resources :protocols do
    get 'merge_new', on: :collection
    post 'merge_create', on: :collection
  end

  resources :department_nodes, only: [:new, :create, :edit, :update]

  resources :departments, except: [:destroy] do
    get 'search', on: :collection
    get 'nodes_for_index', on: :collection
    get 'nodes_for_filter', on: :collection
    get 'nodes_for_parent', on: :collection
    get 'new_child', on: :collection
    get 'edit_child', on: :member
  end

  resources :dictionaries do
    concerns :declensionable
    collection do
      get 'reduction'
    end
    get 'order1352_reg_item', on: :collection
  end

  resources :regulation_items, except: [:show] do
    get 'for_type', on: :collection
  end

  resources :main_contacts do
    post 'sort', on: :collection
  end

  resources :units

  resources :unit_subtitles

  resources :unit_titles

  resources :valid_tender_dates
  resources :tender_dates_for_types

  resources :directions do
    post 'sort', on: :collection
  end
  resources :ownerships
  resources :monitor_services
  resources :effeciency_indicators, except: [:show]

  resources :plan_innovations, only: [:show, :edit, :new, :update, :create]
  resources :unfair_contractors do
    get 'lots', on: :collection
    get 'lots_info', on: :collection
    get 'export_excel', on: :collection
  end

  wash_out :web_service

  mount Markitup::Rails::Engine, at: "markitup", as: "markitup"

  root to: 'plan_lots#index'
end
