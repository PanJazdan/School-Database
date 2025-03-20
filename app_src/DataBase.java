import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.sql.*;
import java.util.ArrayList;

/**
 * Klasa DataBase obsluguje polaczenie z baza danych PostgreSQL oraz wykonuje operacje SQL.
 * Umozliwia pobieranie nazw tabel, kolumn, typow danych, a takze wykonywanie poleceń DML i DDL.
 */

public class DataBase {

    /**
     * Obiekt polaczenia z baza danych.
     */
    Connection conn = null;

    /**
     * Stala komunikatu bledow.
     */
    private final String ERROR = "1:\n";
    /**
     * Stala komunikatu sukcesu.
     */
    private final String SUCCESS = "0:\n  ";

    /**
     * Obiekt przechowujacy metadane bazy danych.
     */
    DatabaseMetaData dbData;

    /**
     * Nazwa schematu uzywanego w bazie danych.
     */
    String schema_name = "erd_projekt";
    /**
     * Konstruktor klasy DataBase. Nawiazuje polaczenie z baza danych PostgreSQL
     * i ustawia domyslny schemat.
     */
    DataBase(){
        // Polaczenie z baza danych
    String url = "jdbc:postgresql://jolly-dominant-ostrich.data-1.use1.tembo.io:5432/postgres";
    String user = "postgres";
    String password = "gpsSy0DIJpNzIAnG";
    Statement stmt = null;

        try  {
            conn = DriverManager.getConnection(url, user, password);
            dbData = conn.getMetaData();
            stmt = conn.createStatement();

          String setSchemaSQL = "SET search_path TO erd_projekt";
          stmt.execute(setSchemaSQL);
        } catch (SQLException e) {
            System.out.println("Blad podczas polaczenia: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Pobiera liste nazw tabel w schemacie.
     * @return Lista nazw tabel.
     */
    public ArrayList<String> getTableNames(){
        ArrayList<String> tableNames = new ArrayList<String>();

        try{
            ResultSet tables = dbData.getTables(null,schema_name,"%",new String[]{"TABLE"});

            while (tables.next()) {
                tableNames.add(tables.getString("TABLE_NAME"));
                //System.out.println(tables.getString("TABLE_NAME"));
            }
        }catch (SQLException e){
            System.err.println("Blad w pobieraniu nazw tabel");
            e.printStackTrace();
        }
        return tableNames;
    }

    /**
     * Pobiera liste nazw kolumn w podanej tabeli.
     * @param tableName Nazwa tabeli.
     * @return Lista nazw kolumn.
     */
    public ArrayList<String> getColumnNames(String tableName){
        ArrayList<String> columnNames = new ArrayList<String>();
        try{
            ResultSet rs = dbData.getColumns(null,schema_name,tableName,null);
            while (rs.next()){
                columnNames.add(rs.getString("COLUMN_NAME"));
            }

        }catch (SQLException e){
            System.err.println("Blad w pobieraniu nazw kolumn");
            e.printStackTrace();
        }
        return columnNames;
    }

    /**
     * Pobiera liste typow danych kolumn dla danej tabeli.
     * @param tableName Nazwa tabeli.
     * @return Lista typow kolumn.
     */
    public ArrayList<String> getColumnTypes(String tableName){
        ArrayList<String> columnTypes = new ArrayList<String>();
        try{
            ResultSet rs = dbData.getColumns(null,schema_name,tableName,null);
            while (rs.next()){
                columnTypes.add(rs.getString("TYPE_NAME"));
            }

        }catch (SQLException e){
            System.err.println("Blad w pobieraniu typow kolumn");
            e.printStackTrace();
        }
        return columnTypes;
    }

    /**
     * Sprawdza, czy kolumny w tabeli moga przyjmowac wartosci NULL.
     * @param tableName Nazwa tabeli.
     * @return Lista wartosci okreslajacych NULL/NOT NULL.
     */
    public ArrayList<String> getColumnNullable(String tableName){
        ArrayList<String> columnNulls = new ArrayList<String>();
        try{
            ResultSet rs = dbData.getColumns(null,schema_name,tableName,null);
            while (rs.next()) {
                int nullable = rs.getInt("NULLABLE");
                if(nullable == 0){
                    columnNulls.add("NOT NULL");
                }
                else
                    columnNulls.add(" ");
            }
        }catch (SQLException e){
                System.err.println("Blad w pobieraniu typow kolumn");
                e.printStackTrace();
            }

        return columnNulls;

    }

    /**
     * Pobiera liste funkcji z bazy danych, ktore zaczynaja sie od "fun".
     * @return Lista nazw funkcji.
     */
    public ArrayList<String> getFunctionNames(){
        ArrayList<String> functionNames = new ArrayList<String>();
        try{
            ResultSet rs = dbData.getFunctions(null,schema_name,"fun%");
            while (rs.next()) {
                functionNames.add(rs.getString("FUNCTION_NAME"));
            }
        }catch (SQLException e){
            System.err.println("Blad w pobieraniu nazw funkcji");
            e.printStackTrace();
        }
        return functionNames;
    }

    /**
     * Pobiera opisy funkcji zapisanych w bazie danych.
     * @return Lista opisow funkcji.
     */
    public ArrayList<String> getFunctionDescription(){
        ArrayList<String> functionDesc = new ArrayList<String>();
        try{
            ResultSet rs = dbData.getFunctions(null,schema_name,"fun%");
            while (rs.next()) {
                String str = rs.getString("REMARKS");
                functionDesc.add(str);
//                System.out.println(str);
            }
        }catch (SQLException e){
            System.err.println("Blad w pobieraniu nazw funkcji");
            e.printStackTrace();
        }
        return functionDesc;
    }

    /**
     * Pobiera wszystkie wartosci z okreslonej kolumny w tabeli.
     * @param tableName Nazwa tabeli.
     * @param columnName Nazwa kolumny.
     * @return Lista wartosci kolumny.
     */
    public ArrayList<String> getOneWholeColumn(String tableName, String columnName){
        ArrayList<String> wholeColumn = new ArrayList<String>();
        String command = "SELECT " + tableName+"_id," + columnName + " FROM " + tableName;

        try{
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(command);
            while (rs.next()) {
                wholeColumn.add(rs.getString(1) + "     " + rs.getString(2));
            }

            rs.close();
            st.close();
        }catch (SQLException e){
            System.err.println("Blad w pobieraniu calej kolumny");
            e.printStackTrace();
        }
        return wholeColumn;
    }

    /**
     * Wykonuje operacje INSERT na bazie danych.
     * @param command Polecenie SQL INSERT.
     * @return Komunikat o sukcesie lub bledzie.
     */
    public String InsertCommand(String command){
        try {
            PreparedStatement pst = conn.prepareStatement(command);
            int rows ;
            rows = pst.executeUpdate();
//            System.out.println(rows) ;
            pst.close();
        }catch (SQLException e){
            System.out.println("Blad insertu");
            e.printStackTrace();
            return ERROR + "Blad we wpisanym polu okna INSERT, szczegoly: " + e.getMessage();
        }
        return SUCCESS + "Pomyslnie dodano rekord o tresci: " + command;
    }

    /**
     * Wykonuje operacje DELETE na bazie danych.
     * @param command Polecenie SQL DELETE.
     * @return Komunikat o sukcesie lub bledzie.
     */
    public String DeleteCommand(String command){
        try {
            PreparedStatement pst = conn.prepareStatement(command);
            pst.executeUpdate();
//            System.out.println(command) ;
            pst.close();
        }catch (SQLException e){
            System.out.println("Blad przy usuwaniu");
            e.printStackTrace();
            return ERROR + "Blad podczas usuwania rekordu, szczegoly: " + e.getMessage();
        }
        return SUCCESS + "Pomyslnie usunieto rekord , tresc kwerendy: " + command;
    }

    /**
     * Wykonuje operacje UPDATE na bazie danych.
     * @param command Polecenie SQL UPDATE.
     * @return Komunikat o sukcesie lub bledzie.
     */
    public String UpdateCommand(String command){
        try {
            PreparedStatement pst = conn.prepareStatement(command);
            pst.executeUpdate();
//            System.out.println(command) ;
            pst.close();
        }catch (SQLException e){
            System.out.println("Blad przy usuwaniu");
            e.printStackTrace();
            return ERROR + "Blad podczas zmiany rekordu, szczegoly: " + e.getMessage();
        }
        return SUCCESS + "Pomyslnie zmieniono rekord , tresc kwerendy: " + command;
    }

    /**
     * Wykonuje dowolne zapytanie SQL i zwraca wyniki w formacie tabelarycznym.
     * @param command Polecenie SQL SELECT.
     * @return Wyniki zapytania jako sformatowany tekst.
     */
    public String ExecuteCommand(String command){
            StringBuilder returnString = new StringBuilder();
        ArrayList<ArrayList<String>> resultOfSelect = new ArrayList<ArrayList<String>>();
        try{

            PreparedStatement pst = conn.prepareStatement(command,ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
            ResultSet rs = pst.executeQuery();
            ResultSetMetaData data = rs.getMetaData();

            int columnCount = data.getColumnCount();

            resultOfSelect.add(new ArrayList<String>());

            for (int i=1;i<=columnCount;i++){
                resultOfSelect.get(0).add(data.getColumnLabel(i));
            }

//            System.out.println();
            int index=1;
            while (rs.next())  {
                resultOfSelect.add(new ArrayList<String>());
                String output="";
                for (int i=1;i<=columnCount;i++){
                    if(rs.getString(i) == null){
                        resultOfSelect.get(index).add("---"); //ta linijka jest potrzebna bo string builder sie pruje gdy widzi obiekt null
                    }
                    else
                        resultOfSelect.get(index).add(rs.getString(i));
                }
                index++;
            }
            rs.close();
            pst.close();

            int[] columnWidths = new int[resultOfSelect.get(0).size()];
            for (ArrayList<String> row : resultOfSelect) {
                for (int i = 0; i < row.size(); i++) {
                    columnWidths[i] = Math.max(columnWidths[i], row.get(i).length());
                }
            }

            for (ArrayList<String> row : resultOfSelect) {
                for (int i = 0; i < row.size(); i++) {
                    returnString.append(String.format("%-" + (columnWidths[i] + 3) + "s ", row.get(i))).append("|");
                }
                returnString.append("\n  ");
            }

        }
        catch (SQLException e){
            System.err.println("command");
            e.printStackTrace();
            return ERROR + "Blad we wpisanej komendzie, szczegoly:\n" + e.getMessage();
        }
        return SUCCESS + returnString;
    }

    /**
     * Uruchamia skrypt SQL z pliku i wykonuje jego polecenia.
     * @param fileName sciezka do pliku SQL.
     * @return Komunikat o sukcesie lub bledzie.
     */
    public String RunFile(String fileName){
        try {
            Statement stmt = conn.createStatement();

//            System.out.println("Proba odczytu pliku z: " + new File(fileName).getAbsolutePath());
            BufferedReader reader = new BufferedReader(new FileReader(fileName));
            StringBuilder sql = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sql.append(line).append("\n");
            }
            reader.close();

            stmt.execute(sql.toString());
            stmt.close();
        }catch (Exception e){
            e.printStackTrace();
            return ERROR + "Blad podczas uruchamiania pliku, szczegoly: " + e.getMessage();
        }

        return SUCCESS + "Pomyslnie odczytano plik";
    }


}
