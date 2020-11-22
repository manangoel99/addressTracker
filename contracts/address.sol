pragma solidity 0.5.16;

contract Users {
  
  mapping(bytes32 => address) locationToToken; 
  mapping(address => address) tokenToOwner;
  mapping(address => bytes32) tokenToCompleteHash;
  
  function mintToken(bytes32 locationHash) public {
    // locationHash -> hash([long, lat, add1, add2])
    // will get token address
    address tkn;
    locationToToken[locationHash] = tkn;
  }
  
  function allot(bytes32 locationHash, bytes32 completeHash, address owner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // completeHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // owner -> first resident

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