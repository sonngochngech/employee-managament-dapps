const mongoose=require("mongoose");

const DepartmentSchema=new mongoose.Schema(
    {

        uuid:{
            type:String,
            unique:true,
            required:true
        },
        name:{
            type:String,
            unique:true,
            required:true
        },
        ownerAddress:{
            type:String,
        }


    },{
        timestamps:true
    }
)

module.exports=mongoose.models.Department||mongoose.model("Department",DepartmentSchema);
module.exports.DepartmentSchema=DepartmentSchema;