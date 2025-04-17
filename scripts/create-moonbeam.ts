import * as fs from "fs";

const gnsTemplate = `
{
  "config": {
    "chainId": 12123,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "erawanBlock": 0,
    "chaophrayaBlock": 0,
    "clique": {
      "span": 50,
      "period": 5,
      "epoch": 300,
      "validatorContract": "0x0000000000000000000000000000000000000000"
    }
  },
  "nonce": "0x0",
  "timestamp": "0x6088ff55",
  "gasLimit": "0x1C9C380",
  "difficulty": "0x1",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {},
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
`;

function readJsonFile(filePath: string): any | null {
  if (fs.existsSync(filePath)) {
    const jsonData = fs.readFileSync(filePath, "utf-8");
    return JSON.parse(jsonData);
  } else {
    console.log("File does not exist:", filePath);
    return null;
  }
}

function writeJsonToFile(filePath: string, data: any): void {
  try {
    const jsonData = JSON.stringify(data, null, 2);
    fs.writeFileSync(filePath, jsonData, "utf-8");
    console.log(`Data successfully written to ${filePath}`);
  } catch (error) {
    console.error(`Failed to write to file ${filePath}:`, error);
  }
}

function filterConfigs(filePath: string): { [key: string]: string } {
  if (!fs.existsSync(filePath)) {
    console.error("File does not exist:", filePath);
    return {};
  }

  const fileContent = fs.readFileSync(filePath, "utf-8");
  const lines = fileContent
    .split("\n")
    .filter(
      (line) =>
        line.includes("OFFICIAL_NODE_ADDR =") ||
        line.includes("VALIDATOR_SET_ADDR =") ||
        line.includes("STAKE_MANAGER_ADDR =") ||
        line.includes("SLASH_MANAGER_ADDR =") ||
        line.includes("SPAN_SIZE =") ||
        line.includes("SPAN_START_BLOCK =")
    );

  const config: { [key: string]: string } = {};

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    let [key, value] = line.split("=").map((part) => part.trim());
    if (key && value) {
      key = key.split(" ").pop() || key;
      value = value.split(";")[0].trim();
      config[key] = value.replace(/'/g, "").replace(/"/g, "");
    }
  }
  return config;
}

function remove0x(addr: string): string {
  if (addr.startsWith("0x")) {
    return addr.slice(2);
  }
  return addr;
}

function main() {
  const out = process.env.OUT || "moonbeam.json";
  const slashManager = readJsonFile(
    `artifacts/contracts/moonbeam/SlashManager.sol/SlashManager.json`
  );
  if (!slashManager || !slashManager.abi || !slashManager.deployedBytecode) {
    console.error("Failed to read or parse SlashManager.json");
    return;
  }
  const stakeManager = readJsonFile(
    `artifacts/contracts/moonbeam/StakeManager.sol/StakeManager.json`
  );
  if (!stakeManager || !stakeManager.abi || !stakeManager.deployedBytecode) {
    console.error("Failed to read or parse StakeManager.json");
    return;
  }
  const validatorSet = readJsonFile(
    `artifacts/contracts/moonbeam/ValidatorSet.sol/ValidatorSet.json`
  );
  if (!validatorSet || !validatorSet.abi || !validatorSet.deployedBytecode) {
    console.error("Failed to read or parse ValidatorSet.json");
    return;
  }

  const config = filterConfigs(`contracts/moonbeam/Config.sol`);
  const genesis = JSON.parse(gnsTemplate);

  genesis.config.clique.validatorContract = config["VALIDATOR_SET_ADDR"];
  genesis.config.clique.span = parseInt(config["SPAN_SIZE"]);
  genesis.config.chaophrayaBlock = parseInt(config["SPAN_START_BLOCK"]);

  const extradata = `0x0000000000000000000000000000000000000000000000000000000000000000${remove0x(
    config["OFFICIAL_NODE_ADDR"]
  )}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000`;
  genesis.extradata = extradata;

  const allocs: { [key: string]: any } = {};
  allocs[remove0x(config["VALIDATOR_SET_ADDR"])] = {
    balance: "0x0",
    code: validatorSet.deployedBytecode,
  };
  allocs[remove0x(config["STAKE_MANAGER_ADDR"])] = {
    balance: "0x0",
    code: stakeManager.deployedBytecode,
  };
  allocs[remove0x(config["SLASH_MANAGER_ADDR"])] = {
    balance: "0x0",
    code: slashManager.deployedBytecode,
  };

  genesis.alloc = allocs;

  writeJsonToFile(out, genesis)
}

main();
