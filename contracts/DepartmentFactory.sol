// DepartmentFactory.sol
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

contract DepartmentFactory {
    uint private departmentDigits = 16;
    uint private modulus = 10 ** departmentDigits;
    uint private randNonce = 0;


    struct Department {
        uint id;
        string name;
    }


    mapping(uint => Department) public departments;
    mapping(uint=>address) public departmentToOwner;
    mapping(address=>uint[])  public departmentKeys;
    mapping(address=>bytes32) public merkleRoots;

    event departmentCreated(uint id,string name,address indexed owner,bytes32 merkeRoot);



    constructor(){
//        departmentKeys[msg.sender] = [1, 2, 3, 4, 5];
    }
    function _generateRandomId(string memory _name) view private returns (uint256) {
        uint id = uint(keccak256(abi.encode(_name, randNonce, block.timestamp))) % modulus;
        return id;
    }

    function createDepartment(string memory _name) public returns (Department memory) {
        require(!_departmentExists(_name), "Department has already existed");
        uint id = _generateRandomId(_name);
        departments[id] = Department(id, _name);
        departmentKeys[msg.sender].push(id);
        departmentToOwner[id]=msg.sender;
        generateMerkleRoot(msg.sender);
        emit departmentCreated(id,_name,msg.sender,merkleRoots[msg.sender]);
        return departments[id];
    }

    function getDepartments() public view returns (Department[] memory) {
        Department[] memory result = new Department[](departmentKeys[msg.sender].length);
        for (uint i = 0; i < departmentKeys[msg.sender].length; i++) {
            result[i] = departments[departmentKeys[msg.sender][i]];
            console.log(result[i].id);
            console.log(result[i].name);
        }
        return result;

    }

    function _departmentExists(string memory _name) view private returns (bool) {
        for (uint i = 0; i < departmentKeys[msg.sender].length; i++) {
            if (keccak256(abi.encodePacked(departments[departmentKeys[msg.sender][i]].name)) == keccak256(abi.encodePacked(_name))) {
                return true;
            }
        }
        return false;
    }

    function departmentKeyExists(uint _id,address owner)  view external returns (bool){
        for (uint i = 0; i < departmentKeys[owner].length; i++) {
            if (departmentKeys[owner][i] == _id) {
                return true;
            }
        }
        return false;
    }

    function generateMerkleRoot(address owner)  public {
        uint DepartmentKeysLength = departmentKeys[owner].length;
        if (DepartmentKeysLength == 0) {
            merkleRoots[owner]= 0x0;
            return;
        }
        bytes32[] memory departmentKeyHashes = new bytes32[](departmentKeys[owner].length);
        for (uint i = 0; i < departmentKeys[owner].length; i++) {
            departmentKeyHashes[i] = (keccak256(abi.encodePacked(departmentKeys[owner][i])));
        }

        uint length = departmentKeyHashes.length;
        while (length > 1) {
            uint counter = 0;
            for (uint i = 0; i < length; i += 2) {
                if (i == length - 1) {
                    departmentKeyHashes[counter] = keccak256(abi.encodePacked(departmentKeyHashes[i], departmentKeyHashes[i]));
                } else {
                    departmentKeyHashes[counter] = keccak256(abi.encodePacked(departmentKeyHashes[i], departmentKeyHashes[i + 1]));
                }
                counter++;
            }
            length = counter;
        }
        merkleRoots[owner]=departmentKeyHashes[0];
    }

    function getMerklePath(uint departmentId) public returns (bytes32[] memory){
        bytes32[] memory result = new bytes32[](Math.log2(departmentKeys[msg.sender].length) + 2);
        bytes32[] memory departmentKeyHashes = new bytes32[](departmentKeys[msg.sender].length);
        for (uint i = 0; i < departmentKeys[msg.sender].length; i++) {
            departmentKeyHashes[i] = (keccak256(abi.encodePacked(departmentKeys[msg.sender][i])));
        }
        uint position = _getDepartmentPosition(departmentId, departmentKeyHashes);
        uint counterResult = 0;
        if (position != type(uint).max) {
            uint length = departmentKeyHashes.length;
            while (length > 1) {
                uint counter = 0;
                for (uint i = 0; i < length; i += 2) {
                    if (i == length - 1) {
                        if (position == i) {
                            result[counterResult] = departmentKeyHashes[i];
                            counterResult++;
                        }
                        departmentKeyHashes[counter] = keccak256(abi.encodePacked(departmentKeyHashes[i], departmentKeyHashes[i]));
                    } else {
                        if (position == i) {
                            result[counterResult] = departmentKeyHashes[i + 1];
                            counterResult++;
                        } else if (position == i + 1) {
                            result[counterResult] = departmentKeyHashes[i];
                            counterResult++;
                        }
                        departmentKeyHashes[counter] = keccak256(abi.encodePacked(departmentKeyHashes[i], departmentKeyHashes[i + 1]));
                    }
                    counter++;
                    position = position / 2;
                }
                length = counter;
            }
            result[counterResult] = departmentKeyHashes[0];
        }
        return result;
    }

    function getMerklePathArray(uint[] memory departmentIds,address owner) view external returns (bytes32[][] memory){
        ElementRow[] memory  result=new ElementRow[](departmentIds.length);
        ElementRow[] memory merkleTree=generateMerkleTree(owner);
        bytes32[] memory hashes=merkleTree[0].hashes;
         for(uint i=0;i<departmentIds.length;i++){
             bytes32[] memory merklePath=new bytes32[](Math.log2(departmentKeys[owner].length)+2);
             uint merklePathCounter=0;
             uint position=_getDepartmentPosition(departmentIds[i],hashes);
             if(position!= type(uint).max){
                 for(uint j=0;j<merkleTree.length;j++){
                     if(position==merkleTree[j].hashes.length-1){
                         if(position%2==0) {
                             merklePath[merklePathCounter]=merkleTree[j].hashes[position];
                             merklePathCounter++;
                         }
                         else {
                             merklePath[merklePathCounter]=merkleTree[j].hashes[position-1];
                             merklePathCounter++;
                         }

                     }else{
                         if(position%2==0) {
                             merklePath[merklePathCounter]=merkleTree[j].hashes[position+1];
                             merklePathCounter++;
                         }
                         else {
                             merklePath[merklePathCounter]=merkleTree[j].hashes[position-1];
                             merklePathCounter++;
                         }
                     }
                     position=position/2;
                 }
             }
             result[i]=(ElementRow(merklePath));
         }
        return convertToBytesArray(result);
    }
    struct ElementRow {
        bytes32[] hashes;
    }
    function generateMerkleTree(address owner) view public returns (ElementRow[] memory){
        ElementRow[] memory merkleTree=new ElementRow[](Math.log2(departmentKeys[owner].length)+2);
        uint DepartmentKeysLength=departmentKeys[owner].length;
        if(DepartmentKeysLength==0) return  new ElementRow[](0);
        bytes32[] memory departmentKeyHashes=new bytes32[](departmentKeys[owner].length);
        for(uint i=0;i<departmentKeys[owner].length;i++){
            departmentKeyHashes[i]=keccak256(abi.encodePacked(departmentKeys[owner][i]));
        }
        merkleTree[0]=ElementRow(departmentKeyHashes);
        uint length=departmentKeyHashes.length;
        uint merkleTreeCount=1;
        while(length>1){
            bytes32[] memory newRow=new bytes32[]((length+1)/2);
            uint counter=0;
            for(uint i=0;i<length;i+=2){
                if(i==length-1){
                   newRow[counter]=keccak256(abi.encodePacked(merkleTree[merkleTreeCount-1].hashes[i],merkleTree[merkleTreeCount-1].hashes[i]));
                }else{
                    newRow[counter] =keccak256(abi.encodePacked(merkleTree[merkleTreeCount-1].hashes[i],merkleTree[merkleTreeCount-1].hashes[i+1]));
                }
                counter++;
            }

            length=counter;
            merkleTree[merkleTreeCount]=(ElementRow(newRow));
            merkleTreeCount++;
        }
        return merkleTree;
    }


    function _getDepartmentPosition(uint departmentId, bytes32[] memory hashes) view private returns (uint){

        for (uint i = 0; i < hashes.length; i++) {
            if (keccak256(abi.encodePacked(departmentId)) == hashes[i]) return i;
        }
        return type(uint).max;
    }

    function departmentKeyListExits(uint[] memory departmentIds,address owner) view external returns (bool){
        for(uint i=0;i<departmentIds.length;i++){
            uint counter=0;
            for(uint j=0;j<departmentKeys[owner].length;j++){
                if(departmentIds[i]==departmentKeys[owner][j]) break;
                counter++;
            }
            if(counter==departmentKeys[owner].length) return false;
        }
        return true;
    }
    function convertToBytesArray(ElementRow[] memory elementRows) public pure returns (bytes32[][] memory) {
        bytes32[][] memory result = new bytes32[][](elementRows.length);
        for (uint i = 0; i < elementRows.length; i++) {
            result[i] = elementRows[i].hashes;
        }
        return result;
    }

    function getDepartmentIdPosition(uint departmentId,address owner) view external returns(uint){
        for(uint i=0;i<departmentKeys[owner].length;i++){
            if(departmentId==departmentKeys[owner][i]) return i;
        }
        return type(uint).max;

    }

    function getDepartmentLength(address owner) external view returns(uint){
        return departmentKeys[owner].length;
    }

    modifier onlyOwner(uint _departmentId){
        require(msg.sender==departmentToOwner[_departmentId]);
        _;
    }


}
