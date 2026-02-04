package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.QuestionDAO;
import model.User;

@WebServlet("/view/DeletePlaylistServlet")
public class DeletePlaylistServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String idStr = request.getParameter("id");

        if (user != null && idStr != null) {
            try {
                int playlistId = Integer.parseInt(idStr);
                
                // 本来はここで「消そうとしている投稿が本当に自分のものか」を
                // チェックするのが望ましいですが、まずは削除機能を優先します。
                qDAO.deletePlaylist(playlistId);
                
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        
        // 削除が終わったらマイページへ戻る
        response.sendRedirect("MyPageServlet");
    }
}