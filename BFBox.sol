// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./BF721.sol";
import "./BFOperator.sol";

contract BeFitterBox is BeFitter721, BeFitterOperator {

    using Counters for Counters.Counter;
    Counters.Counter private _boxIds;

    string private _baseuri;

    mapping(uint256 => string) private _boxType;

    event MintBox(address indexed to, uint256 boxId);
    event TransferBox(address indexed from, address indexed to, uint256 boxId, string message);

    constructor() ERC721("BeFitterBox", "BFB") {
        _operators[msg.sender] = true;
    }

    modifier isValidBoxId(uint256 boxId) {
        require(boxId < _boxIds.current(), "Invalid boxID");
        _;
    }

    function setBaseTokenURI(string memory baseURI)
        public 
        onlyOperators
    {
        _baseuri = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseuri;
    }

    function mint(address to, string memory boxType)
        public
        onlyOperators
    {       
        uint256 boxId = _boxIds.current();
        _safeMint(to, boxId);
        _boxType[boxId] = boxType;
        _boxIds.increment();
        
        emit MintBox(to, boxId);
    }

    function transferFrom(address from, address to, uint256 boxId)
        public
        virtual override
    {
        require(_isApprovedOrOwner(_msgSender(), boxId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, boxId);

        emit TransferBox(msg.sender, to, boxId, "");
    }

    function transferWithMessage(address to, uint256 boxId, string memory message)
        public
    {
        require(_isApprovedOrOwner(_msgSender(), boxId), "ERC721: transfer caller is not owner nor approved");
        _transfer(msg.sender, to, boxId);

        emit TransferBox(msg.sender, to, boxId, message);
    }

    function getBoxType(uint256 boxId) public view isValidBoxId(boxId) 
        returns(string memory)
    {
        return _boxType[boxId];
    }

}