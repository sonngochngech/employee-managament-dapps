require("dotenv").config();

async function main(){
    const Employee= await  ethers.getContractFactory("EmployeeFactory");
    const contract=Employee.attach(process.env.EMPLOYEE_ADDRESS);
    const result = await contract. generateEmployee("hongsonss","123",[61246271457571n],0,"Manager");
    const vwresult = await contract. generateEmployee("sss","1234",[61246271457571n],0,"Employee");
    console.log(result);
}
async function update(){
    const Employee= await  ethers.getContractFactory("EmployeeFactory");
    const contract=Employee.attach(process.env.EMPLOYEE_ADDRESS);
    // const result = await contract. generateEmployee("hongsonss","123",[61246271457571n],0,"Manager");
    const vwresult = await contract. updateEmployee(8394501788582848n,"","",[],5204035803436040n,"");

}
async function getEmployees(){
    const Employee= await  ethers.getContractFactory("EmployeeFactory");
    const contract=Employee.attach(process.env.EMPLOYEE_ADDRESS);
    const result = await contract.getEmployees();

    console.log(result);
}
async function deletef(){
    const Employee= await  ethers.getContractFactory("EmployeeFactory");
    const contract=Employee.attach(process.env.EMPLOYEE_ADDRESS);
    // const result = await contract. generateEmployee("hongsonss","123",[61246271457571n],0,"Manager");
    const vwresult = await contract.deleteEmployee( 8394501788582848n);

}
async function verify(){
    const Employee= await  ethers.getContractFactory("EmployeeFactory");
    const contract=Employee.attach(process.env.EMPLOYEE_ADDRESS);
    // const result = await contract. generateEmployee("hongsonss","123",[61246271457571n],0,"Manager");
    const vwresult = await contract.verifyDepartment([61246271457571n]);

}

verify()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });