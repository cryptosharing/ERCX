// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/IERC9999.sol";
import "./interface/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/utils/ERC721Holder.sol";


contract cryptoSharingV1 is ERC721Holder, ERC721Enumerable{
    
    address public token;
    
    mapping( uint256 => uint256) public _prices;
    
    mapping( uint256 => uint256) public _rentTime;
    
    mapping( uint256 => uint256) public _maxRentTime;
    
    mapping( uint256 => bool) public _rentLock;
    
    mapping( address => uint256) public _reserve;
    
    address immutable public factory;
    
    address public NFTAddress;
    
    constructor (string memory _name,string memory _symbol) ERC721(_name, _symbol)  {
        
        factory = msg.sender;
        
    }

    function setMaxRentTime(uint256 tokenId,uint256 time) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        _maxRentTime[tokenId] = time;
    }

    function setRentLock(uint256 tokenId,bool lock) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        _rentLock[tokenId] = lock;
    }
    
    function initialize(address _nftAddress, address _token) external{
        require(msg.sender == factory ," FORBIDDEN");
        NFTAddress = _nftAddress;
        token = _token;
    }
    
    function lendNFT(uint256 tokenId,uint256 maxRentTime,uint256 price) public {
        super._mint(msg.sender , tokenId);
        _prices[tokenId] = price;
        _maxRentTime[tokenId] = maxRentTime;
        _rentTime[tokenId] = block.timestamp;
        _rentLock[tokenId] = false;
        IERC721(NFTAddress).safeTransferFrom(msg.sender,address(this),tokenId);
    }
    
    function withdarwBalance(uint256 amount) external{
        require(amount <= _reserve[msg.sender],"Insuff amount");
        IERC20(token).transfer(msg.sender,amount);
    }
    
    function rentNFT(uint256 tokenId,uint256 time) external {
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
        require(_rentLock[tokenId]==false,"NFT is lock");
        require(time > _rentTime[tokenId],"ERROR time");
        require(time < _maxRentTime[tokenId] ,"ERROE Time");
        require(_maxRentTime[tokenId] > block.timestamp,"ERROR maxtime");
        _rentTime[tokenId] = time;
        uint256 cur_price = (time - block.timestamp) * _prices[tokenId];
        _reserve[ownerOf(tokenId)] += cur_price;
        IERC20(token).transferFrom(msg.sender,address(this),cur_price);
        IERC9999(NFTAddress).safeTransferUserFrom(address(this),msg.sender,tokenId);
    }
    
    function withDrawNFT(uint256 tokenId) external{
        require(block.timestamp > _rentTime[tokenId],"The NFT is Renting");
        super._burn(tokenId);
        IERC721(NFTAddress).safeTransferFrom(address(this),msg.sender,tokenId);
    }
    
}
