/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gamestore.mysql.common;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

public class Startup extends HttpServlet
{
    public void init() throws ServletException
    {
        ServletContext sc = this.getServletContext();
        String path = sc.getRealPath("/WEB-INF/");
        SerializeHelper.root_directory = path;
    }
}
