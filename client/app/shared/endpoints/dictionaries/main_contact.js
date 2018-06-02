import { railsRequest } from '../base'

const MainContactEndpoint = {
  destroy: (id) => railsRequest({ uri: `/main_contacts/${id}`, method: 'delete' }),
}

export default MainContactEndpoint
