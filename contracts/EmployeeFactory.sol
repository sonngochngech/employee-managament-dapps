pragma solidity ^0.8.20;

import "./DepartmentFactory.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";
contract EmployeeFactory {
    uint private employeeDigits = 16;
    uint private modulus = 10 ** employeeDigits;
    uint private randNonce=0;
    uint public employeeMerkleRoot;
    DepartmentFactory public departmentInstance;

    constructor(address _departmentAddress){
        departmentInstance=DepartmentFactory(_departmentAddress);
    }
    struct Employee {
        uint id;
        string name;
        string phoneNumber;
        uint[] departmentIds;
        uint managerId;
        string role;
    }

    mapping(uint  => Employee)  public employees;
    mapping(uint => Employee) public managers;

    mapping(address=>uint[])public  employeeKeys;
    mapping(address=>uint[]) public managerKeys;

    mapping(uint=>address) public employeeToOwner;
    mapping(address=>uint[]) public ownEmployees;

    event EmployeeCreated(uint id,string indexed phoneNumber,address indexed owner);
    event EmployeeUpdated(uint indexed id);
    event EmployeeDeleted(uint indexed id);




    function generateEmployee(string memory  _name, string memory  _phoneNumber, uint[] memory _departmentIds, uint _managerId, string  memory _role) public {
        require(!_phoneNumberExists(_phoneNumber), "Phone number exists");
        require(departmentInstance.departmentKeyListExits(_departmentIds,msg.sender),"There is a department that does not exist");
        if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("Manager"))) {
            require(!(_managerId>0),"Error");
            uint id = _generateRandomId(_phoneNumber);
            employees[id] = Employee(id, _name, _phoneNumber, _departmentIds, _managerId, _role);
            employeeKeys[msg.sender].push(id);
            managers[id] = employees[id];
            managerKeys[msg.sender].push(id);
            employeeToOwner[id]=msg.sender;
            emit EmployeeCreated(id,_phoneNumber,msg.sender);
        } else if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("Employee"))) {
            if(_managerId>0)   require(_managerExists(_managerId), "Don't exists the manager ");
            uint id = _generateRandomId(_phoneNumber);
            employees[id] = Employee(id, _name, _phoneNumber, _departmentIds, _managerId, _role);
            employeeKeys[msg.sender].push(id);
            employeeToOwner[id]=msg.sender;
            emit EmployeeCreated(id,_phoneNumber,msg.sender);
        }
    }
    function deleteEmployee(uint _employeeId) public onlyOwner(_employeeId)  {
        uint indexToDelete=type(uint).max;
        for(uint i=0;i<employeeKeys[msg.sender].length;i++){
            if(employeeKeys[msg.sender][i]==_employeeId){
                indexToDelete=i;
                break;
            }
        }

        require(indexToDelete!=type(uint).max,"The employee does not exist");
        if(keccak256(abi.encode(employees[_employeeId].role))==keccak256(abi.encode("Manager"))){
            uint indexToDeleteManager=0;
            for(uint i=0;i<employeeKeys[msg.sender].length;i++){
                if(employees[employeeKeys[msg.sender][i]].managerId == _employeeId){
                    employees[employeeKeys[msg.sender][i]].managerId=0;
                }
            }
            for(uint i=0;i<managerKeys[msg.sender].length;i++){
                if(managerKeys[msg.sender][i]== _employeeId){
                    indexToDeleteManager=i;
                }
            }
            managerKeys[msg.sender][indexToDeleteManager]=managerKeys[msg.sender][managerKeys[msg.sender].length-1];
            managerKeys[msg.sender].pop();
        }
        delete employees[indexToDelete];
        employeeKeys[msg.sender][indexToDelete]=employeeKeys[msg.sender][employeeKeys[msg.sender].length -1];
        employeeKeys[msg.sender].pop();
        emit EmployeeDeleted(_employeeId);
    }

    function getEmployees() public view  returns (Employee[] memory){
        Employee[] memory result=new Employee[](employeeKeys[msg.sender].length);
        for (uint i = 0; i < employeeKeys[msg.sender].length; i++) {
            result[i] = employees[(employeeKeys[msg.sender])[i]];
        }
        return result;
    }

    function updateEmployee(uint _employeeId,string memory _name,string memory _phoneNumber,uint[] memory _departmentIds,uint _managerId,string  memory _role) public onlyOwner(_employeeId) {
        require(_employeeExists(_employeeId),"Employee does not exists");
        if(bytes(_phoneNumber).length> 0){
            require(!_phoneNumberExists(_phoneNumber),"Phone number exists");
            employees[_employeeId].phoneNumber=_phoneNumber;
        }

        if(bytes(_name).length>0) employees[_employeeId].name=_name;
        if(_managerId>0){
            require(_managerExists(_managerId) && keccak256(abi.encodePacked(_role))!=keccak256(abi.encodePacked("Manager")),"Manager does not exists");
            if(keccak256(abi.encodePacked(employees[_employeeId].role))==keccak256(abi.encodePacked("Manager"))){
                require(keccak256(abi.encodePacked(_role))==keccak256(abi.encodePacked("Employee")),"");
            }
            employees[_employeeId].managerId=_managerId;
        }
        if(_departmentIds.length!=0){
            require(departmentInstance.departmentKeyListExits(_departmentIds,msg.sender),"There is a department that does not exist");
            employees[_employeeId].departmentIds=_departmentIds;
        }
        if(bytes(_role).length>0){
            require(keccak256(abi.encodePacked(_role))==keccak256(abi.encodePacked("Manager")) ||keccak256(abi.encodePacked(_role))==keccak256(abi.encodePacked("Employee")),"The role does not exist" );
            bytes32 roleHash=keccak256(abi.encodePacked(employees[_employeeId].role));
            bytes32 _roleHash=keccak256(abi.encodePacked(_role));
            bytes32 managerHash=keccak256(abi.encodePacked("Manager"));
            bytes32 employeeHash=keccak256(abi.encodePacked("Employee"));
            if(roleHash==managerHash && _roleHash==employeeHash){
                uint indexToDeleteManager=0;
                for(uint i=0;i<employeeKeys[msg.sender].length;i++){
                    if(employees[(employeeKeys[msg.sender])[i]].managerId == _employeeId){
                        employees[(employeeKeys[msg.sender])[i]].managerId=0;
                    }
                }
                for(uint i=0;i<managerKeys[msg.sender].length;i++){
                    if(managerKeys[msg.sender][i]== _employeeId){
                        indexToDeleteManager=0;
                    }
                }
                managerKeys[msg.sender][indexToDeleteManager]=managerKeys[msg.sender][managerKeys[msg.sender].length-1];
                managerKeys[msg.sender].pop();
            }
            employees[_employeeId].role=_role;
        }
        emit EmployeeUpdated(_employeeId);

    }

    function verifyDepartment(uint[] memory departmentIds) public returns (bool){
        bytes32[][]  memory merklePathArray=departmentInstance.getMerklePathArray(departmentIds,msg.sender);
        for(uint i=0;i<merklePathArray.length;i++){
            bytes32 hash=keccak256(abi.encodePacked(departmentIds[i]));
            uint length=merklePathArray[i].length;
            uint position=departmentInstance.getDepartmentIdPosition(departmentIds[i],msg.sender);
            for(uint j=0;j<length-1;j++){
                if(position%2==0) hash=keccak256(abi.encodePacked(hash,merklePathArray[i][j]));
                else hash=keccak256(abi.encodePacked(merklePathArray[i][j],hash));
                position=position/2;
            }
            console.logBytes32(hash);
            console.logBytes32(merklePathArray[i][length-1]);
            if(hash!=merklePathArray[i][length-1]) return false;
        }
        console.log("It is right");
        return true;

    }

    function _generateRandomId(string memory _phoneNumber) private returns (uint){
        uint id = uint(keccak256(abi.encodePacked(_phoneNumber,randNonce,block.timestamp))) % modulus;
        randNonce++;
        return id;
    }

    function _phoneNumberExists(string memory _phoneNumber) view private returns (bool){
        bytes32 phoneHash=keccak256(abi.encodePacked(_phoneNumber));
        for (uint i = 0; i < employeeKeys[msg.sender].length; i++) {
            if (keccak256(abi.encodePacked(employees[employeeKeys[msg.sender][i]].phoneNumber)) == phoneHash) {
                return true;
            }
        }
        return false;
    }

    function _managerExists(uint _id)  view private returns (bool){
        for (uint i = 0; i < managerKeys[msg.sender].length; i++) {
            if (managerKeys[msg.sender][i] == _id) {
                return true;
            }
        }
        return false;
    }

    function _employeeExists(uint _id) view private returns (bool){
        for (uint i = 0; i < employeeKeys[msg.sender].length; i++) {
            if ((employeeKeys[msg.sender])[i] == _id) {
                return true;
            }
        }
        return false;
    }
    modifier onlyOwner(uint _employeeId){
        require(msg.sender==employeeToOwner[_employeeId]);
        _;
    }

}
