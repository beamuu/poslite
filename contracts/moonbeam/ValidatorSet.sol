// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Span } from "./Span.sol";
import { RLPReader } from "solidity-rlp/contracts/RLPReader.sol";

struct MinimalVal {
    address signer;
    uint256 power;
}

interface IStakeManager {
    function getValidators() external returns (address[] memory, uint256[] memory);
}

contract ValidatorSet is Span {

    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    mapping(uint256 => bytes) public validators;

    function commitSpan(bytes memory rlpEncodedData) public {
        require(msg.sender == block.coinbase, "only coinbase allowed");
        require(tx.gasprice == 0, "gas price must be 0");
        require(block.number == _getCommitmentBlock(currentSpanNumber()), "not the right commitment block");
        validators[currentSpanNumber()] = rlpEncodedData;
    }

    function getValidators(uint256 _blockNumber) public view returns (address[] memory, uint256[] memory, address[3] memory) {
            uint256 span = getSpanNumber(_blockNumber);
            if (span == 0) {
                address[] memory signers = new address[](SPAN_SIZE);
                uint256[] memory powers = new uint256[](SPAN_SIZE);
                for (uint256 i = 0; i < SPAN_SIZE; i++) {
                    signers[i] = OFFICIAL_NODE_ADDR;
                    powers[i] = 0;
                }
                address[3] memory ecosystemAddresses = [
                    STAKE_MANAGER_ADDR,
                    SLASH_MANAGER_ADDR,
                    OFFICIAL_NODE_ADDR
                ];
                return (signers, powers, ecosystemAddresses);
            } else {
                MinimalVal[] memory decoded = _rlpDecodeValidator(validators[span]);
                address[] memory signers = new address[](decoded.length);
                uint256[] memory powers = new uint256[](decoded.length);
                for (uint256 i = 0; i < decoded.length; i++) {
                    signers[i] = decoded[i].signer;
                    powers[i] = decoded[i].power;
                }
                address[3] memory ecosystemAddresses = [
                    STAKE_MANAGER_ADDR,
                    SLASH_MANAGER_ADDR,
                    OFFICIAL_NODE_ADDR
                ];
                return (signers, powers, ecosystemAddresses);
            }
            
    }

    function getEligibleValidators() public returns (MinimalVal[] memory) {
        (address[] memory addrs, uint256[] memory power) = IStakeManager(STAKE_MANAGER_ADDR).getValidators();
        MinimalVal[] memory decoded = new MinimalVal[](addrs.length + 1);
        for (uint256 i = 0; i < addrs.length; i++) {
            decoded[i] = MinimalVal({
                signer: addrs[i],
                power: power[i]
            });
        }
        decoded[addrs.length] = MinimalVal({
            signer: OFFICIAL_NODE_ADDR,
            power: 1 ether
        });
        return decoded;
    }

    function _rlpDecodeValidator(bytes memory rlpBytes) private pure returns (MinimalVal[] memory) {
        RLPReader.RLPItem[] memory items = rlpBytes.toRlpItem().toList();
        MinimalVal[] memory decoded = new MinimalVal[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            RLPReader.RLPItem[] memory item = items[i].toList();
            decoded[i] = MinimalVal({
                signer: item[0].toAddress(),
                power: item[1].toUint()
            });
        }
        return decoded;
    }

    function _getCommitmentBlock(uint256 _spanNumber) public pure returns (uint256) {
        return SPAN_START_BLOCK + ((_spanNumber - 1) * SPAN_SIZE) + (SPAN_SIZE / 2 + 1);
    }
}
