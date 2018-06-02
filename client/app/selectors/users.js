import { createSelector } from 'reselect'
import { values, map } from 'lodash'

import { getUsers } from 'selectors/entities'
import { getArrayContactsByType, getContact } from 'selectors/contacts'

export const getArrayUsers = createSelector(
  [getUsers],
  (users) => values(users)
)

export const getArrayUserContacts = createSelector(
  [getUsers, getArrayContactsByType],
  (users, contacts) =>
    map(contacts, (contact) => users[contact.userId])
)

export const getUser = createSelector(
  [getUsers, getContact],
  (users, contact) => users[contact.userId]
)
