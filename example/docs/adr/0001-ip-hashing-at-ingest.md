# IP hashing at ingest, not at query time

Click events arrive with the visitor's IP address, which we need for
country-level geolocation but cannot retain under GDPR. We hash the IP
with a daily-rotated salt at the redirect service before the event is
written to ClickHouse — the raw IP never leaves the redirect process
memory. Country lookup happens against the raw IP in the same process,
producing a country code that is stored alongside the hash.

We chose this over hashing at query time (which would have required
storing raw IPs even briefly) because GDPR scope is reduced when raw
identifiers never reach durable storage, and because the daily salt
rotation gives us a defensible 24h ceiling on cross-event correlation
for abuse investigation without permanent linkability.

## Consequences

- We cannot retroactively re-geolocate events if our IP-to-country
  database has bugs — the raw IP is gone. We accept this; the database
  is mature and we have not needed retroactive correction in 2+ years
  on the prior system.
- Abuse investigation across more than 24h of click events is not
  possible. This is a deliberate trade-off, not an oversight.
