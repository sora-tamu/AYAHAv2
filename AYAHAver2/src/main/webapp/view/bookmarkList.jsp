<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>お気に入り一覧 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
    <style>
        /* CSSセクションは変更ありませんが、念のため含めています */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }

        body {
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #050510; 
            background-image: url('${pageContext.request.contextPath}/images/bg-galaxy.jpg');
            background-repeat: no-repeat; background-position: center center;
            background-size: cover; background-attachment: fixed;
            overflow-x: hidden; color: #fff;
        }

        #canvas { position: fixed; top: 0; left: 0; z-index: -1; }

        .container {
            position: relative;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            padding: 40px;
            border-radius: 30px;
            width: 90%;
            max-width: 700px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h2 {
            text-align: center;
            font-weight: 300;
            letter-spacing: 3px;
            margin-bottom: 30px;
            text-shadow: 0 0 15px rgba(255, 77, 148, 0.6);
            color: #fff;
        }

        .item-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.08);
            padding: 20px 25px;
            border-radius: 20px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        .item-card:hover {
            background: rgba(255, 255, 255, 0.08);
            transform: scale(1.02);
            border-color: rgba(255, 77, 148, 0.4);
        }

        .playlist-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: #eee;
            display: block;
            margin-bottom: 5px;
        }

        .pixel-glass-btn {
            position: relative;
            display: inline-flex;
            align-items: center;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 700;
            overflow: hidden;
            transition: 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 4px 0 rgba(0, 0, 0, 0.3);
        }

        .pixel-glass-btn:hover {
            background: #fff;
            color: #000;
            transform: translateY(-2px);
            box-shadow: 0 6px 0 rgba(0, 0, 0, 0.3);
        }

        .pixel-glass-btn:active {
            transform: translateY(2px);
            box-shadow: 0 2px 0 rgba(0, 0, 0, 0.3);
        }

        .pixel-container {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            pointer-events: none; overflow: hidden;
        }
        .pixel {
            position: absolute; width: 8px; height: 8px;
            background: rgba(255,255,255,0.8); opacity: 0;
            transition: transform 0.6s ease-out, opacity 0.6s ease-out;
        }
        .pixel-glass-btn:hover .pixel {
            opacity: 1;
            transform: translate(var(--tx), var(--ty));
        }

        .btn-remove {
            color: rgba(255, 77, 148, 0.6);
            text-decoration: none;
            font-size: 0.9rem;
            margin-left: 15px;
            transition: 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .btn-remove:hover {
            color: #ff4d94;
            text-shadow: 0 0 10px rgba(255, 77, 148, 0.5);
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 30px;
            color: rgba(255, 255, 255, 0.4);
            text-decoration: none;
            font-size: 0.9rem;
            transition: 0.3s;
            padding: 10px 20px;
            border-radius: 50px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .back-link:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.05);
            border-color: rgba(255, 77, 148, 0.5);
        }

        .empty-msg {
            text-align: center;
            opacity: 0.5;
            padding: 40px 0;
            font-style: italic;
        }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <h2><i class='bx bxs-heart' style="color: #ff4d94;"></i> お気に入り問題一覧</h2>
        
        <c:choose>
            <c:when test="${empty bookmarkedList}">
                <div class="empty-msg">
                    <p>お気に入りはまだありません。</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="p" items="${bookmarkedList}">
                    <div class="item-card">
                        <div>
                            <span class="playlist-name"><c:out value="${p.name}" /></span>
                            <span style="font-size: 0.8rem; opacity: 0.4;">Playlist ID: #<c:out value="${p.id}" /></span>
                        </div>
                        <div style="display: flex; align-items: center;">
                            <a href="StartPlaylistServlet?id=${p.id}" class="pixel-glass-btn">
                                <div class="pixel-container"></div>
                                <i class='bx bx-play' style="font-size: 1.2rem;"></i> 解く
                            </a>
                            <a href="BookmarkServlet?questionId=${p.id}&action=remove" class="btn-remove">
                                <i class='bx bx-trash'></i>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <div style="text-align: center;">
            <a href="main.jsp" class="back-link">
                <i class='bx bx-arrow-back'></i> メインメニュー
            </a>
        </div>
    </div>

    <script>
        /** 背景の星空アニメーション **/
        var canvas = document.getElementById('canvas');
        var ctx = canvas.getContext('2d');
        var stars = [];
        function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
        window.addEventListener('resize', resize);
        resize();

        function Star() {
            this.x = Math.random() * canvas.width;
            this.y = Math.random() * canvas.height;
            this.size = Math.random() * 1.5;
            this.speed = Math.random() * 0.05;
            this.brightness = Math.random();
        }
        Star.prototype.draw = function() {
            // 文字列結合による回避
            ctx.fillStyle = 'rgba(255, 255, 255, ' + this.brightness + ')';
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
        };
        Star.prototype.update = function() {
            this.y -= this.speed;
            if (this.y < 0) this.y = canvas.height;
            this.brightness += (Math.random() - 0.5) * 0.05;
            if(this.brightness < 0.1) this.brightness = 0.1;
            if(this.brightness > 1) this.brightness = 1;
        };

        for (var i = 0; i < 100; i++) stars.push(new Star());
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            for (var i = 0; i < stars.length; i++) {
                stars[i].update();
                stars[i].draw();
            }
            requestAnimationFrame(animate);
        }
        animate();

        /** ピクセル生成スクリプト **/
        function initPixels() {
            var btns = document.querySelectorAll('.pixel-glass-btn');
            btns.forEach(function(btn) {
                var container = btn.querySelector('.pixel-container');
                var w = btn.offsetWidth, h = btn.offsetHeight;
                var pixSize = 8;
                for (var i = 0; i < Math.floor(w / pixSize); i++) {
                    for (var j = 0; j < Math.floor(h / pixSize); j++) {
                        var pixel = document.createElement('div');
                        pixel.className = 'pixel';
                        pixel.style.left = (i * pixSize) + 'px';
                        pixel.style.top = (j * pixSize) + 'px';
                        pixel.style.transitionDelay = (Math.random() * 0.3) + 's';
                        
                        var tx = (Math.random() - 0.5) * 60 + 'px';
                        var ty = (Math.random() - 0.5) * 60 + 'px';
                        pixel.style.setProperty('--tx', tx);
                        pixel.style.setProperty('--ty', ty);
                        
                        container.appendChild(pixel);
                    }
                }
            });
        }
        window.addEventListener('DOMContentLoaded', initPixels);
    </script>
</body>
</html>