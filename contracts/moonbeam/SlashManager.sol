// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Span } from "./Span.sol";

interface IStakeManager {
  function slash(address _signer) external;
}

contract SlashManager is Span {

  mapping(address => mapping(uint256 => bool)) public slashed;

  function slash(address _signer, uint256 _currentSpan) public {
    require(msg.sender == block.coinbase, "only coinbase allowed");
    require(msg.sender == OFFICIAL_NODE_ADDR, "only official node allowed");
    require(tx.gasprice == 0, "gas price must be 0");
    require(getSpanNumber(block.number) == _currentSpan, "not the right span");
    require(!isSignerSlashed(_signer, _currentSpan), "already slashed");
    
    slashed[_signer][_currentSpan] = true;
    IStakeManager(STAKE_MANAGER_ADDR).slash(_signer);
    
  }

  function isSignerSlashed(address _signer, uint256 _span) public view returns (bool) {
    return slashed[_signer][_span];
  }
}