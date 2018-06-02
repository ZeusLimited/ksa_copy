import ReactOnRails from 'react-on-rails'

// components
import DictionaryOwnerships from 'bundles/ownerships/components'
import TenderExperts from 'bundles/tender_experts/components'
import MainContacts from 'bundles/main_contacts/components'
import EisNumModalForm from 'bundles/plan_lots/components'
// stores
import SharedReduxStore from 'stores/store'

ReactOnRails.register({
  DictionaryOwnerships,
  TenderExperts,
  MainContacts,
  EisNumModalForm,
})

ReactOnRails.registerStore({
  SharedReduxStore,
})
