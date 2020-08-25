import java.sql.*;

public class Assignment2 {

	// A connection to the database
	Connection connection;

	// Statement to run queries
	Statement sql;

	// Prepared Statement
	PreparedStatement ps;

	// Resultset for the query
	ResultSet rs;

	// CONSTRUCTOR
	Assignment2() {
		try {

			// Load JDBC driver
			Class.forName("org.postgresql.Driver");

		} catch (ClassNotFoundException e) {

			e.printStackTrace();
			return;

		}
	}

	// Using the input parameters, establish a connection to be used for this
	// session. Returns true if connection is sucessful
	public boolean connectDB(String URL, String username, String password) {
		try {

			connection = DriverManager.getConnection(URL, username, password);
			Statement statement = connection.createStatement();
			statement.execute("SET search_path TO A2");
		} catch (SQLException e) {

			e.printStackTrace();
			return false;

		}

		try {
			sql = connection.createStatement();
		}

		catch (SQLException e) {
			e.printStackTrace();
		}

		if (connection != null) {
			return true;

		} else {
			return false;
		}
	}

	// Closes the connection. Returns true if closure was sucessful
	public boolean disconnectDB() {
		try {
			connection.close();
			return true;
		}

		catch (SQLException e) {
			return false;
		}
	}

	public boolean insertCountry(int cid, String name, int height, int population) {
		try {
			String sqlText;
			String test;
			test = "SELECT * " + " FROM country AS C " + "WHERE C.cid = " + cid;
			rs = sql.executeQuery(test);
			if (rs == null) {
				sqlText = "INSERT INTO country " + "VALUES (" + cid + ", " + name + ", " + height + ", " + population
						+ ")";
				sql.executeUpdate(sqlText);

				if (sql.getUpdateCount() == -1) {
					return false;

				} else {
					return true;
				}

			} else {
				return false;
			}

		}

		catch (SQLException e) {
			return false;
		}
	}

	public int getCountriesNextToOceanCount(int oid) {
		try {
			String sqlText;
			sqlText = "SELECT count(cid) " + " FROM oceanAccess AS O " + "WHERE O.oid = " + oid;
			rs = sql.executeQuery(sqlText);
			return Integer.parseInt(sqlText);
		}

		catch (Exception e) {
			return -1;
		}
	}

	public String getOceanInfo(int oid) {
		try {
			String sqlText;
			int oid_1;
			String oname_1;
			int depth_1;

			sqlText = "SELECT * " + " FROM ocean AS O " + "WHERE O.oid = " + oid;
			rs = sql.executeQuery(sqlText);

			if (rs != null) {
				oid_1 = rs.getInt("oid");
				oname_1 = rs.getString("oname");
				depth_1 = rs.getInt("depth");
				return oid_1 + ":" + oname_1 + ":" + depth_1;
			} else {
				return "";
			}

		}

		catch (Exception e) {
			return "";
		}
	}

	public boolean chgHDI(int cid, int year, float newHDI) {
		try {
			String sqlText = "UPDATE hdi " + " SET hdi_score = " + newHDI + " WHERE  cid = " + cid + " AND "
					+ " year = " + year;
			sql.executeUpdate(sqlText);
			if (sql.getUpdateCount() == 1) {
				return true;

			}
		} catch (Exception e) {
			return false;
		}
		return false;
	}

	public boolean deleteNeighbour(int c1id, int c2id) {
		try {
			String sqlText = "DELETE FROM neighbour " + " WHERE country = " + c1id + " AND " + " neighbor = " + c2id;
			sql.executeUpdate(sqlText);
			if (sql.getUpdateCount() == 1) {
				sqlText = "DELETE FROM neighbour " + " WHERE country = " + c2id + " AND " + " neighbor = " + c1id;
				sql.executeUpdate(sqlText);

				return true;

			}
		} catch (Exception e) {
			return false;
		}
		return false;
	}

	public String listCountryLanguages(int cid) {
		String r = "";
		try {
			String sqlText = "SELECT L.lid AS lid, L.lname AS lname, ((L.lpercentage/100)* C.population) AS population"
					+ " FROM language L,country C" + " WHERE C.cid=L.cid AND L.cid = " + cid
					+ " GROUP BY population DESC";
			rs = sql.executeQuery(sqlText);
			while (rs.next()) {
				r = r + "l" + rs.getInt("lid") + ":l" + rs.getString("lname") + ":1" + rs.getInt("population") + "\n";
			}
			if (!rs.isBeforeFirst()) {
				return "";
			} else {
				return r;
			}
		} catch (Exception e) {
			return "";
		}
	}

	public boolean updateHeight(int cid, int decrH) {
		try {
			String sqlText = "UPDATE country " + " SET height = country.height -" + decrH + " WHERE cid = " + cid;
			sql.executeUpdate(sqlText);
			if (sql.getUpdateCount() == 1) {
				return true;

			}
		} catch (Exception e) {
			return false;
		}
		return false;
	}

	public boolean updateDB() {
		try {
			String sqlText = "CREATE TABLE mostPopulousCountries(" + " cid INTEGER, " + " cname VARCHAR(20) " + ") ";
			sql.executeUpdate(sqlText);
			if (sql.getUpdateCount() == 1) {
				sqlText = "INSERT INTO mostPopulousCountries" + " SELECT C.cid AS cid, C.cname AS cname"
						+ " FROM country C" + " WHERE C.population>100000000" + " ORDER BY cid ASC";
				sql.executeUpdate(sqlText);
				return true;

			}
		} catch (Exception e) {

		}
		return false;
	}


}
