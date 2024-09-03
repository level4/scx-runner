## Required features

# Internal state

If we are going with internal persistent storage (most of the time, with the ability to dump/hibernate/rehydrate) then we also need:

1. ability to access prior calls/hashes
2. ability to "stash" incomplete transactions
3. GC on the stashed incomplete transactions, clearing them once TTL expired
4. How do we deal with Time? WASM seems to have access to system time but is that truly reliable?

# Required APNs

How do we deal with SCC? I had initially thought to attach them to the entities, but if this is truly meant to be self-contained, that might create permissions problems (who has access to an entity's balance?)

## USDeq, etc contracts

These will need to be their own specialised contracts. Features:

1. 3-level requirements on assents. eg:
  0- 100: 1 assent required (eg. stable authorizor)
  100-1000: 2 assents (eg. authorizor + HSM )
  1000+: 3 assents (eg. above + some sort of encoded 2fa?)

  also include sc.inc.last-resort, an offline backup held for all users.

2. HTTP(?) or equiv access to eg. USDT/USDeq for urrent pricing.

## USDeq/USDT forex contracts

Write access only for sc.inc. Guards around deviations more than 1% normal price. Stop quotes in turbulent times.

USDeq mint_to must include the signed quote from forex? (with ttl)? 