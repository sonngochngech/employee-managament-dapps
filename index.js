require("dotenv").config();
const express=require('express');
const app=express();
const port=3000;
const bodyParser = require("body-parser");
const dbConnect = require("./config");
dbConnect();
const departmentRouter=require("./routes/departmentRoute");
const employeeRouter=require("./routes/employeeRoute");

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/api/departments',departmentRouter);
app.use('/api/employees',employeeRouter);

app.listen(port,()=>{
    console.log("Server is running");
});
