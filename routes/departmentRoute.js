const express=require("express");
const router=express.Router();
const{
    create,getDepartments
}=require("../controller/departmentController");


router.post("/create",create);
router.get("",getDepartments);

module.exports=router;