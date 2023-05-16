<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 로그인이 되어 있지 않으면 이 페이지에 접근할 수 없다
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}

	String loginId = (String)session.getAttribute("loginMemberId");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container-fluid pt-3">
		<!-- 메인메뉴(가로) -->
		<div>
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		
		<!-- 현재 로그인된 ID 보여주기 -->
		<h1>회원정보</h1>
		<table class="table table-bordered">
			<tr>
				<th>ID</th>
				<td><%=loginId%></td>
			</tr>
		</table>
		<a href="<%=request.getContextPath()%>/member/changePwForm.jsp" class="btn btn-warning">비밀번호변경</a>
		<a href="<%=request.getContextPath()%>/member/deleteMemberForm.jsp" class="btn btn-warning">회원탈퇴</a>
	</div>
</body>
</html>