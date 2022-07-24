// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BF721.sol";
import "./BFOperator.sol";

contract BeFitterShoes is BeFitter721, BeFitterOperator {

    uint256 internal _genesisId;
    uint256 internal _spawnId;
    uint256 internal _genesisNum;
    
    string private _baseuri;

    event MintShoes(address indexed to, uint256 tokenId);
    event SpawnShoes(address indexed to, uint256 tokenId);
    event TransferShoes(address indexed from, address indexed to, uint256 tokenId);

    constructor() ERC721("BeFitterShoes", "BFTS") {
        _operators[msg.sender] = true;
    }

    modifier nonZeroGenesisNum() {
        require(_genesisNum > 0, "genesisNum must be set");
        _;
    }

    function setBaseTokenURI(string memory baseURI)
        external
        onlyOperators
    {
        _baseuri = baseURI;
    }

    function setGenesisNum(uint256 genesisNum)
        external
        onlyOwner
    {
        require(_spawnId == _genesisNum, "Cannot set genesisNum when spawning-shoes is available");
        _genesisNum = genesisNum;
        _spawnId = genesisNum;
    }

    function getGenesisNum() external view returns (uint256) {
        return _genesisNum;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseuri;
    }

    function mintGenesis(address to)
        external
        onlyOperators
        nonZeroGenesisNum
    {
        require(_genesisId < _genesisNum, "Exceeds genesis shoes limitation");
        uint256 tokenId = _genesisId;
        _safeMint(to, tokenId);
        _genesisId++;
        
        emit MintShoes(to, tokenId);
    }

    function spawn(address to)
        external
        onlyOperators
        nonZeroGenesisNum
    {
        uint256 tokenId = _spawnId;
        _safeMint(to, tokenId);
        _spawnId++;
        
        emit SpawnShoes(to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        virtual override
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);

        emit TransferShoes(msg.sender, to, tokenId);
    }

    function getTotalShoes() external view returns (uint256) {
        return _genesisId + _spawnId - _genesisNum;
    }
}