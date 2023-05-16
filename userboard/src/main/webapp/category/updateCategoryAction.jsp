<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>

<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러 계층
	// 로그인 상관 없이 이 페이지에 접근 가능 -> 세션 유효성 검사 하지 않음
	// 요청값: category(String/기존 카테고리), newCategory(String/수정 카테고리)
	request.setCharacterEncoding("utf-8");
	
	// 요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("category") + " <--updateCategoryAction param category"); // 확인
	System.out.println(request.getParameter("newCategory") + " <--updateCategoryAction param newCategory"); // 확인
	
	// 요청값 유효성 검사: category요청값이 null이나 공백이면 category Form으로, newCategory값이 null이거나 공백이면 수정폼으로 리다이렉션
	String msg = "";
	if(request.getParameter("category") == null || request.getParameter("category").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
		return;
	} else if (request.getParameter("newCategory") == null || request.getParameter("newCategory").equals("")){
		msg = URLEncoder.encode("카테고리를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/updateCategoryForm.jsp?msg="+msg+"&category="+URLEncoder.encode(request.getParameter("category"),"utf-8"));
		return;
	} // ★★★주소뒤에 값을 보낼때는 값을 받을 때 인코딩과 관계없이 인코딩을 해서 보내야 한다 -> request.getParameter("category")인코딩
	
	String category = request.getParameter("category");
	String newCategory = request.getParameter("newCategory");
	System.out.println(category + " <--updateCategoryAction category");
	System.out.println(newCategory + " <--updateCategoryAction newCategory");
	
	// 2. 모델 계층
	// 기존 카테고리와 동일한 경우 수정 불가능
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	sql = "SELECT local_name localName FROM local";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	
	// ResultSet -> ArrayList로 바꾸기
	ArrayList<String> categoryList = new ArrayList<String>();
	while(rs.next()){
		String c = new String();
		c = rs.getString("localName");
		categoryList.add(c);
	}
	System.out.println(categoryList.size() + " <--updateCategoryAction categoryList.size()"); // 
	
	// 입력값과 비교하기
	for(String c : categoryList){
		if(newCategory.equals(c)){
			msg = URLEncoder.encode("중복된 카테고리입니다", "utf-8");
			response.sendRedirect(request.getContextPath()+"/category/updateCategoryForm.jsp?msg="+msg+"&category="+URLEncoder.encode(category,"utf-8"));
			return;
		}
	} // 중복값 입력하면 리다이렉션 확인
	
	String updateSql = null;
	PreparedStatement updateStmt = null;
	ResultSet updateRs = null;
	int updateRow = 0;
	
	updateSql = "UPDATE local SET local_name = ? WHERE local_name = ?";
	updateStmt = conn.prepareStatement(updateSql);
	updateStmt.setString(1, newCategory);
	updateStmt.setString(2, category);
	System.out.println(BG_YELLOW + updateStmt + " <--updateCategoryAction insertStmt" + RESET);
	updateRow = updateStmt.executeUpdate();
	
	// 입력 성공, 실패 모두 Form으로 리다이렉션, 메시지는 달라짐
	if(updateRow == 1){
		System.out.println(updateRow + " <--updateCategoryAction updateRow");
		msg = URLEncoder.encode("카테고리가 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	} else {
		System.out.println(updateRow + " <--updateCategoryAction updateRow");
		msg = URLEncoder.encode("카테고리 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	}
%>