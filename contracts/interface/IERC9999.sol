// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface IERC9999{
    
    event TransferUser(address from,address to,uint256 tokenId);
    
    event ApprovalUser(address indexed user, address indexed approved, uint256 indexed tokenId);

    event ApprovalUserForAll(address indexed user, address indexed operator, bool approved);
    
    function balanceOfUser(address user) external view returns (uint256 balance);
    
    function userOf(uint256) external view returns (address user);
    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    function transferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    function approveUser(address to, uint256 tokenId) external;
    
    function getApprovedUser(uint256 tokenId) external view returns (address operator);
    
    function isApprovedUserForAll(address user, address operator) external view returns (bool);
    
    function setApprovalUserForAll(address operator, bool _approved) external;
    
}
