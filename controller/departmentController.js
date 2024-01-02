const Department = require("../models/department");
const Employee = require("../models/employee");
const {ethers, JsonRpcProvider} = require("ethers");
const provider = new JsonRpcProvider("http://localhost:8545");
const privateKey = process.env.PERSION1_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey, provider);
const departmentAbi = require("../artifacts/contracts/DepartmentFactory.sol/DepartmentFactory.json");
const departmentContract = new ethers.Contract(process.env.DEPARTMENT_ADDRESS, departmentAbi.abi, wallet);
const create = async (req, res) => {
    const {name} = req.body;
    const existedDepartment = await Department.findOne({name: name});
    if (existedDepartment) {
        res.status(401).send({
            message: "the department exist"
        })
        return;
    }
    try {
        const transaction = await departmentContract.createDepartment(name);
        await transaction.wait();
        let eventReceived = false;
        departmentContract.on("departmentCreated", (departmentId, name, owner, merkleRoot, event) => {
            if (!eventReceived) {
                eventReceived = true;
                const newDepartment = new Department({
                    name: name,
                    uuid: departmentId.toString(),
                    ownerAddress: owner.toString()
                })
                newDepartment.save();
                res.status(200).send({
                    message: "Department created Successfully"
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
        res.status(401).send({
            message: "the server error"
        })
    }

}

const getDepartments = async (req, res) => {
    try {
        const tx = await departmentContract.getDepartments();
        const departments = tx.map((department) => {
            return [department[0].toString(), department[1]];
        });
        res.status(200).json(departments);
    } catch (error) {
        res.status(401).send({
            message: "the server error"
        })
    }


}

module.exports = {
    create, getDepartments
}