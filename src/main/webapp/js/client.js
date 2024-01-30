let socket;

function setEvents()
{
    socket.on('connect', () => onConnect());
    socket.on('disconnect', () => onDisconnect());
    socket.on('queueStatus', (data) => status(data));
    socket.on('startGame', (data) => startGame(data));
    socket.on("receiveBoard", (board) => updateBoard(board));
}

function onConnect() {
    sessionStorage.setItem('socketId', socket.id);
    console.log('Connection established!');
}
function onDisconnect() { console.log('Connection ended!'); }

function setup()
{
    if(sessionStorage.getItem("socketId") === undefined)
    {
        socket = io('http://localhost:5678');
        socket.connect();
        console.log("First connection");
    }
    else
    {
        let socketId = sessionStorage.getItem("socketId");
        socket = io('http://localhost:5678', { query: { socketId } });
        socket.connect();
        console.log("Connection reestablished");
    }

    setEvents();
}

//join queue
function join(){
    console.log("Join button clicked");
    let joinButton = document.getElementById("join");
    console.log("Button state before: ", joinButton.disabled);

    socket.emit("joinQueue");
    if (joinButton) {
        joinButton.disabled = true;
        console.log("Sent join req!");
        console.log("Button state after: ", joinButton.disabled);
    }
}

//receive queue status
function status(status){ document.getElementById("status").innerHTML = status; }

//start game
function startGame(gameId){
    console.log(gameId);
    window.location.assign("http://localhost:8081/memoryGame/game.jsp?gameId="+gameId);
    sessionStorage.setItem("gameId", gameId);
    //startCountdown(gameId);
}
function startCountdown() {
    if (sessionStorage.getItem("gameId") === undefined) return;

    document.getElementById("countdown").hidden = false;
    let count = 5;

    let countdownInterval = setInterval(function() {
        document.getElementById("countdown").innerHTML = " " + count;
        count--;

        if (count < 0) {
            clearInterval(countdownInterval);
        }
    }, 1000);
}

function getBoard() {
    setup();
    let gameId = sessionStorage.getItem('gameId');
    socket.emit("getBoard", gameId);
}

function updateBoard(board)
{
    console.log(board)
    let matrix = JSON.parse(board)

    for (let i = 0; i < matrix.length; i++) {
        for (let j = 0; j < matrix[i].length; j++) {
            console.log(matrix[i][j].value);
        }
    }

    let gameBoardElement = document.getElementById("gameBoard");

    let gameBoard = ""

    for (let i = 0; i < 5; i++){
        gameBoard += `<div class="row align-items-center">`;
        for (let j = 0; j < 6; j++){
            let value;
            if (matrix[i][j].visible){
                value = matrix[i][j].value
            }
            else{
                value = "closed"
            }
            gameBoard += `<div class="col"><a href="#" class="d-block mb-4 h-100">
                        <img class="img-fluid img-thumbnail" src="images/` + value + `.png" alt="">
                        </a>
                    </div>`;
        }
        gameBoard += "</div>";
    }

    gameBoardElement.innerHTML = gameBoard
}