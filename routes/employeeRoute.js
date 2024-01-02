const express=require("express");
const router=express.Router();
const{
    create,getEmployees,update,deleteEmployee,verifyDepartment,getEmployeeDetail
}=require("../controller/employeeController");


router.post("/create",create);
router.get("",getEmployees);
router.post("/update",update);
router.post("/delete",deleteEmployee);
router.post("/verifyDepartment",verifyDepartment);
router.get("/:id",getEmployeeDetail);
module.exports=router