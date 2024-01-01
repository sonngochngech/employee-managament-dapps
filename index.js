require("dotenv").config();
const express=require('express');
const app=express();
const port=3000;
const {ethers,JsonRpcProvider}=require("ethers");
const provider=new JsonRpcProvider("http://localhost:8545");
const privateKey=process.env.PERSION1_PRIVATE_KEY;
const wallet= new ethers.Wallet(privateKey,provider);
const employmentAbi=require("./artifacts/contracts/EmployeeFactory.sol/EmployeeFactory.json");
const departmentAbi=require("./artifacts/contracts/DepartmentFactory.sol/DepartmentFactory.json");
const {experimentalAddHardhatNetworkMessageTraceHook} = require("hardhat/config");
const utf8 = require('utf8');
const departmentContract=new ethers.Contract(process.env.DEPARTMENT_ADDRESS,departmentAbi.abi,wallet);
const employeeContract=new ethers.Contract(process.env.EMPLOYEE_ADDRESS,employmentAbi.abi,wallet);

app.post('/addDepartment', async(req,res)=>{
    try{
        const transaction=await departmentContract.createDepartment("zzzz");
        await transaction.wait();

        departmentContract.on("departmentCreated",(departmentId,name,owner,merkleRoot,event)=>{
            console.log(owner);
            console.log(name);
            console.log(departmentId);


        })
        res.send("OKeee nhaa");

    }catch (error){
        console.error(error);
        res.status(500).send("Errrrr");

    }
})

app.listen(port,()=>{
    console.log("Server is running");
});
