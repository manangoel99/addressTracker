pragma solidity ^0.6.0;

import "./contracts/token/ERC20/ERC20.sol";

contract AddressTracker {
  
  mapping(bytes32 => ERC20) locationToToken; 
  mapping(ERC20 => address) tokenToOwner;
  mapping(ERC20 => bytes32) tokenToCompleteHash;
  mapping(bytes32 => bool) locationExist;
  mapping(address => ERC20[]) tokenOwner;
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
  */
  function getBalance(address person) public view returns(uint256){
      ERC20 token = tokenOwner[person][0];
      return token.balanceOf(person);
  }
  
  function mintToken(bytes32 locationHash) public {
    // locationHash -> hash([long, lat, add1, add2])
    // will get token address
    require(locationExist[locationHash] == false, "Token for this location already exist");
    require(msg.sender == govtAddress, "Only the government can mint tokens");
    ERC20 tkn = new ERC20("x", "x");
    tkn.mintNeeded(govtAddress, 1);
    locationToToken[locationHash] = tkn;
    locationExist[locationHash] = true;
    tokenToOwner[tkn] = govtAddress;
    tokenOwner[govtAddress].push(tkn);
  }

  function remove(uint index, ERC20[] memory array) private returns(ERC20[] memory) {
        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        // array.length--;
        return array;
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
    token.transferNeeded(govtAddress, owner, 1);
    // tokenOwner[govtAddress] = 0;
    uint idx = 0;
    for (idx = 0; idx < tokenOwner[govtAddress].length; idx++) {
      if(keccak256(abi.encodePacked(tokenOwner[govtAddress][idx])) == keccak256(abi.encode(token))) {
        break;
      }
    }
    tokenOwner[owner].push(token);
    tokenOwner[govtAddress] = remove(idx, tokenOwner[govtAddress]);
    // delete tokenOwner[govtAddress][idx];
  }
  
  function transfer(bytes32 locationHash, bytes32 oldHash, bytes32 newHash, address oldOwner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // oldHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // newHash -> hash(new [long, lat, add1, add2, resident hash, nonce])
    
    // newOwner -> first (new) resident
    
    require(locationExist[locationHash] == true, "Token for this location does not exist");
    
    ERC20 token = locationToToken[locationHash];

    // require(tokenToOwner[token] == msg.sender, "you are not the owner");
    require(tokenToCompleteHash[token] == oldHash, "invalid transfer");

    tokenToCompleteHash[token] = newHash;
    tokenToOwner[token] = msg.sender;
    token.transferNeeded(oldOwner, msg.sender, 1);
    uint idx = 0;
    for (idx = 0; idx < tokenOwner[oldOwner].length; idx++) {
      if(keccak256(abi.encodePacked(tokenOwner[oldOwner][idx])) == keccak256(abi.encode(token))) {
        break;
      }
    }
    tokenOwner[msg.sender].push(token);
    tokenOwner[oldOwner] = remove(idx, tokenOwner[oldOwner]);
  }
}