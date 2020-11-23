pragma solidity ^0.6.0;

import "./contracts/token/ERC20/ERC20AddressTracker.sol";

contract AddressTracker {
  
  mapping(bytes32 => ERC20AddressTracker) locationToToken; 
  mapping(ERC20AddressTracker => address) tokenToOwner;
  mapping(ERC20AddressTracker => bytes32) tokenToCompleteHash;
  mapping(bytes32 => bool) locationExist;
  mapping(address => ERC20AddressTracker[]) tokenOwner;
  mapping(address => bool) isAuthorized;
  address[] authorities;
  address govtAddress;
  bool addressSet;

  constructor() public {
    addressSet = false;
  }

  function setGovtAddress(address _govtAddress) public {
    require(addressSet == false, "The government address should not be set");
    govtAddress = _govtAddress;
    addressSet = true;
    isAuthorized[govtAddress] = true;
    authorities.push(govtAddress);
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
  
  function getToken(bytes32 locationHash) public view returns(ERC20AddressTracker){
      return locationToToken[locationHash];
  }
  */
  function getBalance(address person) public view returns(uint256){
      ERC20AddressTracker token = tokenOwner[person][0];
      return token.balanceOf(person);
  }
  
  function issueAuthorisation(address _authority) public {
    require(msg.sender == govtAddress, "Only government can issue an authorisation");
    isAuthorized[_authority] = true;
    authorities.push(_authority);
  }

  function mintToken(bytes32 locationHash) public {
    // locationHash -> hash([long, lat, add1, add2])
    // will get token address
    require(locationExist[locationHash] == false, "Token for this location already exist");
    require(isAuthorized[msg.sender] == true, "Only the government and authorizing organization can mint tokens");
    ERC20AddressTracker tkn = new ERC20AddressTracker("x", "x", locationHash);
    tkn.mintNeeded(msg.sender, 1);
    locationToToken[locationHash] = tkn;
    locationExist[locationHash] = true;
    tokenToOwner[tkn] = msg.sender;
    tokenOwner[msg.sender].push(tkn);
  }

  function remove(uint index, ERC20AddressTracker[] memory array) private returns(ERC20AddressTracker[] memory) {
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
    require(isAuthorized[msg.sender] == true, "Only the government and authorizing organization can mint tokens");
    ERC20AddressTracker token = locationToToken[locationHash];
    require(isAuthorized[tokenToOwner[token]] == true, "Token alloted already");
    tokenToCompleteHash[token] = completeHash;
    tokenToOwner[token] = owner;
    token.transferNeeded(msg.sender, owner, 1);
    // tokenOwner[govtAddress] = 0;
    uint idx1 = 0;
    uint idx2 = 0;
    uint flag = 0;
    for(idx1 = 0; idx1 < authorities.length; idx1++){
      address IA = authorities[idx1];
      for(idx2 = 0; idx2 < tokenOwner[IA].length; idx2++){
        if(keccak256(abi.encodePacked(tokenOwner[IA][idx2])) == keccak256(abi.encode(token))) {
          flag = 1;
          break;
        }
      }
      if(flag == 1){
        break;
      }
    }

    tokenOwner[owner].push(token);
    tokenOwner[authorities[idx1]] = remove(idx2, tokenOwner[authorities[idx1]]);
    // delete tokenOwner[govtAddress][idx];
  }
  
  function transfer(bytes32 locationHash, bytes32 oldHash, bytes32 newHash, address oldOwner) public {
    // locationHash -> hash([long, lat, add1, add2])
    // oldHash -> hash([long, lat, add1, add2, resident hash, nonce])
    // newHash -> hash(new [long, lat, add1, add2, resident hash, nonce])
    
    // newOwner -> first (new) resident
    
    require(locationExist[locationHash] == true, "Token for this location does not exist");
    
    ERC20AddressTracker token = locationToToken[locationHash];

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