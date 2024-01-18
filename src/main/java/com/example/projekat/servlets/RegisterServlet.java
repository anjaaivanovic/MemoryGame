package com.example.projekat.servlets;

import com.example.projekat.Database;
import entities.UserEntity;
import jakarta.persistence.EntityManager;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.util.List;

@WebServlet(name = "registerServlet", value = "/registerServlet")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManager entityManager = Database.getConnection();

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String password1 = req.getParameter("password1");
        req.getSession().setAttribute("username", username);

        if (!password.equals(password1)){
            req.getSession().setAttribute("regError", "Passwords don't match!");
            resp.sendRedirect("register.jsp");
            return;
        }

        String sql  = "select * from users where username='" + username + "'";

        @SuppressWarnings("unchecked")
        List<UserEntity> tempUser = entityManager.createNativeQuery(sql, UserEntity.class).getResultList();

        if (tempUser.size() != 0){
            req.getSession().setAttribute("regError", "Username already exists!");
            resp.sendRedirect("register.jsp");
        }
        else{
            UserEntity user = new UserEntity();
            user.setUsername(username);
            user.setPassword(password);
            user.setRoleId(1);
            user.setGamesPlayed(0);
            user.setGamesWon(0);
            user.setRank("-");

            entityManager.getTransaction().begin();
            entityManager.persist(user);
            entityManager.getTransaction().commit();
            req.getSession().setAttribute("username", null);
            resp.sendRedirect("index.jsp");
        }
    }
}
