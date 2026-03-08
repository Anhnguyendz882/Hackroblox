const express = require("express")
const fs = require("fs")
const fetch = require("node-fetch")
const bodyParser = require("body-parser")

const app = express()

app.use(bodyParser.json())
app.use(express.static("public"))

const DISCORD_WEBHOOK = "YOUR_WEBHOOK"

function loadDB(){
return JSON.parse(fs.readFileSync("keys.json"))
}

function saveDB(db){
fs.writeFileSync("keys.json",JSON.stringify(db,null,2))
}

app.get("/api/check",(req,res)=>{

let key = req.query.key
let name = req.query.name

let db = loadDB()

if(!db[key]) return res.send("invalid")

let data = db[key]

if(data.name !== name)
return res.send("wrong_name")

if(Date.now() > data.expire){

fetch(DISCORD_WEBHOOK,{
method:"POST",
headers:{'Content-Type':'application/json'},
body:JSON.stringify({
content:`Key ${key} da het han`
})
})

return res.send("expired")
}

res.send("valid")

})

app.post("/api/create",(req,res)=>{

let name = req.body.name
let days = req.body.days

let db = loadDB()

let expire = Date.now() + days*86400000

db[name] = {
name:name,
expire:expire
}

saveDB(db)

res.json({status:"created"})
})

app.get("/api/keys",(req,res)=>{
res.json(loadDB())
})

app.listen(3000,()=>{
console.log("Server running")
})
