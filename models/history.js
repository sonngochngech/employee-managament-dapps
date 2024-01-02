const mongoose=require("mongoose");

const HistorySchema=new mongoose.Schema(
    {

        tx:{
            type:String,
            unique: true,
            required: true
        },

        description:{
            type:String,
        },
        creatorAddress:{
            type:String,
        }


    },{
        timestamps:true
    }
)

module.exports=mongoose.models.History||mongoose.model("History",HistorySchema);