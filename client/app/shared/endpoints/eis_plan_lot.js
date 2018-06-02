import { railsRequest } from './base'

const EisPlanLotEndpoint = {
  update: (id, params) => railsRequest({ uri: `/eis_plan_lots/${id}`, method: 'PATCH', params }),
}

export default EisPlanLotEndpoint
