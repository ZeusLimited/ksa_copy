import { createSelector } from 'reselect'
import values from 'lodash/values'

import { getExperts } from 'selectors/entities'
import { getExpertId } from 'selectors/props'

export const getArrayExperts = createSelector(
  [getExperts],
  (experts) => values(experts)
)

export const getExpert = createSelector(
  [getExperts, getExpertId],
  (experts, expertId) => experts[expertId]
)
