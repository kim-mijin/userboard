<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	session.invalidate(); // 기존 세션을 지우고 새로운 새션으로 갱신
	response.sendRedirect(request.getContextPath()+"/home.jsp"); //클라이언트에서 사용하므로 request.getContextPath()를 적어준다
%>