async function main(){
    const [deployer]=await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    const department=await ethers.deployContract("DepartmentFactory");
    console.log("Token address:", await department.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });