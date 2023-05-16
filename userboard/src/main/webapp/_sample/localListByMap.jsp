<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %><!-- HashMap -->

<%
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 1. HashMap에 조회한 데이터 저장하기
	// SELECT결과에 컬럼값 외의 정보를 추가하여 출력 (컬럼이 없는 '대한민국'과 'kmj')
	/*
		SELECT local_name localName, '대한민국' country, 'kmj' worker 
		FROM LOCAL 
		LIMIT 0, 1
	*/
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT local_name localName, '대한민국' country, 'kmj' worker FROM LOCAL LIMIT 0, 1";
	stmt = conn.prepareStatement(sql);
	System.out.println(stmt + " <--localListByMap stmt");
	rs = stmt.executeQuery();
	
	// VO대신 HashMap타입을 사용
	HashMap<String, Object> map = null; 
	// map이라는 이름을 가진 키(String), 값(Object)의 HashMap타입 변수 -> Object에는 모든 타입이 들어올 수 있다
	// rs.next()가 참일때만 map을 만들면 되기 때문에 초기값은 null
	if(rs.next()){ // 행이 하나만 존재하므로 while문 대신 if문으로 결과값을 조회한다
		// System.out.println(rs.getString("localName"));
		// System.out.println(rs.getString("country"));
		// System.out.println(rs.getString("worker"));
		map = new HashMap<String, Object> ();
		map.put("localName", rs.getString("localName")); // map.put(키이름, 값)
		map.put("country", rs.getString("country"));
		map.put("worker", rs.getString("worker"));
	} // 한 행의 HashMap을 만들고 rs의 값을 넣는다
	System.out.println((String)map.get("localName")); // rs.getString("localName")(Object타입)이 String으로 형변환되어 출력된다 
	
	// 2. 여러개의 행을 저장할 때는 HashMap타입의 ArrayList에 저장
	PreparedStatement stmt2 = null;
	ResultSet rs2 = null;
	String sql2 = "SELECT local_name localName, '대한민국' country, 'kmj' worker FROM local";
	stmt2 = conn.prepareStatement(sql2);
	System.out.println(stmt2 + " <--localListByMap stmt2");
	rs2 = stmt2.executeQuery();
	
	ArrayList<HashMap<String, Object>> list2 = new ArrayList<HashMap<String, Object>>();// HashMap<String, Object>타입의 ArrayList를 만든다
	while(rs2.next()){
		HashMap<String, Object> m = new HashMap<String, Object>(); // HashMap은 rs값이 존재할 때 만들어지면 되므로 while블럭 안에 들어온다
		m.put("localName", rs2.getString("localName")); // map.put(키이름, 값)
		m.put("country", rs2.getString("country"));
		m.put("worker", rs2.getString("worker"));
		list2.add(m);
	} // HashMap타입의 m에 rs의 값을 저장하고 만들어진 행을 list2에 추가한다
	
	// 3. SQL GROUP BY 절과 집계함수
	/*
		SELECT local_name, COUNT(board_no) FROM board
		GROUP BY local_name; 
		-- group by 절이 나오는 함수->집계함수(sum(숫자), avg(숫자), count(숫자,문자), max(숫자,문자), min(숫자,문자))
		-- group by null 은 생략가능
	*/
	PreparedStatement stmt3 = null;
	ResultSet rs3 = null;
	String sql3 = "SELECT local_name localName, count(local_name) cnt FROM board GROUP BY local_name";
	stmt3 = conn.prepareStatement(sql3);
	System.out.println(stmt3 + " <--localListByMap stmt3");
	rs3 = stmt3.executeQuery();
	
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<HashMap<String, Object>>();// HashMap<String,Object>타입의 ArrayList를 만든다
	while(rs3.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", rs3.getString("localName")); // map.put(키이름, 값)
		m.put("cnt", rs3.getInt("cnt"));
		list3.add(m);
	}
	
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>localListByMap</title>
</head>
<body>
	<h1>rs2 결과셋</h1>
	<table>
		<tr>
			<th>localName</th>
			<th>country</th>
			<th>worker</th>
		</tr>
		<%
			for(HashMap<String, Object> m : list2){
		%>
				<tr>
					<td><%=m.get("localName")%></td>
					<td><%=m.get("country")%></td>
					<td><%=m.get("worker")%></td>
				</tr>
		<%
			}
		
		%>
	</table>
	
	<hr>
	
	<h1>rs3 결과셋</h1>
	<ul>
		<!-- 
		전체 메뉴
		<li>
			<a href="">전체</a>
		</li>
		-->
		<%
			for(HashMap<String, Object> m : list3) {
		%>
				<li>
					<a href="">
						<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)<!-- Object타입을 String, Integer로 형변환 하는 것 잊지 않기! -->
					</a>
				</li>
		<%
			}
		%>
	</ul>
</body>
</html>