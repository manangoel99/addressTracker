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

  /**
    Constructor for the AddressTracker
    
    This function sets initialise addressSet to false
  */
  constructor() public {
    addressSet = false;
  }

  /**
    This function sets the government address
    
    government address is pushed to authorities array
    
    @param _govtAddress    Account to be set as the government address
  */

  function setGovtAddress(address _govtAddress) public {
    require(addressSet == false, "The government address should not be set");
    govtAddress = _govtAddress;
    addressSet = true;
    isAuthorized[govtAddress] = true;
    authorities.push(govtAddress);
  }

  /**
    getter function to get the government address
  */
  
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
  
  /**
    This function make an account eligible for minting tokens.

    Only government is allowed to make new issuing authorities.
    
    @param _authority    address of account to be made issuing authority.
  */

  function issueAuthorisation(address _authority) public {
    require(msg.sender == govtAddress, "Only government can issue an authorisation");
    isAuthorized[_authority] = true;
    authorities.push(_authority);
  }

  function getAuthority() public view returns(address[] memory) {
    return authorities;
  }

  /**
    This function mints a token for a given location
    
    Only issuing authorities are allowed to mint tokens
    
    @param locationHash    hash of [longitude, latitude, address_line_1, address_line_2]
  */

  function mintToken(bytes32 locationHash) public {
    require(locationExist[locationHash] == false, "Token for this location already exist");
    require(isAuthorized[msg.sender] == true, "Only the government and authorizing organization can mint tokens");
    ERC20AddressTracker tkn = new ERC20AddressTracker("x", "x", locationHash);
    tkn.mintNeeded(msg.sender, 1);
    locationToToken[locationHash] = tkn;
    locationExist[locationHash] = true;
    tokenToOwner[tkn] = msg.sender;
    tokenOwner[msg.sender].push(tkn);
  }

  /**
    This function removes a token from the issuing authorities.
    
    @param index    index of the token to remove
    @param array    array from which to remove the token
  */

  function remove(uint index, ERC20AddressTracker[] memory array) private returns(ERC20AddressTracker[] memory) {
    for (uint i = index; i<array.length-1; i++){
        array[i] = array[i+1];
    }
    delete array[array.length-1];
    // array.length--;
    return array;
    }
  
  /**
    This function allot a token to the owner of the location.
    
    @param locationHash  hash of [longitude, latitude, address_line_1, address_line_2]
    @param completeHash  hash of [longitude, latitude, address_line_1, address_line_2, all residents, owner]
    @param owner         Owner of land
  */

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
      // address IA = authorities[idx1];
      for(idx2 = 0; idx2 < tokenOwner[authorities[idx1]].length; idx2++){
        if(keccak256(abi.encodePacked(tokenOwner[authorities[idx1]][idx2])) == keccak256(abi.encodePacked(token))) {
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

  /**
    This function transfers the ownership of land.
    
    The owner can tranfer the ownership by providing correct details

    @param locationHash     hash of [longitude, latitude, address_line_1, address_line_2]
    @param oldHash          old hash of [longitude, latitude, address_line_1, address_line_2, all residents, owner]
    @param newHash          new hash of [longitude, latitude, address_line_1, address_line_2, all residents, owner]
    @param oldOwner         Previous Owner of land
  */
  
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
      if(keccak256(abi.encodePacked(tokenOwner[oldOwner][idx])) == keccak256(abi.encodePacked(token))) {
        break;
      }
    }
    tokenOwner[msg.sender].push(token);
    tokenOwner[oldOwner] = remove(idx, tokenOwner[oldOwner]);
  }
}