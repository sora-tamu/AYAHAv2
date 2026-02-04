package controller;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // 追加
import jakarta.servlet.http.Part;

import dao.QuestionDAO;
import model.Playlist;
import model.User;
import util.DBManager;

@WebServlet("/view/TimelineServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024)
public class TimelineServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // --- ここからログインチェックの追加 ---
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        
        if (user == null) {
            // ログインしていない場合のみ、ログイン画面へ飛ばす
            response.sendRedirect("../login.jsp");
            return;
        }
        // --- チェック終了 ---

        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        
        request.setAttribute("timeline", qDAO.getAllPublicPlaylists());
        // ログイン済みの場合は、そのままタイムラインを表示
        request.getRequestDispatcher("/view/Timeline.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        
        if (user == null) { 
            response.sendRedirect("../login.jsp"); 
            return; 
        }

        // 1. パラメータ取得
        String description = request.getParameter("description");
        String name = request.getParameter("name");

        // 2. 画像処理
        Part part = request.getPart("image");
        String fileName = null;
        if (part != null && part.getSize() > 0) {
            fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName();
            String path = getServletContext().getRealPath("/uploads");
            File dir = new File(path);
            if (!dir.exists()) dir.mkdirs();
            part.write(path + File.separator + fileName);
        }

        // 3. 投稿処理
        if (description != null && !description.trim().isEmpty()) {
            Playlist p = new Playlist();
            p.setUserId(user.getId());
            p.setDescription(description);
            p.setName(name != null ? name : ""); 
            p.setImagePath(fileName);
            qDAO.createPlaylist(p);
        }

        response.sendRedirect("TimelineServlet");
    }
}