# POSLite - Proof-of-Stake Implementation on KUB Chain
A Light weight consensus with pre-deployed consensus contracts. Specially work on KUB Chain

### 📘 Introduction

KUB Chain offers an exceptional blockchain node software based on (Geth)[https://github.com/kub-chain/bkc], designed to make blockchain logic highly customizable and adaptable for a wide range of use cases. Whether you’re building DeFi applications, staking systems, or experimenting with governance models, KUB Chain provides a powerful and flexible foundation.

At the core of KUB Chain is its robust Proof-of-Stake (PoS) consensus mechanism, which drives a vibrant staking ecosystem. Users can actively participate through innovative features such as:
	•	Stake-to-Vote — allowing token holders to influence governance decisions.
	•	Delegation — enabling users to delegate their stake to trusted validators.
	•	Staking NFTs — empowering NFT holders to engage with staking and governance mechanics.

These features not only encourage deeper community involvement but also enhance decentralization and network security.

Recognizing that consensus is fundamental to everything great on KUB Chain, this project sets out to explore and develop new variants of the PoS model within the KUB Chain node itself. By embracing creativity and innovation, we aim to make the KUB ecosystem even more dynamic, versatile, and future-ready.

Let creativity lead. Let KUB grow stronger.

### 🌙 Moonbeam: A Lightweight PoS Variant

Moonbeam is the lightweight implementation of KUB Chain’s Proof-of-Stake consensus—engineered to be as lean and minimal as possible. It strips away complex and sensitive components that often make consensus maintenance challenging, resulting in a streamlined, modular, and developer-friendly design.

By focusing on simplicity and clarity, Moonbeam opens the door for easier experimentation, faster iteration, and greater flexibility in customizing consensus logic for unique blockchain applications.

Key features
- Stake / Unstake for validators
- Sentry node - Slash unpropagated validators
- No minimum stake for joining
- Stakes = propability - More stakes, more blocks you get

Few steps to deploy
- Make sure you have (KUB Chain node)[https://github.com/kub-chain/bkc] set up correctly like any ethereum node
- Generate moonbeam genesis file (see docs/moonbeam.md)
- Use this genesis with your KUB Chain node

Enjoy

