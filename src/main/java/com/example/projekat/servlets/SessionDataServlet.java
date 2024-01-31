package com.example.projekat.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "sessionDataServlet", value = "/getSessionData")
public class SessionDataServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("application/json");
        HttpSession session = request.getSession(false);
        String jsonResponse;

        if (session != null) {
            Integer id = (Integer) session.getAttribute("id");
            jsonResponse = "{ \"id\": \"" + id + "\" }";
        } else {
            jsonResponse = "{ \"error\": \"No active session\" }";
        }

        System.out.println("JSON Response: " + jsonResponse);

        try (PrintWriter out = response.getWriter()) {
            out.println(jsonResponse);
        }
    }
}
