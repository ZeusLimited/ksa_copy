import { normalizeEntities } from './normalize'
import { initialStates } from './reducer'
import get from 'lodash/get'

export default (props) => {
  const { entities, result } = normalizeEntities(props)
  // console.log(props);

  return {
    ...initialStates,
    // user: result.user,
    entities: {
      ...initialStates.entities,
      ...entities,
    },
    ui: {
      ...initialStates.ui,
      eisPlanLots: {
        ...initialStates.ui.eisPlanLots,
        eisNum: {
          ...initialStates.ui.eisPlanLots.eisNum,
          ...get(result.meta, 'ui.eisPlanLots.eisNum', {}),
        },
      },
    },
  }
}
