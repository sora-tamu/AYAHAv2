let g2048Grid = [];
let g2048Score = 0;
const g2048Size = 4;

// 初期化：ここが呼ばれないと画面が出ません
function init2048() {
    g2048Grid = Array(16).fill(0);
    g2048Score = 0;
    const scoreElement = document.getElementById("g2048-score");
    if(scoreElement) scoreElement.innerText = "0";
    
    addRandomTile();
    addRandomTile();
    draw2048Grid();
}

// 描画：HTMLの grid の中身を空にして作り直す
function draw2048Grid() {
    const container = document.getElementById("g2048-grid");
    if(!container) return;
    
    container.innerHTML = ""; // 一旦リセット
    g2048Grid.forEach(val => {
        const tile = document.createElement("div");
        tile.className = "g2048-tile";
        if (val !== 0) {
            tile.innerText = val;
            tile.setAttribute("data-val", val);
        }
        container.appendChild(tile);
    });
}

function addRandomTile() {
    let emptyIndices = [];
    g2048Grid.forEach((v, i) => { if(v === 0) emptyIndices.push(i); });
    
    if (emptyIndices.length > 0) {
        let randomIdx = emptyIndices[Math.floor(Math.random() * emptyIndices.length)];
        g2048Grid[randomIdx] = Math.random() < 0.9 ? 2 : 4;
    }
}

// 移動処理（左）
function moveLeft() {
    let changed = false;
    for (let i = 0; i < g2048Size; i++) {
        let row = g2048Grid.slice(i * 4, i * 4 + 4);
        let newRow = slide(row);
        for (let j = 0; j < 4; j++) {
            if(g2048Grid[i * 4 + j] !== newRow[j]) changed = true;
            g2048Grid[i * 4 + j] = newRow[j];
        }
    }
    return changed;
}

// 移動処理（右）
function moveRight() {
    let changed = false;
    for (let i = 0; i < g2048Size; i++) {
        let row = g2048Grid.slice(i * 4, i * 4 + 4).reverse();
        let newRow = slide(row).reverse();
        for (let j = 0; j < 4; j++) {
            if(g2048Grid[i * 4 + j] !== newRow[j]) changed = true;
            g2048Grid[i * 4 + j] = newRow[j];
        }
    }
    return changed;
}

// 移動処理（上）
function moveUp() {
    let changed = false;
    for (let j = 0; j < g2048Size; j++) {
        let col = [g2048Grid[j], g2048Grid[j+4], g2048Grid[j+8], g2048Grid[j+12]];
        let newCol = slide(col);
        for (let i = 0; i < 4; i++) {
            if(g2048Grid[j + i*4] !== newCol[i]) changed = true;
            g2048Grid[j + i*4] = newCol[i];
        }
    }
    return changed;
}

// 移動処理（下）
function moveDown() {
    let changed = false;
    for (let j = 0; j < g2048Size; j++) {
        let col = [g2048Grid[j], g2048Grid[j+4], g2048Grid[j+8], g2048Grid[j+12]].reverse();
        let newCol = slide(col).reverse();
        for (let i = 0; i < 4; i++) {
            if(g2048Grid[j + i*4] !== newCol[i]) changed = true;
            g2048Grid[j + i*4] = newCol[i];
        }
    }
    return changed;
}

function slide(row) {
    let arr = row.filter(v => v !== 0);
    for (let i = 0; i < arr.length - 1; i++) {
        if (arr[i] === arr[i + 1]) {
            arr[i] *= 2;
            g2048Score += arr[i];
            arr.splice(i + 1, 1);
        }
    }
    while (arr.length < 4) arr.push(0);
    return arr;
}

// キーイベント
window.addEventListener("keydown", (e) => {
    const view2048 = document.getElementById("view-2048");
    if (!view2048 || !view2048.classList.contains("active")) return;

    let moved = false;
    if (e.key === "ArrowLeft") moved = moveLeft();
    else if (e.key === "ArrowRight") moved = moveRight();
    else if (e.key === "ArrowUp") moved = moveUp();
    else if (e.key === "ArrowDown") moved = moveDown();

    if (moved) {
        e.preventDefault();
        addRandomTile();
        draw2048Grid();
        document.getElementById("g2048-score").innerText = g2048Score;
    }
});