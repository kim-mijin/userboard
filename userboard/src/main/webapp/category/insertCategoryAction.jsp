<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";

	// 1. 컨트롤러 계층
	// 로그인 관계없이 이 페이지에 접근 가능-> 세션 유효성 검사 하지 않음
	// 요청값: category(String)
	// 요청값 인코딩
	request.setCharacterEncoding("utf-8");
	
	//요청값이 잘 넘어오는지 확인
	System.out.println(request.getParameter("category") + " <--inserCategoryAction param category"); // null, 공백, 안산 확인
	
	//요청값 유효성 검사: 요청값이 null이거나 공백이면 Form으로 돌아간다
	String msg = null;
	if(request.getParameter("category") == null || request.getParameter("category").equals("")){
		msg = URLEncoder.encode("카테고리를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
		return;
	} // 확인 완료
	
	String category = request.getParameter("category");
	
	// 2. 모델 계층
	// 입력된 값이 기존 카테고리와 중복되면 Form으로 돌아가기
	// 입력된 값 불러오기
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
	System.out.println(categoryList.size() + " <--insertCategoryAction categoryList.size()"); // 결과: 9
	
	// 입력값과 비교하기
	for(String c : categoryList){
		if(category.equals(c)){
			msg = URLEncoder.encode("중복된 카테고리입니다", "utf-8");
			response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
			return;
		}
	} // 중복값 입력하면 리다이렉션 확인
	
	// 중복값이 없으면 DB에 저장하기
	String insertSql = null;
	PreparedStatement insertStmt = null;
	int row = 0;
	
	insertSql = "INSERT INTO local (local_name, createdate, updatedate) VALUES (?, NOW(), NOW())";
	insertStmt = conn.prepareStatement(insertSql);
	insertStmt.setString(1, category);
	System.out.println(BG_YELLOW + insertStmt + " <--insertCategoryAction insertStmt" + RESET);
	row = insertStmt.executeUpdate();
	
	// 입력 성공, 실패 모두 Form으로 리다이렉션, 메시지는 달라짐
	if(row == 1){
		msg = URLEncoder.encode("카테고리가 추가되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	} else {
		msg = URLEncoder.encode("카테고리 추가에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/category/categoryForm.jsp?msg="+msg);
	}
%>
