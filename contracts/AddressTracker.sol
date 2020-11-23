pragma solidity ^0.6.0;

import "./contracts/token/ERC20/ERC20.sol";

contract AddressTracker {
  
  mapping(bytes32 => ERC20) locationToToken; 
  mapping(ERC20 => address) tokenToOwner;
  mapping(ERC20 => bytes32) tokenToCompleteHash;
  mapping(bytes32 => bool) locationExist;
  
  address govtAddress;
  bool addressSet;

  constructor() public {
    addressSet = false;
  }

  function setGovtAddress(address _govtAddress) public {
    require(addressSet == false, "The government address should not be set");
    govtAddress = _govtAddress;
    addressSet = true;
  }
  
  function getGovtAddress() public view returns(address) {
    return govtAddress;
  }

  /*
  function setLocHash(string memory long, string memory lat, string memory a1, string memory a2) public pure returns(bytes32) {
      return keccak256(abi.encodePacked(long, lat, a1, a2));
  }
  
  function setLocHash1(string memory long, string memory lat, string memory a1, string memory a2) public pure returns(bytes32) {
      return keccak256(abi.encodePacked(long, lat, a1, a2));
  }
  
  function setcompHash(string memory long, string memory lat, string memory a1, string memory a2, string memory res, string memory nonce) public pure returns(bytes32) {
      return keccak256(abi.encodePacked(long, lat, a1, a2, res, nonce));
  }  
  
  function getToken(bytes32 locationHash) public view returns(ERC20){
      return locationToToken[locationHash];
  }
  
  function getOwner(ERC20 tkn) public view returns(address){
      return tokenToOwner[tkn];
  }
  */
  
  function mintToken(bytes32 locationHash) public {
    // locationHash -> hash([long, lat, add1, add2])
    // will get token address
    require(locationExist[locationHash] == false, "Token for this location already exist");
    require(msg.sender == govtAddress, "Only the government can mint tokens");
    ERC20 tkn = new ERC20("x", "x");
    locationToToken[locationHash] = tkn;
    locationExist[locationHash] = true;
    tokenToOwner[tkn] = govtAddress;
  }
  
  function allot(bytes32 locationHash, bytes32 completeHash, address owner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // completeHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // owner -> first resident
    require(locationExist[locationHash] == true, "Token for this location does not exist");
    require(msg.sender == govtAddress, "Only the government can allot a new token");
    ERC20 token = locationToToken[locationHash];
    require(tokenToOwner[token] == govtAddress, "Token alloted alreay");
    tokenToCompleteHash[token] = completeHash;
    tokenToOwner[token] = owner;
  }
  
  function transfer(bytes32 locationHash, bytes32 oldHash, bytes32 newHash, address newOwner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // oldHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // newHash -> hash(new [long, lat, add1, add2, resident hash, nonce])
    
    // newOwner -> first (new) resident
    
    require(locationExist[locationHash] == true, "Token for this location does not exist");
    
    ERC20 token = locationToToken[locationHash];

    // require(tokenToOwner[token] == msg.sender, "you are not the owner");
    require(tokenToCompleteHash[token] == oldHash, "invalid transfer");

    tokenToCompleteHash[token] = newHash;
    tokenToOwner[token] = newOwner;
  }
}