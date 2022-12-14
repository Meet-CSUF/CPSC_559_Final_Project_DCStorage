// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./DCStorage.sol";
import "./safemath.sol";

contract BuildOrganization is DCStorage{

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint setId = 0;

    struct Organization {
        uint Id;
        string Name;
        string Description;
        address Owner;
        bool Private;
        uint MemberLimit;
        bytes32 Passcode;
        uint createdAt;
    }

    Organization[] public organizations;

    mapping(uint => address) organizationToOwner;

    mapping(address => uint) ownerOrganizationCount;

    mapping(address => uint[]) addressToOrganizations;

    mapping(uint => address[]) organizationToAddresses;

    function createOrganization(string memory name, string memory description, bool privateBool, uint memberLimit, string memory passcode) public {
        require(bytes(name).length > 0);
        require(bytes(description).length > 0);
        require(memberLimit > 0);
        if(privateBool == false){
            passcode = "";
        }else{
            require(bytes(passcode).length > 0);
        }

        uint id = setId;
        bytes32 userPasscode = keccak256(abi.encodePacked(passcode));
        organizations.push(Organization(id, name, description, msg.sender, privateBool, memberLimit, userPasscode, now));
        organizationToOwner[id] = msg.sender;
        ownerOrganizationCount[msg.sender] = ownerOrganizationCount[msg.sender].add(1);
        addressToOrganizations[msg.sender].push(id);
        organizationToAddresses[id].push(msg.sender);
        setId++;
    }

    function editOrganization(uint id, string memory name, string memory description, bool privateBool, uint memberLimit, string memory passcode) public {
        require(bytes(name).length > 0);
        require(bytes(description).length > 0);
        require(memberLimit > 0);
        if(privateBool == false){
            passcode = "";
        }else{
            require(bytes(passcode).length > 0);
        }

        require(organizationToOwner[id] == msg.sender);
        bytes32 userPasscode = keccak256(abi.encodePacked(passcode));
        organizations[id].Name = name;
        organizations[id].Description = description;
        organizations[id].Private = privateBool;
        organizations[id].MemberLimit = memberLimit;
        organizations[id].Passcode = userPasscode;
    }

    function deleteOrganization(uint id) public {
        require(organizationToOwner[id] == msg.sender);
        if(id >= organizations.length) return;
        for (uint i = id; i < organizations.length - 1; i++){
            organizations[i] = organizations[i + 1];
        }
        delete organizations[organizations.length - 1];
        organizations.length--;
        delete organizationToOwner[id];
        ownerOrganizationCount[msg.sender] = ownerOrganizationCount[msg.sender].sub(1);
    }

    function getOrganizations() external view returns(Organization[] memory) {
        return organizations;
    }

    function getMemberships() external view returns(uint[] memory){
        return addressToOrganizations[msg.sender];
    }

}

