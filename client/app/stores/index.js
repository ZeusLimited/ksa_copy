import ReactOnRails from 'react-on-rails'

const SHARED_REDUX_STORE = 'SharedReduxStore'

export default function getStore() {
  const stores = ReactOnRails.stores()
  if (stores.has(SHARED_REDUX_STORE)) return ReactOnRails.getStore(SHARED_REDUX_STORE)
  return null
}
