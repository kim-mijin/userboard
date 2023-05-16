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
	System.out.println(loginMemberId + " <--removeComment loginMemberId");
	
	// 요청값: boardNo(int), commentNo(int), commentContent(String), memberId(String)
	// boardNo와 memberId가 없으면 home으로 리다이렉션
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId") == null || request.getParameter("memberId").equals("")){
		msg = URLEncoder.encode("잘못된 접근입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	} 
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	System.out.println(boardNo + " <--modifyCommentAction boardNo");
	System.out.println(memberId + " <--modifyCommentAction memberId");
	
	// commentNo가 없으면 board상세페이지로 리다이렉션
	if (request.getParameter("commentNo") == null || request.getParameter("commentNo").equals("")){
		msg = URLEncoder.encode("댓글번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	} 
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	System.out.println(commentNo + " <--modifyCommentAction commentNo");
	
	// 댓글내용을 입력하지 않았을 경우에는 댓글 수정페이지로 리다이렉션
	if(request.getParameter("commentContent") == null || request.getParameter("commentContent").equals("")){
		msg = URLEncoder.encode("수정할 댓글을 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/modifyComment.jsp?boardNo="+boardNo+"commentNo="+commentNo+"memberId="+memberId+"&msg="+msg);
		return;
	}
	String commentContent = request.getParameter("commentContent");
	
	// loginMeberId와 memberId다르면 수정 불가
	if(!loginMemberId.equals(memberId)){
		msg = URLEncoder.encode("작성자가 아니므로 댓글을 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
		return;
	}
	System.out.println(commentContent + " <--modifyCommentAction commentContent");
	
	// 2. 모델계층
	// 기존 작성된 댓글 내용 불러오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String cmtMdfSql = null;
	PreparedStatement cmtMdfStmt = null;
	int cmtMdfResult = 0;
	
	cmtMdfSql = "UPDATE comment SET comment_content = ?, updatedate = NOW() WHERE comment_no = ?";
	cmtMdfStmt = conn.prepareStatement(cmtMdfSql);
	cmtMdfStmt.setString(1, commentContent);
	cmtMdfStmt.setInt(2, commentNo);
	System.out.println(BG_YELLOW + cmtMdfStmt + " <--modifyCommentAction mdfCmtStmt");
	cmtMdfResult = cmtMdfStmt.executeUpdate();
	
	if(cmtMdfResult == 1){
		System.out.println(cmtMdfResult + "modifyCommentAction mdfResult: 성공");
		msg = URLEncoder.encode("댓글이 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	} else {
		System.out.println(cmtMdfResult + "modifyCommentAction mdfResult: 실패");
		msg = URLEncoder.encode("댓글 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo+"&msg="+msg);
	}
%>
