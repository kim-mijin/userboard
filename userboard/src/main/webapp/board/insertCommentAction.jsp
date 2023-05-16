<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "vo.*" %>

<%
	//안시코드
	final String GREEN = "\u001B[32m";
	final String RESET = "\u001B[0m";	
	
	// 1. 컨트롤러 계층
	// insertCommentAction: 댓글입력-> DB에 저장
	// 세션 유효성 검사: 로그인이 되어있지 않으면 댓글입력은 불가하므로 상세페이지로 되돌아가기
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp?");
		return;
	}
	
	// 요청값: boardNo(int), memberId(String), commentContent(String)
	// post방식 요청값 인코딩
	request.setCharacterEncoding("utf-8");
	
	// 요청값 잘 넘어오는지 확인하기
	System.out.println(request.getParameter("boardNo") + " <--insertCommentAction param boardNo"); // 1000->1000
	System.out.println(request.getParameter("memberId") + " <--insertCommentAction memberId boardNo"); // admin->admin
	System.out.println(request.getParameter("commentContent") + " <--insertCommentAction commentContent boardNo"); // test->test

	String memberId = ""; // null이 넘어오는 경우 공백으로 처리하면 되기 때문에 공백으로 초기화한다
	String commentContent = "";
	
	// 요청값 유효성 검사: 요청값들이 null이거나 공백이면 home.jsp로 리다이렉션
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId").equals("")
			|| request.getParameter("commentContent").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp?");
		return;
	} 
	
	int boardNo = Integer.parseInt(request.getParameter("boardNo")); // boardNo는 초기값이 필요가 없기 때문에 변수를 선언하고 바로 요청값을 대입한다
	memberId = request.getParameter("memberId");
	commentContent = request.getParameter("commentContent");
	
	System.out.println(boardNo + " <--insertCommentAction boardNo");
	System.out.println(memberId + " <--insertCommentAction memberId");
	System.out.println(commentContent + " <--insertCommentAction commentContent");
	
	// 변수에 저장한 요청값을 Comment타입으로 묶는다
	Comment comment = new Comment();
	comment.setBoardNo(boardNo); // Comment클래스의 boardNo는 private으로 정보은닉, 캡슐화 되어있으므로 set메서드로 값을 변경한다
	comment.setCommentContent(commentContent);
	comment.setMemberId(memberId);
	
	// 2. 모델계층
	// DB에 comment저장
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 쿼리 변수 선언
	/*
		INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate)
		VALUES(?, ?, ?, NOW(), NOW())
	*/
	String commentSql = "";
	PreparedStatement commentStmt = null;
	int commentRow = 0; // 영향받은 행의 개수(실행 후 결과값)
	
	// 쿼리 실행
	commentSql = "INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())";
	commentStmt = conn.prepareStatement(commentSql);
	commentStmt.setInt(1, comment.getBoardNo());
	commentStmt.setString(2, comment.getCommentContent());
	commentStmt.setString(3, comment.getMemberId());
	System.out.println(GREEN + commentStmt + " <--insertCommentAction commentStmt" + RESET);
	
	commentRow = commentStmt.executeUpdate();
	if(commentRow == 1){
		System.out.println(commentRow + " <--insertCommentAction commentRow: 입력성공");
	} else{
		System.out.println(commentRow + " <--insertCommentAction commentRow: 입력실패");
	}
	
	// 입력이 완료되면(성공, 실패 여부 관계없이) boardOne.jsp로 되돌아간다
	response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+comment.getBoardNo());
%>
