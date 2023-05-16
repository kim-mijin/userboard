<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	// 로그인이 되어있지 않으면 현재 페이지에 접근할 수 없다
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
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
	
	<h1>비밀번호 변경</h1>
		
	<!-- Action페이지에서 리다이렉션 되면 메시지표시 -->
	<div class="bg-danger text-white">
	<%
		if(request.getParameter("msg") != null){
	%>
			<%=request.getParameter("msg")%>
	<%
		}
	%>
	</div>
	<form action="<%=request.getContextPath()%>/member/changePwAction.jsp" method="post">
		<!-- 현재 비밀번호 확인 및 변경 비밀번호 입력 -->
		<table class="table table-bordered">
			<tr>
				<th><label for="curPw">현재 비밀번호</label></th>
				<td>
					<input type="password" name="currentPw" id="curPw">
				</td>
			</tr>
			<tr>
				<th><label for="newPw">변경 비밀번호</label></th>
				<td>
					<input type="password" name="changePw" id="newPw">
				</td>
			</tr>
			<tr>
				<th><label for="confirmPw">변경 비밀번호 확인</label></th>
				<td>
					<input type="password" name="confirmPw" id="confirmPw">
				</td>
			</tr>
		</table>
		<button type="submit" class="btn btn-warning">변경하기</button>
	</form>
</div>
</body>
</html>