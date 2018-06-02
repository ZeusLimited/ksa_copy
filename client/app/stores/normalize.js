import { camelizeKeys } from 'humps'
import { normalize, schema } from 'normalizr'

const ownership = new schema.Entity('ownerships')
const expert = new schema.Entity('experts')
const user = new schema.Entity('users')
const contact = new schema.Entity('contacts')

export const normalizeEntities = (storeProps) =>
  normalize(camelizeKeys(storeProps), {
    ownerships: [ownership],
    experts: [expert],
    users: [user],
    contacts: [contact],
  })
