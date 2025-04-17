// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Config {
  uint256 public constant SPAN_START_BLOCK = 2; // Cannot less than 2
  uint256 public constant SPAN_SIZE = 50;
  uint256 public constant SLASH_VALUE = 1 ether;
  address public constant OFFICIAL_NODE_ADDR = 0xA6f4AEd9E674c29813b11E3529e1C37f4dC75aBA;
  address public constant VALIDATOR_SET_ADDR = 0x00000000000000000000000000000000000BEAb1; // Don't change this
  address public constant STAKE_MANAGER_ADDR = 0x00000000000000000000000000000000000bEAb2; // Don't change this
  address public constant SLASH_MANAGER_ADDR = 0x00000000000000000000000000000000000BeAB3; // Don't change this
}