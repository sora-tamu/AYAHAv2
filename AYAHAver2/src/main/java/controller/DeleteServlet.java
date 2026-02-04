package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.QuestionDAO;
import model.User;

@WebServlet("/view/DeleteServlet")
public class DeleteServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        // 削除する投稿のIDを取得
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int playlistId = Integer.parseInt(idStr);
            // 削除実行
            qDAO.deletePlaylist(playlistId, loginUser.getId());
        }

        // 削除が終わったらマイページにリダイレクト
        response.sendRedirect("MyPageServlet");
    }
}