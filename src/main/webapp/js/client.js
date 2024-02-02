let socket;
function setEvents()
{
    socket.on('connect', () => onConnect());
    socket.on('disconnect', () => onDisconnect());
    socket.on('queueStatus', (data) => status(data));
    socket.on('startGame', (data) => startGame(data));
    socket.on("receiveBoard", (board, turn, score, otherScore, win) => updateBoard(board, turn, score, otherScore, win));
    socket.on("appendMessage", (msg) => appendMessage(msg));
    socket.on("receiveActiveAndQueued", (active, queued) => setActiveAndQueued(active, queued));
    socket.on("playerLeft", (gameId, idLeft) => onPlayerLeft(gameId, idLeft));
}

function onPlayerLeft(gameId, idLeft)
{
    if (gameId == sessionStorage.getItem("gameId") && idLeft == sessionStorage.getItem("id")) alert("Your opponent left the game. You win!");
}

function getSessionData() {
    return fetch('/memoryGame/getSessionData')
        .then(response => response.json())
        .then(data => {
            console.log('Session data:', data);
            if (data) {
                return data
            } else {
                console.error("Data not found in session!")
                return null;
            }
        })
        .catch(error => {
            console.error('Error retrieving session data: ', error);
            return null
        });
}

function onConnect() {
    sessionStorage.setItem('socketId', socket.id);
}
function onDisconnect() { console.log('Connection ended!'); }

async function setup() {
    if (!sessionStorage.getItem("socketId")) {
        socket = io('http://localhost:5678');
        socket.connect();

        try {
            const data = await getSessionData();
            let id = data.id
            let username = data.username
            if (id !== null) {
                sessionStorage.setItem("id", id);
                console.log("Retrieved userId:", id);
                socket.emit("saveId", id);
                document.getElementById("join").disabled = false;
            } else {
                console.log('Id not found in session.');
            }
            if (username !== null) {
                sessionStorage.setItem("username", username);
                console.log("Retrieved username:", username);
            } else {
                console.log('Username not found in session.');
            }
        } catch (error) {
            console.log('Error in setup:', error);
        }

        console.log("First connection");
    } else {
        let socketId = sessionStorage.getItem("socketId");
        socket = io('http://localhost:5678', {query: {socketId: socketId}});
        socket.connect();
        console.log("Connection reestablished");
    }

    if (sessionStorage.getItem("id")) socket.emit("saveId", sessionStorage.getItem("id"));

    if (window.location.href == "http://localhost:8081/memoryGame/user.jsp") {
        if (sessionStorage.getItem("id")) { document.getElementById("join").disabled = false; }
        socket.emit("getActiveAndQueued");
    }

    setEvents();
}

function setActiveAndQueued(active, queue){
    if (window.location.href != "http://localhost:8081/memoryGame/user.jsp") return;
    let activeElement = document.getElementById("active");
    let queuedElement = document.getElementById("queue");
    activeElement.innerText = active;
    queuedElement.innerText = queue;
}

//join queue
function join(){
    let joinButton = document.getElementById("join");
    let userId = sessionStorage.getItem("id");
    socket.emit("joinQueue",userId);
    if (joinButton) {
        joinButton.disabled = true;
    }
}

//receive queue status
function status(status)
{
    document.getElementById("status").innerHTML = status;
}

//start game
function startGame(gameId){
    console.log(gameId);
    sessionStorage.setItem("gameId", gameId);
    window.location.assign("http://localhost:8081/memoryGame/game.jsp?gameId="+gameId);
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
    let id = sessionStorage.getItem("id");
    socket.emit("getBoard", [gameId, id]);
}

function updateBoard(board, turn, score, otherScore, win)
{
    let matrix = JSON.parse(board)
    console.log(matrix)
    console.log(score)
    console.log(otherScore)
    console.log(sessionStorage.getItem("socketId"))
    let gameBoardElement = document.getElementById("gameBoard");
    document.getElementById("score").innerHTML = score;
    document.getElementById("otherScore").innerHTML = otherScore;
    let gameBoard = ""

    for (let i = 0; i < 5; i++){
        gameBoard += `<div class="row align-items-center">`;
        for (let j = 0; j < 6; j++){
            let value = "closed";
            if (matrix[i][j].visible){ value = matrix[i][j].value }

            let cursor = "style='cursor:pointer'";
            let onclick = `onclick="playMove(` + i + `,` + j + `)"`
            if (turn != sessionStorage.getItem("id")) {
                cursor = "style='cursor:default'";
                onclick = onclick="";
            }
            gameBoard += `<div class="col"><div class="d-block mb-4 h-100"` + cursor + `>
                        <img class="img-fluid img-thumbnail" src="images/` + value + `.png" alt="Playing card" ` + onclick + `>
                        </div>
                    </div>`;
        }
        gameBoard += "</div>";
    }

    if (win != 0)
    {
        if (win == sessionStorage.getItem("id")) {
            document.getElementById("result").innerText = "Congratulations! You won.";
        }
        else {
            document.getElementById("result").innerText = "You lost! Better luck next time.";
        }
        let myModal = new bootstrap.Modal(document.getElementById('endModal'));
        myModal.show();
    }
    gameBoardElement.innerHTML = gameBoard
}

function playMove(x, y){
    console.log("played move for " + x + ", " + y);
    let gameId = sessionStorage.getItem('gameId');
    let id = sessionStorage.getItem("id")
    socket.emit("playMove", [gameId, id, x, y]);
}

function sendMessage(){
    let input = document.getElementById("chatInput");
    if (input.value.trim() == "") return;
    let text = "<b>" + sessionStorage.getItem("username") + ":</b> " + input.value;
    input.value = "";
    input.focus();
    let gameId = sessionStorage.getItem("gameId");
    socket.emit("sendMessage", [gameId, text])
    console.log("Message sent!");
}

function appendMessage(msg){
    console.log(msg)
    let container = document.getElementById("chat");
    let msgDiv = document.createElement("div");
    msgDiv.innerHTML = msg;
    container.append(msgDiv);
    container.scrollTo({
        top: container.scrollHeight,
        behavior: 'smooth'
    });
    console.log("Message appended!");
}