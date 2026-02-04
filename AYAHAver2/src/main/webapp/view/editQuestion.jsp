<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>問題の編集 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;500;700&display=swap">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background-color: #f9fbf9; overflow: hidden; color: #333;
        }

        /* 背景：植物が揺れるような穏やかなアニメーション用 */
        #canvas { position: fixed; top: 0; left: 0; z-index: -1; background: linear-gradient(135deg, #fff 0%, #f1f8e9 100%); }

        .container {
            position: relative;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(15px);
            padding: 40px 50px;
            border-radius: 40px;
            width: 95%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.4);
            z-index: 10;
            animation: containerFade 0.6s ease-out;
        }

        @keyframes containerFade {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* スクロールバー */
        .container::-webkit-scrollbar { width: 4px; }
        .container::-webkit-scrollbar-thumb { background: #c5e1a5; border-radius: 10px; }

        h1 {
            font-size: 1.4rem; font-weight: 700; color: #2e7d32;
            margin-bottom: 30px; text-align: center; letter-spacing: 1px;
        }

        .form-group { margin-bottom: 25px; text-align: left; }
        
        label {
            display: block; font-size: 0.85rem; font-weight: 700;
            color: #666; margin-bottom: 8px; margin-left: 5px;
        }

        /* 入力エリア：洗練されたミニマルデザイン */
        .input-minimal, textarea {
            width: 100%; padding: 12px 15px;
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid #e0e0e0; border-radius: 12px;
            font-size: 1rem; color: #444; font-family: inherit;
            transition: 0.3s;
        }
        .input-minimal:focus, textarea:focus {
            outline: none; border-color: #81c784;
            box-shadow: 0 5px 15px rgba(129, 199, 132, 0.1);
            background: #fff;
        }

        textarea { resize: none; line-height: 1.6; }

        /* チェックボックスのカスタム */
        .checkbox-container {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.95rem; color: #555; cursor: pointer;
            margin-top: 10px;
        }
        input[type="checkbox"] { width: 18px; height: 18px; accent-color: #4caf50; }

        /* 保存ボタン */
        .btn-success {
            width: 100%; padding: 18px; margin-top: 10px;
            background: #2e7d32; color: #fff; border: none;
            border-radius: 50px; font-weight: 700; font-size: 1rem;
            cursor: pointer; transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            letter-spacing: 2px;
        }
        .btn-success:hover {
            background: #1b5e20; transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(46, 125, 50, 0.2);
        }

        .btn-back {
            display: block; text-align: center; margin-top: 25px;
            color: #999; text-decoration: none; font-size: 0.9rem;
            transition: 0.3s;
        }
        .btn-back:hover { color: #666; }

    </style>
    <script>
        let isSubmitted = false;
        function validateSubmit() {
            if (isSubmitted) return false;
            isSubmitted = true;
            const btn = document.getElementById("updateBtn");
            btn.innerText = "更新内容を保存中...";
            btn.style.opacity = "0.7";
            return true;
        }
    </script>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <h1><i class='bx bx-edit'></i> 問題の編集</h1>
        
        <form action="${pageContext.request.contextPath}/view/UpdateQuestionServlet" method="POST" onsubmit="return validateSubmit()">
            <input type="hidden" name="id" value="<c:out value='${question.id}' />">

            <div class="form-group">
                <label>タイトル</label>
                <input type="text" name="title" value="<c:out value='${question.title}' />" required class="input-minimal" placeholder="問題のタイトルを入力">
            </div>

            <div class="form-group">
                <label>問題内容</label>
                <textarea name="content" required class="input-minimal" style="height: 120px;" placeholder="問題の本文を入力"><c:out value="${question.content}" /></textarea>
            </div>

            <div class="form-group">
                <label>正解</label>
                <input type="text" name="answer" value="<c:out value='${question.answer}' />" required class="input-minimal" placeholder="答えを入力">
            </div>

            <div class="form-group">
                <label>解説 (任意)</label>
                <textarea name="explanation" class="input-minimal" style="height: 100px;" placeholder="解説がある場合は入力してください"><c:out value="${question.explanation}" /></textarea>
            </div>

            <div class="form-group">
                <label>タグ (カンマ区切り)</label>
                <input type="text" name="tags" value="<c:out value='${question.tags}' />" class="input-minimal" placeholder="例: 歴史, 江戸時代">
            </div>

            <div class="form-group">
                <label class="checkbox-container">
                    <input type="checkbox" name="isPublic" value="1" ${question.isPublic ? 'checked' : ''}>
                    この問題を公開する
                </label>
            </div>

            <button type="submit" id="updateBtn" class="btn-success">更新を保存する</button>
        </form>
        
        <a href="${pageContext.request.contextPath}/view/MyQuestionsServlet" class="btn-back">
            <i class='bx bx-x'></i> キャンセルして戻る
        </a>
    </div>

    <script>
        /** 穏やかな植物の揺らぎアニメーション **/
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let leaves = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        class Leaf {
            constructor() { this.init(); }
            init() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 40 + 20;
                this.angle = Math.random() * Math.PI * 2;
                this.speed = 0.005 + Math.random() * 0.01;
                this.color = 'rgba(200, 230, 201, ' + (Math.random() * 0.2 + 0.1) + ')';
            }
            draw() {
                ctx.save();
                ctx.translate(this.x, this.y);
                ctx.rotate(this.angle + Math.sin(Date.now() * 0.001) * 0.2);
                ctx.fillStyle = this.color;
                // 葉っぱのような楕円を描画
                ctx.beginPath();
                ctx.ellipse(0, 0, this.size, this.size / 2.5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
            update() {
                this.y -= this.speed * 20;
                this.x += Math.sin(this.y * 0.01);
                if (this.y < -50) this.y = canvas.height + 50;
            }
        }

        for (let i = 0; i < 15; i++) leaves.push(new Leaf());

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            leaves.forEach(l => { l.update(); l.draw(); });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>