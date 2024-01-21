const socket = io('http://localhost:5678');

socket.on('connect', () => onConnect());
socket.on('disconnect', () => onDisconnect());
socket.on('queueStatus', (data) => status(data));
socket.on('startGame', (data) => startGame(data));

function onConnect() { console.log('Connection established!'); }
function onDisconnect() { console.log('Connection ended!'); }
function connect() { socket.connect(); }
function disconnect() { socket.disconnect(); }

//join queue
function join(){
    console.log("Join button clicked");
    var joinButton = document.getElementById("join");
    console.log("Button state before: ", joinButton.disabled);

    socket.emit("joinQueue");
    if (joinButton) {
        joinButton.disabled = true;
        console.log("Sent join req!");
        console.log("Button state after: ", joinButton.disabled);
    }
}

//receive queue status
function status(status)
{
    console.log(status);
    document.getElementById("status").innerHTML = status;
}

function startGame(gameId){
    console.log(gameId);
    document.getElementById("status").innerHTML = "Game starting in ";
    startCountdown();
}

function startCountdown() {
    var count = 5;

    var countdownInterval = setInterval(function() {
        document.getElementById("countdown").innerHTML = " " + count;
        count--;

        if (count < 0) {
            clearInterval(countdownInterval);
            window.location.assign("http://localhost:8081/memoryGame/stats.jsp");
        }
    }, 1000);
}