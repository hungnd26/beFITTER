// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./FitterPassMinter.sol";

contract BeFitterPass is ERC1155, FitterPassMinter {

    using EnumerableSet for EnumerableSet.AddressSet;
    uint256 private _currentTokenId;

    EnumerableSet.AddressSet private _whiteList;

    mapping(uint256 => string) itemMetadata;

    constructor() ERC1155("") {
        _operators[msg.sender] = true;
    }

    modifier isValidTokenId(uint256 tokenId) {
        require(tokenId <= _currentTokenId, "Invalid tokenId");
        _;
    }

    function setItemMetadata(uint256 tokenId, string memory metadata)
        external
        onlyOwner
        isValidTokenId(tokenId)
    {
        itemMetadata[tokenId] = metadata;
    }

    function uri(uint256 tokenId) public view override 
        isValidTokenId(tokenId)
        returns (string memory)
    {
        return itemMetadata[tokenId];
    }

    function addWhiteList(address wallet) external onlyOwner {
        _whiteList.add(wallet);
    }

    function removeWhiteList(address wallet) external onlyOwner {
        _whiteList.remove(wallet);
    }

    function getWhiteList() external view returns (bytes32[] memory) {
        return _whiteList._inner._values;
    }

    function createNewToken() external onlyOwner {
        _currentTokenId += 1;
    }

    function getCurrentTokenID() external view returns (uint256) {
        return _currentTokenId;
    }

    function mint(address to, uint256 tokenId, uint256 amount)
        public
        onlyOperators
        isValidTokenId(tokenId)
        override
    {
        _mint(to, tokenId, amount, "");
        emit MintFitterPass(to, tokenId, amount);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(_whiteList.contains(to), "Cannot transfer to this address");
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(_whiteList.contains(to), "Cannot transfer to this address");
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}