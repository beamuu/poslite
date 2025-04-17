// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Config } from "./Config.sol";

contract Span is Config {
    function currentSpanNumber() public view returns (uint256) {
        return getSpanNumber(block.number);
    }

    function getSpanNumber(uint256 _blockNumber) public pure returns (uint256) {
        if (_blockNumber < SPAN_START_BLOCK) {
            return 0;
        }
        uint256 spanNumber = (_blockNumber - SPAN_START_BLOCK) / SPAN_SIZE;
        return spanNumber;
    }
}