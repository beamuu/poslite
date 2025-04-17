# Moonbeam setup

1. Go to `contracts/moonbeam/Config.sol`
2. Setup consensus configs
   1. Simple setup - set `OFFICIAL_NODE_ADDR` to your main KUB Chain (geth) node account (signer), this assign this node as a sentry node
3. Run `npm run moonbeam` and you will get the `moonbeam.json` at the root of the project.
4. Back to you KUB Chain (geth) use the `moonbeam.json` as a genesis.json file.
Simple as that