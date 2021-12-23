// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERCX.sol";

contract ERCXMock is ERCX{
    constructor(string memory name_, string memory symbol_) ERCX(name_ , symbol_){
        
    }

    function safeMint(address from, uint256 tokenId) public{
        _safeMint(from, tokenId);
    }

    function burn(uint256 tokenId) public{
        _burn(tokenId);
    }
}
