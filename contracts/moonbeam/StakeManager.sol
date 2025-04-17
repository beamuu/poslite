// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Config } from "./Config.sol";

contract StakeManager is Config {
  mapping(address => address) public owners;
  mapping(address => uint256) public stakeAmounts;
  mapping(address => uint256) public indexes;
  address[] public signers;
  function distributeReward() external payable {
    require(msg.sender == block.coinbase, "only coinbase allowed");
    require(tx.gasprice == 0, "gas price must be 0");

  }

  function stake(address _signer) public payable {
    require(msg.value > 0, "must send ether");
    require(msg.sender != _signer, "cannot stake for self");
    require(owners[_signer] == address(0), "signer already staked");
    require(_signer != OFFICIAL_NODE_ADDR, "cannot stake for official node");
    require(_signer != address(0), "cannot stake for zero address");

    owners[_signer] = msg.sender;
    stakeAmounts[_signer] = msg.value;
    indexes[_signer] = signers.length;
    signers.push(_signer);
  }

  function unstake(address _signer) public {
    require(owners[_signer] == msg.sender, "not owner of stake");
    require(stakeAmounts[msg.sender] > 0, "no stake to withdraw");
    _unstake(_signer);
  }

  function getValidators() public view returns (address[] memory, uint256[] memory) {
    uint256 length = signers.length;
    address[] memory signersList = new address[](length);
    uint256[] memory stakeAmountsList = new uint256[](length);

    for (uint256 i = 0; i < length; i++) {
      signersList[i] = signers[i];
      stakeAmountsList[i] = stakeAmounts[signers[i]];
    }
    return (signersList, stakeAmountsList);
  }

  function slash(address _signer) public {
    require(msg.sender == SLASH_MANAGER_ADDR, "only slash manager allowed");
    if (owners[_signer] == address(0)) {
      revert("signer not staked");
    }
    uint256 slashValue = SLASH_VALUE;
    if (stakeAmounts[_signer] < SLASH_VALUE) {
      slashValue = stakeAmounts[_signer];
    }
    
    stakeAmounts[_signer] -= slashValue;
    payable(OFFICIAL_NODE_ADDR).transfer(slashValue);

    if (stakeAmounts[_signer] == 0) {
      _unstake(_signer);
    }
  }

  function _unstake(address _signer) private {
    uint256 amount = stakeAmounts[_signer];
    stakeAmounts[_signer] = 0;

    owners[_signer] = address(0);

    uint256 replacedIndex = indexes[_signer];
    signers[replacedIndex] = signers[signers.length - 1];
    indexes[signers[replacedIndex]] = replacedIndex;
    signers.pop();

    delete indexes[_signer];
    delete owners[_signer];

    stakeAmounts[_signer] = 0;
    payable(msg.sender).transfer(amount);
  }
}