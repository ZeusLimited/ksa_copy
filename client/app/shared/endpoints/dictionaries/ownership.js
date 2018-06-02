import { railsRequest } from '../base'

const OwnershipEndpoint = {
  create: (params) => railsRequest({ uri: '/ownerships', params }),
  update: (id, params) => railsRequest({ uri: `/ownerships/${id}`, method: 'put', params }),
  destroy: (id) => railsRequest({ uri: `/ownerships/${id}`, method: 'delete' }),
}

export default OwnershipEndpoint
