<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>問題一覧 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;500;700&display=swap">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #f4f7f9; overflow: hidden; color: #333;
        }

        /* 背景：静かな波紋アニメーション */
        #canvas { position: fixed; top: 0; left: 0; z-index: -1; background: linear-gradient(180deg, #fff 0%, #e3f2fd 100%); }

        .container {
            position: relative;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(12px);
            padding: 45px;
            border-radius: 35px;
            width: 95%;
            max-width: 800px;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.6);
            z-index: 10;
        }

        /* スクロールバー */
        .container::-webkit-scrollbar { width: 5px; }
        .container::-webkit-scrollbar-thumb { background: rgba(0, 122, 255, 0.15); border-radius: 10px; }

        .header-area {
            display: flex; justify-content: space-between; align-items: flex-end;
            margin-bottom: 40px; border-bottom: 2px solid #f0f4f8; padding-bottom: 20px;
        }

        h2 { font-weight: 700; font-size: 1.5rem; color: #2c3e50; letter-spacing: 1px; }
        .playlist-id { font-size: 0.8rem; color: #95a5a6; font-weight: 400; margin-left: 10px; }

        .question-card {
            background: #fff;
            padding: 25px;
            border-radius: 20px;
            margin-bottom: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
            border: 1px solid transparent;
            animation: slideIn 0.5s ease forwards;
            opacity: 0;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .question-card:hover {
            transform: scale(1.01);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.02);
            border-color: rgba(0, 122, 255, 0.1);
        }

        .q-info { flex: 1; padding-right: 20px; }
        .q-title { font-size: 1.1rem; font-weight: 700; color: #34495e; display: block; margin-bottom: 6px; }
        .q-content { font-size: 0.85rem; color: #7f8c8d; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }

        .action-btns { display: flex; gap: 12px; align-items: center; }

        /* ボタンデザイン */
        .btn-edit {
            color: #007aff !important; text-decoration: none; font-size: 0.9rem; font-weight: 700;
            padding: 8px 18px; border-radius: 50px; background: rgba(0, 122, 255, 0.05);
            transition: 0.3s; display: inline-flex; align-items: center; gap: 5px;
        }
        .btn-edit:hover { background: #007aff; color: #fff !important; }

        .btn-delete {
            background: transparent; border: none; color: #e74c3c; cursor: pointer;
            font-size: 1.2rem; padding: 8px; transition: 0.3s; display: flex; align-items: center;
        }
        .btn-delete:hover { color: #c0392b; transform: rotate(10deg); }

        .footer { text-align: center; margin-top: 40px; }
        .btn-back { color: #95a5a6; text-decoration: none; font-size: 0.9rem; transition: 0.3s; display: inline-flex; align-items: center; gap: 5px; }
        .btn-back:hover { color: #34495e; }

    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <div class="header-area">
            <h2>プレイリスト詳細 <span class="playlist-id">ID: ${playlistId}</span></h2>
        </div>
        
        <div class="list-wrapper">
            <c:forEach var="q" items="${questions}" varStatus="status">
                <div class="question-card" style="animation-delay: ${status.index * 0.08}s">
                    <div class="q-info">
                        <span class="q-title"><c:out value="${q.title}" /></span>
                        <p class="q-content"><c:out value="${q.content}" /></p>
                    </div>
                    
                    <div class="action-btns">
                        <a href="${pageContext.request.contextPath}/view/EditQuestionServlet?id=${q.id}" class="btn-edit">
                            <i class='bx bx-edit-alt'></i> 編集
                        </a>

                        <form action="${pageContext.request.contextPath}/view/PlaylistDetailServlet" method="POST" onsubmit="return confirm('この問題を削除しますか？');" style="margin: 0;">
                            <input type="hidden" name="action" value="deleteQuestion">
                            <input type="hidden" name="questionId" value="${q.id}">
                            <input type="hidden" name="playlistId" value="${playlistId}">
                            <button type="submit" class="btn-delete" title="削除">
                                <i class='bx bx-trash'></i>
                            </button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <div class="footer">
            <a href="${pageContext.request.contextPath}/view/MyQuestionsServlet" class="btn-back">
                <i class='bx bx-arrow-back'></i> プレイリスト一覧に戻る
            </a>
        </div>
    </div>

    <script>
        /** 水面の静かな波紋（JSPエラー回避版） **/
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let circles = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        class Circle {
            constructor() { this.init(); }
            init() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.r = Math.random() * 20;
                this.opacity = Math.random() * 0.5 + 0.1;
                this.speed = Math.random() * 0.3 + 0.1;
            }
            draw() {
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
                ctx.strokeStyle = 'rgba(0, 122, 255, ' + (this.opacity * 0.1) + ')';
                ctx.lineWidth = 1;
                ctx.stroke();
            }
            update() {
                this.r += this.speed;
                this.opacity -= 0.001;
                if (this.opacity <= 0) this.init();
            }
        }

        for (let i = 0; i < 20; i++) circles.push(new Circle());

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            circles.forEach(c => { c.update(); c.draw(); });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>