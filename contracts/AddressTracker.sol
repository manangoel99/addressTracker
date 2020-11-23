pragma solidity ^0.6.0;

contract AddressTracker {
  
  mapping(bytes32 => address) locationToToken; 
  mapping(address => address) tokenToOwner;
  mapping(address => bytes32) tokenToCompleteHash;

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
  
  function getGovtAddress() public returns(address) {
    return govtAddress;
  }

  function mintToken(bytes32 locationHash) public {
    // locationHash -> hash([long, lat, add1, add2])
    // will get token address
    require(msg.sender == govtAddress, "Only the government can mint tokens");
    address tkn;
    locationToToken[locationHash] = tkn;
  }
  
  function allot(bytes32 locationHash, bytes32 completeHash, address owner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // completeHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // owner -> first resident
    require(msg.sender == govtAddress, "Only the government can allot a new token");
    address token = locationToToken[locationHash];
    tokenToCompleteHash[token] = completeHash;
    tokenToOwner[token] = owner;
  }
  
  function transfer(bytes32 locationHash, bytes32 oldHash, bytes32 newHash, address newOwner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // oldHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // newHash -> hash(new [long, lat, add1, add2, resident hash, nonce])
    
    // newOwner -> first (new) resident
    address token = locationToToken[locationHash];

    require(tokenToOwner[token] == msg.sender, "you are not the owner");
    require(tokenToCompleteHash[token] == oldHash, "invalid transfer");

    tokenToCompleteHash[token] = newHash;
    tokenToOwner[token] = newOwner;
  }
}