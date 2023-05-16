<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="vo.*" %>
<%
	//ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	//1. 컨트롤러 계층
		
	// 세션 유효성 검사: 로그인 안된 사용자는 접근 불가
	String msg = null;
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	
	// 요청값: localName(String), boardTitle(String), boardContent(String), memberId(String)
	request.setCharacterEncoding("utf-8");
	
	// 요청값 유효성 검사
	if(request.getParameter("localName") == null || request.getParameter("localName").equals("")
		|| request.getParameter("boardTitle") == null || request.getParameter("boardTitle").equals("")
		|| request.getParameter("boardContent") == null || request.getParameter("boardContent").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("게시글을 작성해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/addBoard.jsp?msg="+msg);
		return;
	}
	
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	String memberId = request.getParameter("memberId");
	
	System.out.println(localName + " <--addBoardAction localName");
	System.out.println(boardTitle + " <--addBoardAction boardTitle");
	System.out.println(boardContent + " <--addBoardAction boardContent");
	System.out.println(memberId + " <--addBoardAction memberId");
	
	//2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String addSql = null;
	PreparedStatement addStmt = null;
	int addResult = 0;
	
	addSql = "INSERT INTO board (local_name, board_title, board_content, member_id, createdate, updatedate)"
				+ "VALUES (?, ?, ?, ?, NOW(), NOW())";
	addStmt = conn.prepareStatement(addSql);
	addStmt.setString(1, localName);
	addStmt.setString(2, boardTitle);
	addStmt.setString(3, boardContent);
	addStmt.setString(4, memberId);
	System.out.println(BG_YELLOW + addStmt + " <--addBoardAction addStmt" + RESET);
	addResult = addStmt.executeUpdate();
	
	if(addResult == 1){
		System.out.println(addResult + "addBoardAction addResult: 성공");
		msg = URLEncoder.encode("게시글이 추가되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	} else {
		System.out.println(addResult + "addBoardAction addResult: 실패");
		msg = URLEncoder.encode("게시글 추가에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	}
%>