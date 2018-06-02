import { createSelector } from 'reselect'
import filter from 'lodash/filter'
import sortBy from 'lodash/sortBy'

import { getContacts } from 'selectors/entities'
import { getContactType, getContactId } from 'selectors/props'

export const getArrayContactsByType = createSelector(
  [getContacts, getContactType],
  (contacts, type) =>
    sortBy(
      filter(contacts, (contact) => contact.role === type),
      (contact) => contact.position)
)

export const getContact = createSelector(
  [getContacts, getContactId],
  (contacts, id) => contacts[id]
)
