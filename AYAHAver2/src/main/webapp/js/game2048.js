/**
 * 2048 Game Logic (Enhanced with Animations & Game Over)
 */
let g2048Grid = [];
let g2048Score = 0;
let g2048MergedIndices = []; // 合体したタイルの位置を一時保存
const g2048Size = 4;

function init2048() {
    g2048Grid = Array(g2048Size * g2048Size).fill(0);
    g2048Score = 0;
    g2048MergedIndices = [];
    const scoreBox = document.getElementById("g2048-score");
    if(scoreBox) scoreBox.innerText = g2048Score;
    
    // ゲームオーバー表示があれば消す
    const overDisplay = document.querySelector(".g2048-gameover");
    if(overDisplay) overDisplay.remove();

    addRandomTile();
    addRandomTile();
    draw2048Grid();
}

function draw2048Grid() {
    const container = document.getElementById("g2048-grid");
    if(!container) return;

    container.innerHTML = "";
    g2048Grid.forEach((val, i) => {
        const tile = document.createElement("div");
        tile.className = "g2048-tile";
        if (val !== 0) {
            tile.innerText = val;
            tile.setAttribute("data-val", val);
            
            // 合体したタイルにアニメーション用クラスを付与
            if (g2048MergedIndices.includes(i)) {
                tile.classList.add("tile-merged");
            }
        }
        container.appendChild(tile);
    });
}

function addRandomTile() {
    let emptyIndices = g2048Grid.map((v, i) => v === 0 ? i : null).filter(v => v !== null);
    if (emptyIndices.length > 0) {
        let randomIdx = emptyIndices[Math.floor(Math.random() * emptyIndices.length)];
        g2048Grid[randomIdx] = Math.random() < 0.9 ? 2 : 4;
    }
}

/**
 * スライド処理の共通化
 * 合体が発生した位置(localIndex)を追跡するように強化
 */
function slide2048(row) {
    let arr = row.filter(v => v !== 0);
    let mergedInfo = Array(g2048Size).fill(false);
    
    for (let i = 0; i < arr.length - 1; i++) {
        if (arr[i] === arr[i + 1]) {
            arr[i] *= 2;
            g2048Score += arr[i];
            arr.splice(i + 1, 1);
            mergedInfo[i] = true; // この位置で合体が発生
        }
    }
    while (arr.length < g2048Size) arr.push(0);
    return { newRow: arr, mergedInfo: mergedInfo };
}

function moveLeft() {
    let changed = false;
    g2048MergedIndices = [];
    for (let i = 0; i < g2048Size; i++) {
        let row = g2048Grid.slice(i * 4, i * 4 + 4);
        let result = slide2048(row);
        result.newRow.forEach((val, j) => {
            let idx = i * 4 + j;
            if(g2048Grid[idx] !== val) changed = true;
            g2048Grid[idx] = val;
            if(result.mergedInfo[j]) g2048MergedIndices.push(idx);
        });
    }
    return changed;
}

function moveRight() {
    let changed = false;
    g2048MergedIndices = [];
    for (let i = 0; i < g2048Size; i++) {
        let row = g2048Grid.slice(i * 4, i * 4 + 4).reverse();
        let result = slide2048(row);
        result.newRow.reverse().forEach((val, j) => {
            let idx = i * 4 + j;
            if(g2048Grid[idx] !== val) changed = true;
            g2048Grid[idx] = val;
            // 右移動なのでインデックスの計算を反転
            if(result.mergedInfo[3 - j]) g2048MergedIndices.push(idx);
        });
    }
    return changed;
}

function moveUp() {
    let changed = false;
    g2048MergedIndices = [];
    for (let j = 0; j < g2048Size; j++) {
        let col = [g2048Grid[j], g2048Grid[j+4], g2048Grid[j+8], g2048Grid[j+12]];
        let result = slide2048(col);
        result.newRow.forEach((val, i) => {
            let idx = j + i * 4;
            if(g2048Grid[idx] !== val) changed = true;
            g2048Grid[idx] = val;
            if(result.mergedInfo[i]) g2048MergedIndices.push(idx);
        });
    }
    return changed;
}

function moveDown() {
    let changed = false;
    g2048MergedIndices = [];
    for (let j = 0; j < g2048Size; j++) {
        let col = [g2048Grid[j], g2048Grid[j+4], g2048Grid[j+8], g2048Grid[j+12]].reverse();
        let result = slide2048(col);
        result.newRow.reverse().forEach((val, i) => {
            let idx = j + i * 4;
            if(g2048Grid[idx] !== val) changed = true;
            g2048Grid[idx] = val;
            if(result.mergedInfo[3 - i]) g2048MergedIndices.push(idx);
        });
    }
    return changed;
}

/**
 * 強化：ゲームオーバー判定
 */
function checkGameOver() {
    // 1. 空きマスがあれば続行
    if (g2048Grid.includes(0)) return false;

    // 2. 隣接する同じ数字があれば続行
    for (let i = 0; i < 4; i++) {
        for (let j = 0; j < 4; j++) {
            let current = g2048Grid[i * 4 + j];
            // 右隣チェック
            if (j < 3 && current === g2048Grid[i * 4 + (j + 1)]) return false;
            // 下隣チェック
            if (i < 3 && current === g2048Grid[(i + 1) * 4 + j]) return false;
        }
    }

    // どこにも動かせない
    showGameOver();
    return true;
}

function showGameOver() {
    const gridContainer = document.getElementById("g2048-grid");
    if (!gridContainer) return;

    const overDiv = document.createElement("div");
    overDiv.className = "g2048-gameover";
    overDiv.innerHTML = `
        <h2 style="font-size:2rem; margin-bottom:10px;">Game Over</h2>
        <p style="margin-bottom:20px;">Score: ${g2048Score}</p>
        <button onclick="init2048()" style="padding:10px 20px; background:#8f7a66; border:none; color:white; border-radius:5px; cursor:pointer; font-weight:bold;">Try Again</button>
    `;
    gridContainer.appendChild(overDiv);
}

// キーイベント
window.addEventListener("keydown", (e) => {
    const view = document.getElementById("view-2048");
    if (!view || !view.classList.contains("active")) return;
    
    // ゲームオーバー画面が出ている時は操作無効
    if (document.querySelector(".g2048-gameover")) return;

    let moved = false;
    if (e.key === "ArrowLeft") moved = moveLeft();
    else if (e.key === "ArrowRight") moved = moveRight();
    else if (e.key === "ArrowUp") moved = moveUp();
    else if (e.key === "ArrowDown") moved = moveDown();

    if (moved) {
        e.preventDefault();
        addRandomTile();
        draw2048Grid();
        const scoreElem = document.getElementById("g2048-score");
        if(scoreElem) scoreElem.innerText = g2048Score;
        
        // 移動・描画後にゲームオーバー判定
        setTimeout(checkGameOver, 200); 
    }
});