import { createSelector } from 'reselect'
import values from 'lodash/values'

import { getOwnerships } from 'selectors/entities'
import { getOwnershipId } from 'selectors/props'

export const getArrayOwnerships = createSelector(
  [getOwnerships],
  (ownerships) => values(ownerships)
)

export const getOwnership = createSelector(
  [getOwnerships, getOwnershipId],
  (ownerships, ownershipId) => ownerships[ownershipId]
)
