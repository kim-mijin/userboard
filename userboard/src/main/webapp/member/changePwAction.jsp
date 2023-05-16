<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>

<%
	// 로그인이 되어있지 않으면 해당 페이지는 접근할 수 없다 -> home으로 리다이렉션 후 코드진행 종료
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	// ANSI코드
	final String BG_YELLOW = "\u001B[43m";
	final String RESET = "\u001B[0m";
	
	// 1. 컨트롤러 계층
	// 요청값: currentPw(String), changePw(String), confirmPw(String)
	// post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	// 요청값이 잘 넘어오는지 확인하기
	System.out.println(request.getParameter("currentPw") + " <--changePwAction param currentPw"); // 입력안했을 경우 공백 넘어옴
	System.out.println(request.getParameter("changePw") + " <--changePwAction param changePw");
	System.out.println(request.getParameter("confirmPw") + " <--changePwAction param confirmPw");
	
	String currentPw = ""; // null로 넘어오는 경우 공백으로 처리하기 위해 공백으로 초기값 설정
	String changePw = "";
	String confirmPw = "";
	String msg = null;
	// 요청값이 공백이거나 null이면 changePwForm으로 리다이렉션, 메시지, 코드진행 종료
	if(request.getParameter("currentPw") == null
			|| request.getParameter("currentPw").equals("")
			|| request.getParameter("changePw") == null
			|| request.getParameter("changePw").equals("")
			|| request.getParameter("confirmPw") == null
			|| request.getParameter("confirmPw").equals("")){
		msg = URLEncoder.encode("현재 비밀번호 또는 변경할 비밀번호를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/changePwForm.jsp?msg="+msg);
		return;
	}
	currentPw = request.getParameter("currentPw");
	changePw = request.getParameter("changePw");
	confirmPw = request.getParameter("confirmPw");
	
	System.out.println(BG_YELLOW + currentPw + " <--changePwAction currentPw" + RESET);
	System.out.println(BG_YELLOW + changePw + " <--changePwAction changePw" + RESET);
	System.out.println(BG_YELLOW + confirmPw + " <--changePwAction confirmPw" + RESET);
	
	// 변경 비밀번호와 확인 비밀번호가 일치하지 않으면 Form으로 리다이렉션
	if(!changePw.equals(confirmPw)){
		msg = URLEncoder.encode("변경 비밀번호를 다시 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/changePwForm.jsp?msg="+msg);
		return;
	}
	
	String loginId = (String)session.getAttribute("loginMemberId");  // session.getAttribute는 object타입이라 String으로 형변환
		
	// 2. 모델 계층
	// DB에서 데이터 가져오기
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 현재 비밀번호와 일치하는 경우 비밀번호 변경
	String sql = null;
	PreparedStatement stmt = null;
	int row = 0;
	
	/*
		update member 
		set member_pw = password(?)
		where member_id = ? and member_pw = password(?) 
	*/
	
	sql = "update member set member_pw = password(?) where member_id = ? and member_pw = password(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, changePw);
	stmt.setString(2, loginId); 
	stmt.setString(3, currentPw);
	System.out.println(BG_YELLOW + stmt + " <--changePwAction stmt" + RESET);
	row = stmt.executeUpdate();
	System.out.println(row + " <--changePwAction row");
	
	if(row == 1){ // 변경 성공한 경우
		msg = URLEncoder.encode("비밀번호가 변경되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	} else { // 변경 실패한 경우
		msg = URLEncoder.encode("비밀번호 변경에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/changePwForm.jsp?msg="+msg);
	}

%>