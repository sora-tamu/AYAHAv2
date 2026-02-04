<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>タイムライン - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: sans-serif; background: #050510; color: #fff; display: flex; justify-content: center; }
        .feed { width: 100%; max-width: 600px; border-left: 1px solid #333; border-right: 1px solid #333; min-height: 100vh; background: rgba(15,23,42,0.9); }
        
        /* ヘッダーのスタイル調整 */
        .header { padding: 15px; border-bottom: 1px solid #333; position: sticky; top: 0; background: rgba(15,23,42,0.95); z-index: 10; display: flex; align-items: center; gap: 15px; }
        .back-to-main { color: #fff; text-decoration: none; font-size: 1.5rem; display: flex; align-items: center; transition: 0.2s; }
        .back-to-main:hover { color: #1d9bf0; }
        
        .post-box { padding: 15px; border-bottom: 8px solid #1e293b; }
        textarea { width: 100%; background: transparent; border: none; color: #fff; font-size: 1.1rem; outline: none; resize: none; min-height: 80px; }
        .post-btn { background: #1d9bf0; color: #fff; border: none; padding: 8px 20px; border-radius: 20px; font-weight: bold; cursor: pointer; }
        .post-card { padding: 15px; border-bottom: 1px solid #333; display: flex; gap: 12px; }
        .post-img { width: 100%; border-radius: 12px; margin-top: 10px; border: 1px solid #333; }
        .pl-card { background: rgba(29, 155, 240, 0.1); border: 1px solid #1d9bf0; border-radius: 12px; padding: 12px; margin-top: 10px; cursor: pointer; }
        .like-btn { cursor: pointer; display: flex; align-items: center; gap: 5px; color: #64748b; margin-top: 10px; transition: 0.2s; width: fit-content; }
        .liked { color: #f43f5e; }
        .liked i { animation: heart-pop 0.3s ease-out; }
        @keyframes heart-pop { 0% { transform: scale(1); } 50% { transform: scale(1.3); } 100% { transform: scale(1); } }
        #preview-container { margin-top: 10px; display: none; position: relative; }
        #img-preview { width: 100%; border-radius: 12px; max-height: 300px; object-fit: cover; }
        .cancel-img { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.6); border-radius: 50%; width: 25px; height: 25px; display: flex; align-items: center; justify-content: center; cursor: pointer; }
    </style>
</head>
<body>
    <div class="feed">
        <div class="header">
            <a href="main.jsp" class="back-to-main" title="メインメニューに戻る">
                <i class='bx bx-chevron-left'></i>
            </a>
            <strong style="flex: 1; font-size: 1.2rem;">ホーム</strong>
            <a href="MyPageServlet" style="color:#1d9bf0; text-decoration:none; display: flex; align-items: center; gap: 4px;">
                <i class='bx bx-user-circle' style="font-size: 1.4rem;"></i> マイページ
            </a>
        </div>
        
        <div class="post-box">
            <form action="TimelineServlet" method="POST" enctype="multipart/form-data">
                <textarea name="description" placeholder="いまどうしてる？" required></textarea>
                
                <div id="preview-container">
                    <div class="cancel-img" onclick="clearImage()"><i class='bx bx-x'></i></div>
                    <img id="img-preview" src="">
                </div>

                <div style="margin: 10px 0;">
                    <input type="text" name="name" placeholder="プレイリストを紐付ける（任意）" style="width: 100%; background: rgba(255,255,255,0.05); color: #fff; border: 1px solid #333; padding: 8px; border-radius: 8px;">
                </div>
                
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <label style="color:#1d9bf0; cursor:pointer;">
                        <i class='bx bx-image-add'></i> 画像
                        <input type="file" name="image" id="image-input" style="display:none;" accept="image/*" onchange="handlePreview(this)">
                    </label>
                    <button type="submit" class="post-btn">投稿する</button>
                </div>
            </form>
        </div>

        <c:forEach var="p" items="${timeline}">
            <div class="post-card">
                <div style="width:48px; height:48px; background:#334155; border-radius:50%; display:flex; align-items:center; justify-content:center; flex-shrink: 0;"><i class='bx bxs-user'></i></div>
                <div style="flex:1;">
                    <div style="font-weight:bold;">
                        <c:out value="${p.userName}" /> 
                        <span style="color:#64748b; font-weight:normal;">@user_${p.userId}</span>
                    </div>
                    <div style="margin-top:5px; white-space: pre-wrap;"><c:out value="${p.description}" /></div>
                    
                    <c:if test="${not empty p.imagePath}">
                        <img src="${pageContext.request.contextPath}/uploads/${p.imagePath}" class="post-img">
                    </c:if>

                    <c:if test="${not empty p.name && p.name != ''}">
                        <div class="pl-card" onclick="location.href='StartPlaylistServlet?id=${p.id}'">
                            <i class='bx bx-list-ul'></i> <strong><c:out value="${p.name}" /></strong>
                            <div style="font-size: 0.8rem; color: #1d9bf0; margin-top: 4px;">この問題を解く</div>
                        </div>
                    </c:if>

                    <div class="like-btn" onclick="ajaxLike(${p.id}, this)">
                        <i class='bx ${p.bookmarkCount > 0 ? "bxs-heart liked" : "bx-heart"}'></i> 
                        <span class="count">${p.bookmarkCount}</span>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <script>
    function handlePreview(input) {
        const container = document.getElementById('preview-container');
        const preview = document.getElementById('img-preview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = e => { preview.src = e.target.result; container.style.display = 'block'; };
            reader.readAsDataURL(input.files[0]);
        }
    }
    function clearImage() {
        document.getElementById('image-input').value = "";
        document.getElementById('preview-container').style.display = 'none';
    }
    function ajaxLike(id, element) {
        fetch('LikeServlet?id=' + id)
            .then(res => res.json())
            .then(data => {
                element.querySelector('.count').innerText = data.newCount;
                const icon = element.querySelector('i');
                if(data.isLiked) { element.classList.add('liked'); icon.className = 'bx bxs-heart'; }
                else { element.classList.remove('liked'); icon.className = 'bx bx-heart'; }
            });
    }
    </script>
</body>
</html>