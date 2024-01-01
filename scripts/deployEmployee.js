require("dotenv").config();

async function main(){
    const [deployer]=await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    const EmployeeFactory=await ethers.getContractFactory("EmployeeFactory");
    const employee=await EmployeeFactory.deploy(process.env.DEPARTMENT_ADDRESS);
    console.log("Token address:", await employee.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });