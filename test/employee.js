// DepartmentFactory.test.js
const { expect } = require("chai");

describe("EmployeeFactory", function () {
    it("create new employee", async function () {

        const employee=await ethers.deployContract("EmployeeFactory");

        const result=await employee.generateEmployee("hello","0123456789","");
        const newResult=await  department.getDepartments();
        console.log(newResult);
        expect(true);

    });
});
