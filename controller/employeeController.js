const Department = require("../models/department");
const Employee = require("../models/employee");
const History = require("../models/history");
const {ethers, JsonRpcProvider} = require("ethers");
const provider = new JsonRpcProvider("http://localhost:8545");
const privateKey = process.env.PERSION1_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey, provider);
const employmentAbi = require("../artifacts/contracts/EmployeeFactory.sol/EmployeeFactory.json");
const employeeContract = new ethers.Contract(process.env.EMPLOYEE_ADDRESS, employmentAbi.abi, wallet);

const create = async (req, res) => {
    try {
        const {name, phoneNumber, departmentIds, managerId, role} = req.body;
        const bigIntDepartmentIds = departmentIds.map((departmentId) => BigInt(departmentId));
        const transaction = await employeeContract.generateEmployee(name, phoneNumber, bigIntDepartmentIds, managerId, role);
        History.create({
            tx: transaction.hash.toString(),
            description: "create new Employee",
            creatorAddress: process.env.PERSION1_ADDRESS
        })
        let eventReceived = false;
        employeeContract.on("EmployeeCreated", (employeeId, phoneNumber, owner, role, event) => {
            if (!eventReceived) {
                eventReceived = true;
                const newEmployee = new Employee({
                    uuid: employeeId.toString(),
                    phoneNumber: phoneNumber,
                    owner: owner.toString(),
                    role: role
                })
                newEmployee.save();
                res.status(200).send({
                    message: "Employee is  created Successfully"
                })
            }
        })
        // Wait for the event to be received or timeout after a reasonable duration
        await new Promise((resolve, reject) => {
            setTimeout(() => {
                if (!eventReceived) {
                    reject(new Error("Timeout: Event not received"));
                } else {
                    resolve();
                }
            }, 10000); // Adjust timeout as needed
        });

    } catch (error) {
        res.status(500).send({
            message: "Server error"
        })

    }


}

const update = async (req, res) => {
    try {
        const {employeeId, name, phoneNumber, departmentIds, managerId, role} = req.body;
        const employee = Employee.findOne({uuid: employeeId});
        const bigIntDepartmentIds = departmentIds.map((departmentId) => BigInt(departmentId));
        const transaction = await employeeContract.updateEmployee(BigInt(employeeId), name, phoneNumber, bigIntDepartmentIds, BigInt(managerId), role);
        History.create({
            tx: transaction.hash.toString(),
            description: "update the Employee",
            creatorAddress: process.env.PERSION1_ADDRESS
        })

        const update = {};
        update.uuid = employeeId;
        if (phoneNumber.length > 0) update.phoneNumber = phoneNumber;
        if (role.length > 0) update.role = role;
        await Employee.updateOne({_id: employee._id}, {$set: update});
        res.status(200).send({
            message: "Updating Successfully"
        })
    } catch (error) {
        res.status(500).send({
            message: "Server error"
        })
    }


}

const deleteEmployee = async (req, res) => {
    try {
        const {employeeId} = req.body;
        const employee = Employee.findOne({uuid: employeeId});
        if (!employee) {
            res.status(500).send({
                message: "the employee does not exist"
            })
            return;
        }
        const tx = await employeeContract.deleteEmployee(BigInt(employeeId));
        History.create({
            tx: tx.hash.toString(),
            description: "delete the Employee",
            creatorAddress: process.env.PERSION1_ADDRESS
        })
        await Employee.deleteOne({_id: employee._id});
        res.status(200).send({
            message: "delete successfully",
        })
    } catch (error) {
        res.status(500).send({
            message: "Server error"
        })
    }
}

const getEmployees = async (req, res) => {
    try {
        const tx = await employeeContract.getEmployees();
        const employees = tx.map((employee) => {
            return [employee[0].toString(), employee[1], employee[2], employee[3].map(id => id.toString()), employee[4].toString(), employee[5]];
        });
        res.status(200).json(employees);
    } catch (error) {
        res.status(401).send({
            message: "the server error"
        })
    }
}
const verifyDepartment=async (req,res)=>{
    try {
        const {departmentIds}=req.body;
        const bigIntDepartmentIds=departmentIds.map((id)=>BigInt(id));
        console.log(bigIntDepartmentIds);
        const tx = await employeeContract.verifyDepartment(bigIntDepartmentIds);
        res.status(200).send({
           message: tx
        })
    } catch (error) {
        res.status(401).send({
            message: "the server error"
        })
    }
}
const getEmployeeDetail=async (req,res)=>{
    try{
        const{id}=req.params;
        const employee=await Employee.findById(id);
        if(employee){
            res.status(500).send({
                message: "The employee does not exist"
            })
        }
        const tx= await  employeeContract.getEmployeeById(BigInt(employee.uuid));
        const response=[
            tx[0].toString(),
            tx[1],
            tx[2],
            tx[3].map((department)=>department.toString()),
            tx[4].toString(),
            tx[5]
        ]

        res.status(200).json(response)

    }catch (error){
        res.status(401).send({
            message: error
        })
    }
}

module.exports = {create, getEmployees, update, deleteEmployee,verifyDepartment,getEmployeeDetail}