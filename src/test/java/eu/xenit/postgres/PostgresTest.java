package eu.xenit.postgres;

import org.junit.jupiter.api.Test;
import java.sql.*;
import static org.junit.jupiter.api.Assertions.*;

class PostgresTest {

    private Connection getConnection() throws SQLException {
        String connectionString = System.getProperty("connectionString");
        String user = System.getProperty("postgres.username");
        String password = System.getProperty("postgres.password");
        return DriverManager.getConnection(connectionString, user, password);
    }

    @Test
    void testConnection() throws SQLException {
        System.out.println("Executing testConnection");
        getConnection().close();
    }

    @Test
    public void testTimescaleDB() throws SQLException {
        System.out.println("Executing testTimescaleDB");
        Connection connection = getConnection();
        Statement stm = connection.createStatement();
        ResultSet resultSet = stm.executeQuery("SELECT * FROM pg_extension WHERE extname='timescaledb';");
        assertTrue(resultSet.next());
        assertFalse(resultSet.next());
        connection.close();
    }

    @Test
    public void testPromscale() throws SQLException {
        System.out.println("Executing testPromscale");
        Connection connection = getConnection();
        Statement stm = connection.createStatement();
        ResultSet resultSet = stm.executeQuery("SELECT * FROM pg_available_extensions WHERE name='promscale';");
        assertTrue(resultSet.next());
        assertFalse(resultSet.next());
        connection.close();
    }
}
