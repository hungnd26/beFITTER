// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./BFOperator.sol";

abstract contract FitterPassMinter is BeFitterOperator {

    event MintFitterPass(address indexed to, uint256 tokenId, uint256 amount);

    function mint(address to, uint256 tokenId, uint256 amount)
        public virtual onlyOperators {}

}