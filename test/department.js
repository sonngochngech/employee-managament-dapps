// DepartmentFactory.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("DepartmentFactory", function () {
    let departmentContract;
    let employeeContract;
    // beforeEach(async()=>{
    //
    //     // const employeeFactory=  ethers.getContractFactory("EmployeeFactory");
    //     // employeeContract=await employeeFactory.deploy(departmentContract.address);
    // })
    it("create new department", async function () {
          // const result=await employeeContract.verifyDepartment([1]);
        const  departmentFactory= await ethers.getContractFactory("DepartmentFactory");
        departmentContract=await  departmentFactory.deploy();
        await  departmentContract.deployed();
        console.log(departmentContract.address);
        expect(true);

    });
});
