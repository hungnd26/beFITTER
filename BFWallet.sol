// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "./BFOperator.sol";

contract BeFitterWallet is ERC721Holder, ERC1155Holder, BeFitterOperator {

    //=====================================
    event ReceiveBNB(
        address indexed from,
        uint256 amount
    );

    event DepositBNB(
        address indexed from,
        uint256 amount,
        string message
    );

    event WithdrawBNB(
        address indexed to,
        uint256 amount,
        string message
    );

    event TransferBNB(
        address indexed from,
        address indexed to,
        uint256 amount,
        string message
    );

    //=====================================
    event DepositToken(
        address indexed from,
        address indexed tokenAddress,
        uint256 amount,
        string message
    );

    event WithdrawToken(
        address indexed to,
        address indexed tokenAddress,
        uint256 amount,
        string message
    );

    event TransferToken(
        address indexed from,
        address indexed to,
        address indexed tokenAddress,
        uint256 amount,
        string message
    );

    //=====================================
    event DepositItem(
        address indexed from,
        address indexed tokenAddress,
        uint256 tokenId,
        string message
    );

    event WithdrawItem(
        address indexed to,
        address indexed tokenAddress,
        uint256 tokenId,
        string message
    );

    event TransferItem(
        address indexed from,
        address indexed to,
        address indexed tokenAddress,
        uint256 tokenId,
        string message
    );

    //=====================================

    event DepositMTS(
        address indexed from,
        address indexed tokenAddress,
        uint256 tokenId,
        uint256 amount,
        string message
    );

    event WithdrawMTS(
        address indexed to,
        address indexed tokenAddress,
        uint256 tokenId,
        uint256 amount,
        string messgage
    );

    event TransferMTS(
        address indexed from,
        address indexed to,
        address indexed tokenAddress,
        uint256 tokenId,
        string message
    );

    //=====================================

    uint256 tokenWithdrawalLimit;
    uint256 BNBWithdrawalLimit;
    uint256 itemWithdrawalLimit;

    constructor() {
        _operators[msg.sender] = true;
        tokenWithdrawalLimit = 1000000000 * 10**18;
        BNBWithdrawalLimit = 1000 * 10**18;
        itemWithdrawalLimit = 1;
    }

    function setTokenWithdrawalLimit(uint256 amount)
        external
        onlyOwner
    {
        tokenWithdrawalLimit = amount;
    }

    function setBNBWithdrawalLimit(uint256 amount)
        external
        onlyOwner
    {
        BNBWithdrawalLimit = amount;
    }

    function setItemWithdrawalLimit(uint256 amount)
        external
        onlyOwner
    {
        itemWithdrawalLimit = amount;
    }

    receive() external payable {
        emit ReceiveBNB(msg.sender, msg.value);
    }

    function depositBNB(string memory message) external payable {
        emit DepositBNB(msg.sender, msg.value, message);
    }

    function depositToken(
        address tokenAddress,
        uint256 amount,
        string memory message
    ) external {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), amount);

        emit DepositToken(msg.sender, tokenAddress, amount, message);
    }

    function depositItem(
        address tokenAddress,
        uint256 tokenId,
        string memory message
    ) external {
        IERC721 item = IERC721(tokenAddress);
        item.transferFrom(msg.sender, address(this), tokenId);

        emit DepositItem(msg.sender, tokenAddress, tokenId, message);
    }

    function depositMTS(
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        string memory message
    ) external {
        IERC1155 item = IERC1155(tokenAddress);
        item.safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x00");

        emit DepositMTS(msg.sender, tokenAddress, tokenId, amount, message);
    }

    function withdrawBNB(
        address to,
        uint256 amount,
        string memory message
    )
        external
        onlyOperators
    {
        uint256 totalBNB = address(this).balance;
        require(amount <= totalBNB, "withdraw amount exceeds wallet balance");
        require(amount <= BNBWithdrawalLimit, "withdraw amount exceeds withdrawal limit");
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "failed to withdraw BNB");

        emit WithdrawBNB(to, amount, message);
    }

    function withdrawToken(
        address to,
        address tokenAddress,
        uint256 amount,
        string memory message
    )
        external
        onlyOperators
    {
        require(amount <= tokenWithdrawalLimit, "withdraw amount exceeds withdrawal limit");
        IERC20 token = IERC20(tokenAddress);
        token.transfer(to, amount);

        emit WithdrawToken(to, tokenAddress, amount, message);
    }

    function withdrawItem(
        address to,
        address tokenAddress,
        uint256 tokenId,
        string memory message
    )
        external
        onlyOperators
    {
        require(itemWithdrawalLimit > 0, "Cannot withdraw item now");
        IERC721 item = IERC721(tokenAddress);
        item.transferFrom(address(this), to, tokenId);

        emit WithdrawItem(to, tokenAddress, tokenId, message);
    }

    function withdrawMTS(
        address to,
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        string memory message
    )
        external
        onlyOperators
    {
        IERC1155 item = IERC1155(tokenAddress);
        item.safeTransferFrom(address(this), to, tokenId, amount, "0x00");

        emit WithdrawMTS(to, tokenAddress, tokenId, amount, message);
    }

    function transferBNB(
        address to,
        string memory message
    )
        external payable
        onlyOperators
    {
        uint256 amount = msg.value;
        require(amount > 0, "BNB amount must not be zero");

        (bool success, ) = to.call{value: amount}("");
        require(success, "failed to transfer BNB");

        emit TransferBNB(msg.sender, to, amount, message);
    }
     
    function transferToken(
        address from,
        address to,
        address tokenAddress,
        uint256 amount,
        string memory message
    ) external {
        IERC20 token = IERC20(tokenAddress);
        require(msg.sender == from, "caller is not token owner nor approved");
        token.transferFrom(from, to, amount);

        emit TransferToken(from, to, tokenAddress, amount, message);
    }

    function transferItem(
        address from,
        address to,
        address tokenAddress,
        uint256 tokenId,
        string memory message
    ) external {
        IERC721 item = IERC721(tokenAddress);
        require(msg.sender == from, "caller is not token owner nor approved");
        item.transferFrom(from, to, tokenId);

        emit TransferItem(from, to, tokenAddress, tokenId, message);
    }

    function transferMTS(
        address from,
        address to,
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        string memory message
    ) external {
        IERC1155 item = IERC1155(tokenAddress);
        require(msg.sender == from, "caller is not token owner nor approved");
        item.safeTransferFrom(from, to, tokenId, amount, "0x00");

        emit TransferMTS(from, to, tokenAddress, tokenId, message);
    }
}