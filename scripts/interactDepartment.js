require("dotenv").config();

async function main(){
    const Department= await  ethers.getContractFactory("DepartmentFactory");
    const contract=Department.attach(process.env.DEPARTMENT_ADDRESS);
    await contract.createDepartment("1");
    await contract.createDepartment("2");
    await contract.createDepartment("3");
    await contract.createDepartment("4");
    await contract.createDepartment("5");
    await contract.createDepartment("6");


}
async function getDepartments(){
    const Department= await  ethers.getContractFactory("DepartmentFactory");
    const contract=Department.attach(process.env.DEPARTMENT_ADDRESS);
    const result=await contract.getDepartments();
    console.log(result);
}
getDepartments()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });