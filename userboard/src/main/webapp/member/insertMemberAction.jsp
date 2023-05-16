<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
	// Ansi코드 
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 요청값(String id, String pw): post방식으로 들어오므로 인코딩
	request.setCharacterEncoding("utf-8");
	
	// 요청값이 잘 들어오는지 확인한다
	System.out.println(BG_YELLOW + request.getParameter("id") + " <--insertMemberAction param id" + RESET); // test1확인
	System.out.println(BG_YELLOW + request.getParameter("pw") + " <--insertMemberAction param pw" + RESET); // test1확인
	
	// 세션 유효성 검사: 로그인이 되어 있는 경우에는 이 페이지에 들어올 수 없다-> home.jsp로 리다이렉션 후 코드 진행 종료한다
	String msg = null;
	if(session.getAttribute("loginMemberId") != null) { // null인 경우는 세션에 정보가 저장되지 않은 경우
		msg = URLEncoder.encode("이미 로그인 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg); // 로그인 시 리다이렉션 확인
		return;
	}
	
	// 요청값 유효성 검사: null 이거나 공백일 경우에는 회원가입폼으로 리다이렉션 한다
	if(request.getParameter("id") == null 
		|| request.getParameter("id").equals("")
		|| request.getParameter("pw") == null
		|| request.getParameter("pw").equals("")){
		
		msg = URLEncoder.encode("ID 또는 PW를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/insertMemberForm.jsp?msg="+msg);
		return;
	}
	
	String id = request.getParameter("id");
	String pw = request.getParameter("pw");
	System.out.println(BG_YELLOW + id + " <--insertMemberAction id" + RESET); // test2확인
	System.out.println(BG_YELLOW + pw + " <--insertMemberAction pw" + RESET); // test2확인
	
	// 변수에 저장한 요청값을 Member클래스로 묶는다
	Member signup = new Member();
	signup.setMemberId(id); // Member타입 signup의 memberId필드에 id변수를 저장한다
	signup.setMemberPw(pw);
	
	// 요청값을 DB에 저장
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	PreparedStatement stmt = null;
	int row = 0; // 영향받은 행의 수를 저장할 변수
	PreparedStatement stmt2 = null; // id가 중복되는 점검할 때 쿼리
	ResultSet rs = null; // id가 중복되는 점검할 때 결과를 저장할 변수
	
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(BG_YELLOW + conn + " <--insertMemberAction conn : db접속성공" + RESET);
	
	/*
		INSERT INTO member (member_id, member_pw, createdate, updatedate)
		VALUES (?, PASSWORD(?), NOW(), NOW())
	*/
	String sql = "INSERT INTO member (member_id, member_pw, createdate, updatedate) VALUES (?, PASSWORD(?), NOW(), NOW())";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, signup.getMemberId());
	stmt.setString(2, signup.getMemberPw());
	System.out.println(BG_YELLOW + stmt + " <--insertMemberAction stmt" + RESET); //입력: test1, test1 -> ['test1','test1']
	
	// id(기본키)가 중복되는 경우 에러 발생 -> select로 id먼저 비교한 후 중복값은 리다이렉션 시키기
	String sql2 = "SELECT member_id memberId from member where member_id = ?";
	stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1, signup.getMemberId());
	System.out.println(BG_YELLOW + stmt2 + " <--insertMemberAction stmt2" + RESET);
	rs = stmt2.executeQuery();	
	if(rs.next()){ // 중복된 ID가 있는 경우
		msg = URLEncoder.encode("중복된 ID입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/insertMemberForm.jsp?msg="+msg);
		return;
	}
	
	row = stmt.executeUpdate(); // 영향받은 행의 수를 반환한다
	System.out.println(BG_YELLOW + row + " <--insertMemberAction row" + RESET); // 입력: test4, test4->1, admin, test5->에러 발생-> 앞에 중복검사 추가
	
	if(row == 1){ 
		msg = URLEncoder.encode("회원가입 성공", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	} else {
		msg = URLEncoder.encode("회원가입 실패", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	}
%>