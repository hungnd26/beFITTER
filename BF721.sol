// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract BeFitter721 is ERC721 {

    using EnumerableSet for EnumerableSet.UintSet;
    mapping(address => EnumerableSet.UintSet) internal _ownedTokens;

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToOwner(to, tokenId);
        }
        else if (to == address(0)) {
            _removeTokenFromOwner(from, tokenId);
        }
        else if (from != to) {
            _addTokenToOwner(to, tokenId);
            _removeTokenFromOwner(from, tokenId);
        }
    }

    function _addTokenToOwner(address to, uint256 tokenId) private {
        _ownedTokens[to].add(tokenId);
    }

    function _removeTokenFromOwner(address from, uint256 tokenId) private {
        _ownedTokens[from].remove(tokenId);
    }

    function getOwnedTokens(address owner)
        public
        view
        returns (bytes32[] memory)
    {
        return _ownedTokens[owner]._inner._values;
    }
}