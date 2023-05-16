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
	// 세션 유효성 검사
	String msg = null;
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	Object o = session.getAttribute("loginMemberId");
	String loginMemberId = null;
	if(o instanceof String){
		loginMemberId = (String)o;
	}
	System.out.println(loginMemberId + " <--removeCommentAction loginMemberId");
	
	// 요청값: boardNo(int), memberId(String), commentNo(int)
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	System.out.println(boardNo + " <--removeCommentAction boardNo");
	System.out.println(memberId + " <--removeCommentAction memberId");
	
	if (request.getParameter("commentNo") == null || request.getParameter("commentNo").equals("")){
		msg = URLEncoder.encode("댓글번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	System.out.println(commentNo + " <--removeCommentAction commentNo");
	
	// loginMeberId와 memberId다르면 삭제 불가
	if(!loginMemberId.equals(memberId)){
		msg = URLEncoder.encode("작성자가 아니므로 댓글을 삭제할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	
	// 2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String cmtRmvSql = null;
	PreparedStatement cmtRmvStmt = null;
	int cmtRmvResult = 0;
	
	cmtRmvSql = "DELETE FROM comment WHERE comment_no = ?";
	cmtRmvStmt = conn.prepareStatement(cmtRmvSql);
	cmtRmvStmt.setInt(1, commentNo);
	System.out.println(cmtRmvStmt + " <--removeBoardAction rmvStmt");
	cmtRmvResult = cmtRmvStmt.executeUpdate();
	
	if(cmtRmvResult == 1){
		System.out.println(cmtRmvResult + "removeCommentAction cmtRmvResult: 성공");
		msg = URLEncoder.encode("댓글이 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	} else {
		System.out.println(cmtRmvResult + "removeCommentAction cmtRmvResult: 실패");
		msg = URLEncoder.encode("댓글 삭제에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	}
%>