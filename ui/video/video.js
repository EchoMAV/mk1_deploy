
const confLocation = "/usr/local/echopilot/mavnetProxy/";
const scriptLocation = "/usr/local/echopilot/scripts/";
const gimbalPort = document.getElementById("gimbalPort");
//const atakHost = document.getElementById("atakHost");
//const atakPort = document.getElementById("atakPort");
//const atakIface = document.getElementById("atakIface");
//const atakBitrate = document.getElementById("atakBitrate");
const videoHost = document.getElementById("videoHost");
//const videoPort = document.getElementById("videoPort");
const videoBitrate = document.getElementById("videoBitrate");
const videoName = document.getElementById("videoName");
const myIP = document.getElementById("myIP");
const myIP2 = document.getElementById("myIP2");
const mainSection = document.getElementById("mainSection");
const noServerSection = document.getElementById("noServerSection");


// used for mav, atak, and video
const serverBitrateArray = [ "Disabled", "500", "750", "1000", "1250", "1500", "2000" ];

//start both sections hidden, and then will enable appropriate section on page init
mainSection.style.display="none";
noServerSection.style.display="none";

document.onload = InitPage();

document.getElementById("save").addEventListener("click", SaveSettings);

var qrcode;


function InitPage() {

        
    qrcode = new QRCode(document.getElementById("qrcode"), "https://data.echomav.com");

    cockpit.file(confLocation + "video.conf").read().then((content, tag) => SuccessReadFile(content))
    .catch(error => FailureReadFile(error));

    cockpit.script(scriptLocation + "cockpitScript.sh -z")
    .then(function(content) {
        myIP.innerHTML=content.trim();   
        myIP2.innerHTML=content.trim();     
    })
    .catch(error => Fail(error));  
    var serverFound = false;
    //get gst-client pipeline_list response
    //the response is JSON, and we are specifically look to make sure the "server" pipeline exists
    cockpit.script(scriptLocation + "cockpitScript.sh -g")
    .then(function(content) {
        try {
            var jsonObject = JSON.parse(content);

            for (const pipeline of jsonObject.response.nodes) { 
                if (pipeline.name === "server")
                {     
                    serverFound = true;
                    break;
                }
            }
            if (serverFound)
            {
                //enable the main contents
                mainSection.style.display="block";
                noServerSection.style.display="none";
            }
            else
            {
                //disable the main contents and alert use the video server component is not running
                mainSection.style.display="none";
                noServerSection.style.display="block";   
            }
        }
        catch (error)
        {
              //disable the main contents and alert use the video server component is not running
              mainSection.style.display="none";
              noServerSection.style.display="block";   
        }
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
           // videoPort.value = myConfig.VIDEOSERVER_PORT;
            videoName.value = myConfig.VIDEOSERVER_STREAMNAME;
            serverURL.innerHTML = "<a href='https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value + "' target='_blank'>https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value + "</a>";
            qrcode.makeCode("https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value);
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
    videoHost.value = "data.echomav.com";
    //videoPort.value = "1935";    
    videoName.value = "CHANGETOFFAID";
    gimbalPort.value = "7000";
    //platform.value = "NVID";
}

function CheckDisabled(disable){
    if(disable == "Disabled"){
        return 0;
    }
    return disable;
}

function SaveSettings() {

    var bitRate = CheckDisabled(videoBitrate.value);      
    cockpit.file(confLocation + "video.conf").replace("[Service]\n" + 
        "GIMBAL_PORT=" + gimbalPort.value + "\n" +
        "VIDEOSERVER_HOST=" + videoHost.value + "\n" +
        "VIDEOSERVER_PORT=1935" + "\n" +
        "VIDEOSERVER_BITRATE=" + bitRate + "\n" +        
        "VIDEOSERVER_STREAMNAME=" + videoName.value + "\n" +
        "PLATFORM=NVID" + "\n")
        .then(Success)
        .catch(error => Fail(new Error("Failure, settings NOT changed!")));

    //rather than restarting video service, dynamically change settings

    //stop the pipeline (can't change location without stopping anyway)
    cockpit.spawn(["gst-client", "pipeline_stop", "server"]);

    //bitrate
    var scaledBitrate = bitRate * 1000;
    //currently using x264enc which does not use scaled bitrate
    cockpit.spawn(["gst-client", "element_set", "server", "serverEncoder", "bitrate", bitRate]);

    //server location
    var serverURI="rtmp://" + videoHost.value + "/LiveApp?streamid=LiveApp/" + videoName.value;
    cockpit.spawn(["gst-client", "element_set", "server", "serverLocation", "location", serverURI]);

    //gimbal receive port (not used for antmedia)
    //cockpit.spawn(["gst-client", "element_set", "h265src", "serverReceivePort", "port", gimbalPort.value]);

    //update the server URL link
    serverURL.innerHTML = "<a href='https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value + "' target='_blank'>https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value + "</a>";

    //generate the QR Code
    qrcode.makeCode("https://" + videoHost.value + "/LiveApp/play.html?id=" + videoName.value);
    
    //start the pipeline back (unless disabled)
    if (bitRate!==0)
        cockpit.spawn(["gst-client", "pipeline_play", "server"]);    
}

function Success() {
    result.style.color = "green";
    result.innerHTML = "Success, video stream parameters updated...";
    setTimeout(() => result.innerHTML = "", 4000);
}

function Fail(error) {
    result.style.color = "red";
    result.innerHTML = error.message;
}

// Send a 'init' message.  This tells integration tests that we are ready to go
cockpit.transport.wait(function() { });

