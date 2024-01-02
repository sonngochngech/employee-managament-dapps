const mongoose=require("mongoose");

const {DepartmentSchema}=require("./department");
const EmployeeSchema=new mongoose.Schema(
    {

        uuid:{
            type:String,
            unique:true,
            required:true
        },
        phoneNumber:{
            type:String,
            unique:true,
            required:true
        },
        role:{
            type:String,
        },
        owner:{
            type:String,
        },
    },{
        timestamps:true
    }
)


module.exports=mongoose.models.Employee||mongoose.model("Employee",EmployeeSchema);