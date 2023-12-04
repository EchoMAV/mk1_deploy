const confLocation = "/usr/local/echopilot/mavnetProxy/";
const scriptLocation = "/usr/local/echopilot/scripts/";
const gimbalPort = document.getElementById("gimbalPort");
//const atakHost = document.getElementById("atakHost");
//const atakPort = document.getElementById("atakPort");
//const atakIface = document.getElementById("atakIface");
//const atakBitrate = document.getElementById("atakBitrate");
const videoHost = document.getElementById("videoHost");
const videoPort = document.getElementById("videoPort");
const videoBitrate = document.getElementById("videoBitrate");
const videoName = document.getElementById("videoName");
const myIP = document.getElementById("myIP");
const myIP2 = document.getElementById("myIP2");

// used for mav, atak, and video
const serverBitrateArray = [ "Disabled", "500", "750", "1000", "1250", "1500", "2000" ];

document.onload = InitPage();

document.getElementById("save").addEventListener("click", SaveSettings);

function InitPage() {
    cockpit.file(confLocation + "video.conf").read().then((content, tag) => SuccessReadFile(content))
    .catch(error => FailureReadFile(error));

    cockpit.script(scriptLocation + "cockpitScript.sh -z")
    .then(function(content) {
        myIP.innerHTML=content.trim();   
        myIP2.innerHTML=content.trim();     
    })
    .catch(error => Fail(error));  
}

function SuccessReadFile(content) {

    try{

        var lines = content.split('\n');
        var myConfig = {};
        for(var line = 0; line < lines.length; line++){
            
            if (lines[line].trim().startsWith("#") === false)  //check if this line in the config file is not commented out
            {
                var currentline = lines[line].split('=');
                
                if (currentline.length === 2)            
                    myConfig[currentline[0].trim().replace(/["]/g, "")] = currentline[1].trim().replace(/["]/g, "");  
            }          
        }       
        var splitResult = content.split("\n");
        
        if(splitResult.length > 0) {
            gimbalPort.value = myConfig.GIMBAL_PORT;
            videoHost.value = myConfig.VIDEOSERVER_HOST;
            videoPort.value = myConfig.VIDEOSERVER_PORT;
            videoName.value = myConfig.VIDEOSERVER_STREAMNAME;
            AddDropDown(videoBitrate, serverBitrateArray, myConfig.VIDEOSERVER_BITRATE);
        }
        else{
            FailureReadFile(new Error("Too few parameters in file"));
        }
    }
    catch(e){
        FailureReadFile(e);
    }
}

function AddPathToDeviceFile(incomingArray){
    for(let t = 0; t < incomingArray.length; t++){
        incomingArray[t] = "/dev/" + incomingArray[t];
    }
    return incomingArray;
}

function AddDropDown(box, theArray, defaultValue){
    try{
        for(let t = 0; t < theArray.length; t++){
            var option = document.createElement("option");
            option.text = theArray[t];
            box.add(option);
            if(defaultValue == option.text){
                box.value = option.text;
            }
        }
    }
    catch(e){
        Fail(e)
    }
}

function FailureReadFile(error) {
    // Display error message
    output.innerHTML = "Error : " + error.message;

    // Defaults
    videoHost.value = "video.echomav.com";
    videoPort.value = "1935";    
    videoName.value = "CHANGETOFFAID";
    gimbalPort.value = "7000";
    platform.value = "NVID";
}

function CheckDisabled(disable){
    if(disable == "Disabled"){
        return "0";
    }
    return disable;
}

function SaveSettings() {

    var bitRate = CheckDisabled(videoBitrate.value);      
    cockpit.file(confLocation + "video.conf").replace("[Service]\n" + 
        "GIMBAL_PORT=" + gimbalPort.value + "\n" +
        "VIDEOSERVER_HOST=" + videoHost.value + "\n" +
        "VIDEOSERVER_PORT=" + videoPort.value + "\n" +
        "VIDEOSERVER_BITRATE=" + bitRate + "\n" +        
        "VIDEOSERVER_STREAMNAME=" + videoName.value + "\n" +
        "PLATFORM=NVID" + "\n")
        .then(Success)
        .catch(error => Fail(new Error("Failure, settings NOT changed!")));

    cockpit.spawn(["systemctl", "restart", "video"]);
    cockpit.spawn(["systemctl", "restart", "mavnetProxy"]);
}

function Success() {
    result.style.color = "green";
    result.innerHTML = "Success, restarting Video Services...";
    setTimeout(() => result.innerHTML = "", 4000);
}

function Fail(error) {
    result.style.color = "red";
    result.innerHTML = error.message;
}

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() { });