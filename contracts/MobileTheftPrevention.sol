pragma solidity ^0.8.0;

contract MobileTheftPrevention {
    struct Device {
        bytes32 id;
        address owner;
        uint256 timestamp; 
        bool isStolen;
    }

    mapping(bytes32 => Device) public devices;
    mapping(address => uint256) public customerProfiles;
    address payable  operatorAddress; 

    event LogDeviceRegistered(bytes32 deviceId, address owner);
    event LogOwnershipTransferred(bytes32 deviceId, address newOwner);
    event LogDeviceBlocked(bytes32 deviceId);
    event LogDeviceUnblocked(bytes32 deviceId);

    function registerDevice(bytes32 deviceId, uint256 customerProfileId) public {
        require(devices[deviceId].owner == address(0), "Device already registered");
        devices[deviceId] = Device(deviceId, msg.sender, block.timestamp, false);
        customerProfiles[msg.sender] = customerProfileId;
        emit LogDeviceRegistered(deviceId, msg.sender);
    }

    function checkOwnership(bytes32 deviceId) public view returns (bool) {
        return devices[deviceId].owner == msg.sender;
    }

    function transferOwnership(bytes32 deviceId, address newOwner) public {
        require(devices[deviceId].owner == msg.sender, "Only the owner can transfer ownership");
        require(newOwner != address(0), "Invalid new owner address");
        devices[deviceId].owner = newOwner;
        devices[deviceId].timestamp = block.timestamp;
        emit LogOwnershipTransferred(deviceId, newOwner);
    }

    function blockDevice(bytes32 deviceId) public {
        require(devices[deviceId].owner == msg.sender, "Only the owner can block the device");
        devices[deviceId].isStolen = true;
        emit LogDeviceBlocked(deviceId);
        // Notify the operator
        require(operatorAddress != address(0), "Operator address is not set");
        operatorAddress.transfer(1);
    }

    function unblockDevice(bytes32 deviceId) public {
        require(devices[deviceId].owner == msg.sender, "Only the owner can unblock the device");
        devices[deviceId].isStolen = false;
        emit LogDeviceUnblocked(deviceId);
        // Notify the operator
        require(operatorAddress != address(0), "Operator address is not set");
        operatorAddress.transfer(1);
    }

    function setOperatorAddress(address payable _operatorAddress) public {
        operatorAddress = _operatorAddress;
}

    function getDeviceStatus(bytes32 deviceId) public view returns (bool) {
        return devices[deviceId].isStolen;
    }

    function isDeviceBlocked(bytes32 deviceId) public view returns (bool) {
        return devices[deviceId].isStolen;
    }
}
