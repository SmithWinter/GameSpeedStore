<%@page import="gamestore.mysql.beans.OrderItem"%>
<%@page import="gamestore.mysql.beans.Order"%>
<%@page import="gamestore.mysql.common.Constants"%>
<%@page import="gamestore.mysql.common.Helper"%>
<%@page import="gamestore.mysql.beans.SelectorOption"%>
<%@page import="java.util.ArrayList"%>
<%@page import="gamestore.mysql.beans.ProductItem"%>
<%@page import="java.util.List"%>
<%@page import="gamestore.mysql.dao.ProductDao"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String errmsg = "";
    List<SelectorOption> list = null;
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_ALLORDERS);
    if(!helper.isLoggedin()){
        errmsg = "Please login first!";
    } else {    
        String usertype = helper.usertype();

        if (usertype==null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
            errmsg = "You have no authorization to manage order!";
        }

        ProductDao dao = ProductDao.createInstance();
        List<ProductItem> products = dao.getProductList();
        list = new ArrayList<SelectorOption>();
        for (ProductItem product: products) {
            list.add(new SelectorOption(product.getId(), product.getName()));
        }
    }
    
    String orderid = request.getParameter("orderid");
    if (orderid==null||orderid.isEmpty()) {
        errmsg = "Invalid Paramters!";
    } else {    
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            String address = request.getParameter("address");
            String creditcard = request.getParameter("creditcard");
            Order order;    
            synchronized(session) {
                order = (Order)session.getAttribute("OrderItem"+orderid);
                order.setAddress(address);
                order.setCreditCard(creditcard);                   
            }
        } else {
            String productkey = request.getParameter("productkey");
            String strQuantity = request.getParameter("quantity");
            int quantity;
            try {
                quantity = Integer.parseInt(strQuantity);
            } catch(NumberFormatException nfe) {
                quantity = 1;
            }
            ProductDao dao = ProductDao.createInstance();
            ProductItem product = dao.getProduct(productkey);

            Order order;    
            synchronized(session) {
                order = (Order)session.getAttribute("OrderItem"+orderid);
                if (order != null) {
                    int maxid = 0;
                    for (int i = 0; i < order.getItems().size(); i++) {
                        maxid = Math.max(order.getItems().get(i).getOrderItemId(), maxid);
                    }
                    OrderItem item = new OrderItem(maxid + 1, Integer.parseInt(orderid), product.getId(), product.getName(), product.getType(), product.getPrice(), product.getImage(), product.getMaker(), product.getDiscount(), 1);
                    item.setQuantity(quantity);
                    order.addItem(item);
                    errmsg = "Product has been added to order!";
                }           
            }
        }
    }
    
    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("orderid", orderid);    
    pageContext.setAttribute("list", list);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add Item</title>
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>  
        <link rel="stylesheet" 
          href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
        <!-- User defined css -->  
        <link rel="stylesheet" href="css/style.css" type="text/css" />
        <link rel="stylesheet" href="css/jquery.fancybox.css" type="text/css" />
        <script src="scripts/autocompleter.js"></script>
        <script src="scripts/jquery.fancybox.js"></script>
    </head>
    <body>
        <h1>Choose Product</h1>
        <c:choose>
            <c:when test="${not empty errmsg}">
                <h3 style='color:red'>${errmsg}</h3>
            </c:when>
            <c:otherwise>
                <form action="admin_orderitemedit.jsp" method="Post">
                    <input type='hidden' name='orderid' id='orderid' value='${orderid}'>
                    <table>
                        <tr><td>Product:</td>
                            <td>
                                <select name='productkey' class='input'>
                                <c:forEach var="option" items="${list}">
                                    <option value=${option.key}>${option.text}</option>
                                </c:forEach>  
                                </select>
                            </td>
                        </tr>
                        <tr><td>Quantity:</td><td><input type='text' name='quantity' value='1' class='input' required /></td></tr>
                        <tr><td colspan="2"><input name="create" class="formbutton" value="Add" type="submit" /></td></tr>
                    </table>
                </form>
            </c:otherwise>
        </c:choose>
    </body>
</html>
