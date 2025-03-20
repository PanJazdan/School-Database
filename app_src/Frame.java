import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

/**
 * Klasa Frame obsluguje glowne okno aplikacji oraz interfejs uzytkownika.
 * Zawiera elementy UI, takie jak przyciski, pola tekstowe i listy rozwijane,
 * oraz umozliwia interakcje z baza danych za pomoca klasy DataBase.
 */
public class Frame extends JFrame implements ActionListener {

    /**
     * Instancja klasy DataBase do obslugi polaczenia z baza danych.
     */
    DataBase data;

    /**
     * Pola tekstowe do wprowadzania zapytan i warunkow SQL.
     */
    JTextField whereClausule_textField;
    /**
     * Pola tekstowe do wprowadzania zapytan i warunkow SQL.
     */
    JTextField admin_textField;

    /**
     * Obszar tekstowy do wyswietlania wynikow zapytan.
     */
    JTextArea textArea;

    /**
     * Przycisk interakcji z baza danych.
     */
    JButton button;
    /**
     * Przycisk wywolujacy metode insertWindow.
     */
    JButton insertRecord_button;
    /**
     * Przycisk wywolujacy metode deleteWindow.
     */
    JButton deleteRecord_button;
    /**
     * Przycisk wywolujacy metode updateWindow.
     */
    JButton updateRecord_button;
    /**
     * Przycisk wywolujacy generujacy polecenie odnosnie wybranej tabeli.
     */
    JButton function_button;
    /**
     * Przycisk wywolujacy metode accessWindow.
     */
    JButton password_button;
    /**
     * Przycisk resetujacy dostep do podstawowego.
     */
    JButton resetAccess_button;
    /**
     * Przycisk resetujacy baze danych do ustawien poczatkowych.
     */
    JButton resetDatabase_button;
    /**
     * Przycisk powodujacy dodanie przykladowych danych do bazy
     */
    JButton exampleInsert_button;
    /**
     * Przycisk umozliwiajacy dodanie danych w formacie CSV.
     */
    JButton file_csv_button;
    /**
     * Przycisk umozliwiajacy dodanie danych w formacie SQL.
     */
    JButton file_sql_button;

    /**
     * Rozwijane menu zawierajace nazyw tabel.
     */
    JComboBox<String> tableNames_comboBox;
    /**
     * Rozwijane menu zawierajace nazyw kolum.
     */
    JComboBox<String> columnNames_comboBox;
    /**
     * Rozwijane menu zawierajace opisy funkcji.
     */
    JComboBox<String> functionDesc_comboBox;
    /**
     * Rozwijane menu zawierajace rekordy tabeli klasa.
     */
    JComboBox<String> klasa_comboBox;
    /**
     * Rozwijane menu zawierajace rekordy tabeli nauczyciel.
     */
    JComboBox<String> nauczyciel_comboBox;
    /**
     * Rozwijane menu zawierajace rekordy tabeli sala.
     */
    JComboBox<String> sala_comboBox;
    /**
     * Rozwijane menu zawierajace rekordy tabeli uczen.
     */
    JComboBox<String> uczen_comboBox;
    /**
     * Rozwijane menu zawierające rekordy tabeli przedmioty
     */
    JComboBox<String> przedmiot_comboBox;

    /**
     * Pole do zaznaczenia przy warunku WHERE.
     */
    JCheckBox where_checkBox;

    /**
     * Mapa przechowujaca powiazanie identyfikatorow z odpowiednimi listami rozwijanymi.
     */
    Map<String, JComboBox<?>> comboBoxMap = new LinkedHashMap<>();

    /**
     * Lista komponentow UI wymagajacych uprawnien administracyjnych.
     */
    ArrayList<Component> advancedAccessList = new ArrayList<Component>();

    /**
     * Lista list zawierajaca nazwy tabel i kolumn pobrane z bazy danych.
     */
    ArrayList<ArrayList<String>> allColumnTableNames = new ArrayList<ArrayList<String>>();
    /**
     * Lista list zawierajaca nazwy tabel i typow kolumn pobrane z bazy danych.
     */
    ArrayList<ArrayList<String>> allColumnTableTypes = new ArrayList<ArrayList<String>>();

    /**
     * Lista przechowujace nazwy funkcji.
     */
    ArrayList<String> functionNames;
    /**
     * Lista przechowujace opisy funkcji.
     */
    ArrayList<String> functionDesc;

    /**
     * Zmienna uzywana jako output dla funkcji zwracajacych string.
     */
    String outputString;

    /**
     * Zmienna uzywana do wyswietlania tekstu na panelu glownym.
     */
    String textToDisplay;

    private final String ADMIN = "admin";
    private final String ADVANCE = "traktor";

    /**
     * Tworzy okno aplikacji, inicjalizuje polaczenie z baza danych oraz ustawia elementy UI.
     */
    Frame() {
        data = new DataBase();
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(1200, 740);
        this.setLocationRelativeTo(null);

        //Stworzenie panelow i przypisanie im Layoutu
        JPanel optionsPanel = new JPanel();
        JPanel workspacePanel = new JPanel();
        workspacePanel.setLayout(new BorderLayout());
        optionsPanel.setLayout(new GridLayout(29, 1));

        //Utworzenie listy list stringow z nazwami tabel i kolumn
        setAllColumnTableNames();
        setAllColumnTableTypes();

        //Inicjalizacja nazw i opisow funkcji
        functionNames = data.getFunctionNames();
        functionDesc = data.getFunctionDescription();

        String[] functionDesc_array = ListToArray(functionDesc);
        //Dropdown menu z nazwami funkcji
        functionDesc_comboBox = new JComboBox(functionDesc_array);
        {
            functionDesc_comboBox.addActionListener(this);
            functionDesc_comboBox.setEditable(true);
            functionDesc_comboBox.setMaximumSize(new Dimension(300, 30));
            functionDesc_comboBox.setSelectedItem(null);
            functionDesc_comboBox.setRenderer(new CenteredList());
        }
//        for(String str : functionNames)
//            System.out.println(str);

        //Zamienienie nazw z lity na tablice by przekazac ja do dropdown menu
        String[] tableNames_array = new String[allColumnTableNames.size()];
        for (int i = 0; i < tableNames_array.length; i++) {
            tableNames_array[i] = allColumnTableNames.get(i).get(0);
        }

        //Dropdown menu z nazwami tabel
        tableNames_comboBox = new JComboBox(tableNames_array);
        {
            tableNames_comboBox.addActionListener(this);
            tableNames_comboBox.setEditable(true);
            tableNames_comboBox.setMaximumSize(new Dimension(300, 30));
            tableNames_comboBox.setSelectedItem(null);
            tableNames_comboBox.setRenderer(new CenteredList());
        }

        //Dropdown menu z przyszlymi nazwami kolumn w tabeli
        columnNames_comboBox = new JComboBox();
        {
            columnNames_comboBox.addActionListener(this);
            columnNames_comboBox.setEditable(true);
            columnNames_comboBox.setMaximumSize(new Dimension(300, 30));
            columnNames_comboBox.setEnabled(false);
            columnNames_comboBox.setRenderer(new CenteredList());
        }

        String[] klasa_array = ListToArray(data.getOneWholeColumn("klasa", "klasa_num || klasa_letter"));
        klasa_comboBox = new JComboBox(klasa_array);
        {
            klasa_comboBox.addActionListener(this);
            klasa_comboBox.setEditable(true);
            klasa_comboBox.setMaximumSize(new Dimension(300, 30));
            klasa_comboBox.setEnabled(false);
            klasa_comboBox.setRenderer(new CenteredList());
        }

        String[] sala_array = ListToArray(data.getOneWholeColumn("sala", "sala_name"));
        sala_comboBox = new JComboBox(sala_array);
        {
            sala_comboBox.addActionListener(this);
            sala_comboBox.setEditable(true);
            sala_comboBox.setMaximumSize(new Dimension(300, 30));
            sala_comboBox.setEnabled(false);
            sala_comboBox.setRenderer(new CenteredList());
        }

        ArrayList<String> tmp = data.getOneWholeColumn("uczen", "nazwisko || ' ' || imie");
        tmp.add(0, "0     Wszyscy");
        String[] uczenID_array = ListToArray(tmp);
        uczen_comboBox = new JComboBox(uczenID_array);
        {
            uczen_comboBox.addActionListener(this);
            uczen_comboBox.setEditable(true);
            uczen_comboBox.setMaximumSize(new Dimension(300, 30));
            uczen_comboBox.setEnabled(false);
            uczen_comboBox.setRenderer(new CenteredList());
        }

        String[] nauczyciel_array = ListToArray(data.getOneWholeColumn("nauczyciel", "nazwisko || ' ' || imie"));
        nauczyciel_comboBox = new JComboBox(nauczyciel_array);
        {
            nauczyciel_comboBox.addActionListener(this);
            nauczyciel_comboBox.setEditable(true);
            nauczyciel_comboBox.setMaximumSize(new Dimension(300, 30));
            nauczyciel_comboBox.setEnabled(false);
            nauczyciel_comboBox.setRenderer(new CenteredList());
        }

        String[] przedmiot_array = ListToArray(data.getOneWholeColumn("przedmiot", "przedmiot_name"));
        przedmiot_comboBox = new JComboBox(przedmiot_array);
        {
            przedmiot_comboBox.addActionListener(this);
            przedmiot_comboBox.setEditable(true);
            przedmiot_comboBox.setMaximumSize(new Dimension(300, 30));
            przedmiot_comboBox.setEnabled(false);
            przedmiot_comboBox.setRenderer(new CenteredList());
        }


        // Przycisk testowy
        button = new JButton("Wyszukaj");
        button.addActionListener(this);

        insertRecord_button = new JButton("Dodaj rekord");
        insertRecord_button.addActionListener(this);

        deleteRecord_button = new JButton("Usun rekord");
        deleteRecord_button.addActionListener(this);

        updateRecord_button = new JButton("Zmien rekord");
        updateRecord_button.addActionListener(this);

        function_button = new JButton("Pokaz");
        function_button.addActionListener(this);
        function_button.setEnabled(false);

        password_button = new JButton("Zwieksz poziom dostepu");
        password_button.addActionListener(this);
        password_button.setEnabled(true);

        resetAccess_button = new JButton("Resetuj poziom dostepu");
        resetAccess_button.addActionListener(this);
        resetAccess_button.setEnabled(true);

        resetDatabase_button = new JButton("Resetuj baze");
        resetDatabase_button.addActionListener(this);
        resetDatabase_button.setEnabled(true);

        exampleInsert_button = new JButton("Dodanie przykladowych danych");
        exampleInsert_button.addActionListener(this);
        exampleInsert_button.setEnabled(true);

        file_csv_button = new JButton("Wgraj plik CSV");
        file_csv_button.addActionListener(this);
        file_csv_button.setEnabled(false);

        file_sql_button = new JButton("Wgraj plik SQL");
        file_sql_button.addActionListener(this);
        file_sql_button.setEnabled(false);


        //CheckBox do aktywacji klauzuli where
        where_checkBox = new JCheckBox("Aktywuj klauzule WHERE");
        where_checkBox.addActionListener(this);
        where_checkBox.setHorizontalAlignment(SwingConstants.CENTER);

        // Pole tekstowe klauzuli where pola select*
        whereClausule_textField = new JTextField();
        whereClausule_textField.setEnabled(false);

        //Pole tekstowe klauzuli where pola funkcji
        admin_textField = new JTextField();
        admin_textField.setText("UNIWERSALNE POLE DO WPISYWANIA SELECT UPDATE DELETE INSERT --> DOSTEP TYLKO ADMIN");
        admin_textField.addActionListener(this);
        admin_textField.setEnabled(false);


        //Pole tekstowe wyswietlajace odpowiednie rekordy
        textArea = new JTextArea();
        textArea.setFont(new Font("Monospaced", Font.PLAIN, 12));
        textArea.setEditable(false);
        textArea.setLineWrap(true);
        textArea.setWrapStyleWord(true);


        //Podzielenie aplikacji na dwa obszary
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, optionsPanel, workspacePanel);
        splitPane.setDividerLocation(300); // Ustawienie poczatkowej pozycji podzialu
        splitPane.setResizeWeight(0.33);  // Proporcja podzialu (1/3 i 2/3)

        JLabel selectFromLabel = new JLabel("WYBIERZ WSZYSTKO Z TABELI");
        JLabel selectWhereLabel = new JLabel("WARUNEK (WHERE)");
        JLabel selectEqualsLabel = new JLabel("=");
        JLabel spacer1 = new JLabel("-----------");
        JLabel spacer2 = new JLabel("-----------");
        JLabel spacer3 = new JLabel("-----------");
        JLabel spacer4 = new JLabel("-----------");
        JLabel plus = new JLabel("+");
        JLabel pokaz = new JLabel("POKAZ");

        //Ustawianie horizontal alignment
        {
            selectFromLabel.setHorizontalAlignment(SwingConstants.CENTER);
            selectWhereLabel.setHorizontalAlignment(SwingConstants.CENTER);
            selectEqualsLabel.setHorizontalAlignment(SwingConstants.CENTER);
            spacer1.setHorizontalAlignment(SwingConstants.CENTER);
            spacer2.setHorizontalAlignment(SwingConstants.CENTER);
            spacer3.setHorizontalAlignment(SwingConstants.CENTER);
            spacer4.setHorizontalAlignment(SwingConstants.CENTER);
            plus.setHorizontalAlignment(SwingConstants.CENTER);
            pokaz.setHorizontalAlignment(SwingConstants.CENTER);
        }

        //Dodawanie componentow UI do listy zwiekszonego dostepu
        {
            advancedAccessList.add(tableNames_comboBox);
            advancedAccessList.add(where_checkBox);
            advancedAccessList.add(columnNames_comboBox);
            advancedAccessList.add(whereClausule_textField);
            advancedAccessList.add(button);
            advancedAccessList.add(insertRecord_button);
            advancedAccessList.add(deleteRecord_button);
            advancedAccessList.add(updateRecord_button);
            advancedAccessList.add(file_csv_button);
            advancedAccessList.add(file_sql_button);
        }

        for(Component comp : advancedAccessList){
            comp.setEnabled(false);
        }

        //Dodawanie elementow do paneli
        {
            optionsPanel.add(pokaz);
            optionsPanel.add(functionDesc_comboBox);
            optionsPanel.add(plus);
            optionsPanel.add(klasa_comboBox);
            optionsPanel.add(sala_comboBox);
            optionsPanel.add(nauczyciel_comboBox);
            optionsPanel.add(uczen_comboBox);
            optionsPanel.add(przedmiot_comboBox);
            optionsPanel.add(function_button);
            optionsPanel.add(spacer1);
            optionsPanel.add(selectFromLabel);
            optionsPanel.add(tableNames_comboBox);
            optionsPanel.add(where_checkBox);
            optionsPanel.add(selectWhereLabel);
            optionsPanel.add(columnNames_comboBox);
            optionsPanel.add(selectEqualsLabel);
            optionsPanel.add(whereClausule_textField);
            optionsPanel.add(button);
            optionsPanel.add(spacer2);
            optionsPanel.add(insertRecord_button);
            optionsPanel.add(deleteRecord_button);
            optionsPanel.add(updateRecord_button);
            optionsPanel.add(file_csv_button);
            optionsPanel.add(file_sql_button);
            optionsPanel.add(spacer3);
            optionsPanel.add(password_button);
            optionsPanel.add(resetAccess_button);
            optionsPanel.add(resetDatabase_button);
            optionsPanel.add(exampleInsert_button);
            workspacePanel.add(new JScrollPane(textArea));
            workspacePanel.add(admin_textField, BorderLayout.SOUTH);
        }


        this.add(splitPane);

        this.setVisible(true);
    }

    /**
     * Konwertuje liste ArrayList na tablice String[].
     * @param list Lista do przeksztalcenia.
     * @return Tablica String[] zawierajaca elementy przekazanej listy.
     */
    //Zamiana Listy na Tablice
    private String[] ListToArray(ArrayList<String> list) {

        String[] array = new String[list.size()];
        for (int i = 0; i < list.size(); i++) {
            array[i] = list.get(i);
        }
        return array;
    }

    /**
     * Tworzy liste list zawierajaca nazwy tabel oraz ich kolumny.
     * Pobiera informacje z bazy danych za pomoca metody getTableNames() i getColumnNames().
     * Kazdy element listy glownej odpowiada jednej tabeli i zawiera jej nazwe oraz nazwy jej kolumn.
     */
    //Stworzenie Listy List z nazwami tabel i ich kolumnami
    private void setAllColumnTableNames() {
        ArrayList<String> tableNames = data.getTableNames();
        int index = 0;
        for (String table : tableNames) {
            allColumnTableNames.add(new ArrayList<String>());
            allColumnTableNames.get(index).add(table);
            ArrayList<String> columnNames = data.getColumnNames(table);
            for (String column : columnNames) {
                allColumnTableNames.get(index).add(column);
            }
            index++;
        }
//        System.out.println(allColumnTableNames);
    }

    /**
     * Tworzy liste list zawierajaca nazwy tabel oraz typy ich kolumn.
     * Pobiera z bazy danych informacje o typach kolumn oraz o tym, czy moga przyjmowac wartosci NULL.
     * Kazdy element listy glownej odpowiada jednej tabeli i zawiera jej nazwe oraz typy kolumn w formacie "typ NULL/NOT NULL".
     */
    private void setAllColumnTableTypes() {
        ArrayList<String> tableNames = data.getTableNames();
        int index = 0;
        for (String table : tableNames) {
            allColumnTableTypes.add(new ArrayList<String>());
            allColumnTableTypes.get(index).add(table);
            ArrayList<String> columnTypes = data.getColumnTypes(table);
            ArrayList<String> columnNulls = data.getColumnNullable(table);
            for (int i = 0; i < columnTypes.size(); i++) {
                allColumnTableTypes.get(index).add(columnTypes.get(i) + " " + columnNulls.get(i));
            }
            index++;
        }
    }

    /**
     * Obsluguje zdarzenia akcji dla przyciskow i komponentow UI.
     * @param e Obiekt zdarzenia akcji.
     */
    @Override
    public void actionPerformed(ActionEvent e) {
        if (e.getSource() == button) {
//            System.out.println(whereClausule_textField.getText());
            this.outputString = whereClausule_textField.getText();
            String select = "SELECT * FROM ";
            String table = tableNames_comboBox.getSelectedItem().toString();
            String column;
            String command = select + table;
            if (where_checkBox.isSelected()) {
                column = columnNames_comboBox.getSelectedItem().toString();
                command = command + " WHERE " + column + " = " + "'" + outputString + "'";
            }
            textToDisplay = data.ExecuteCommand(command);
            textArea.setText("\n" + textToDisplay);
        }

        if (e.getSource() == where_checkBox) {
            if (where_checkBox.isSelected()) {
                columnNames_comboBox.setEnabled(true);
                whereClausule_textField.setEnabled(true);
            } else {
                columnNames_comboBox.setEnabled(false);
                whereClausule_textField.setEnabled(false);
            }
        }

        if (e.getSource() == tableNames_comboBox && tableNames_comboBox.getSelectedItem() != null) {
            //Usuniecie poprzednio istniejacych nazw z dropdown menu
            if (columnNames_comboBox.getItemCount() > 0) {
                columnNames_comboBox.removeAllItems();
            }
            columnNames_comboBox.addItem("");
            //Dodanie nazw kolumn do dropdown menu z listy list stringow wszystkich nazw kolumn
            for (ArrayList<String> stringList : allColumnTableNames) {
                if (Objects.equals(stringList.get(0), tableNames_comboBox.getSelectedItem().toString())) {
                    for (int i = 1; i < stringList.size(); i++) {
                        columnNames_comboBox.addItem(stringList.get(i));
                    }
                }
            }
            columnNames_comboBox.setSelectedItem(null);
        }

        if (e.getSource() == columnNames_comboBox) {
            if (columnNames_comboBox.getSelectedItem() != null && !columnNames_comboBox.getSelectedItem().toString().isEmpty()) {
//                System.out.println("udalo sie");
            }
        }

        if (e.getSource() == insertRecord_button) {
            closeAllOtherWindows();
            insertWindow();
        }

        if (e.getSource() == deleteRecord_button) {
            closeAllOtherWindows();
            deleteWindow();

        }

        if(e.getSource() == updateRecord_button){
            closeAllOtherWindows();
            updateWindow();
        }


        if (e.getSource() == functionDesc_comboBox && functionDesc_comboBox.getSelectedItem() != null) {
            function_button.setEnabled(true);

            String selectedText = functionDesc_comboBox.getSelectedItem().toString();
//            int position = selectedText.indexOf(':');
//
//            if(position>0){
//                key = selectedText.substring(0, position);
//            }


            comboBoxMap.put("IDk", klasa_comboBox);
            comboBoxMap.put("IDu", uczen_comboBox);
            comboBoxMap.put("IDs", sala_comboBox);
            comboBoxMap.put("IDn", nauczyciel_comboBox);
            comboBoxMap.put("IDp", przedmiot_comboBox);

            klasa_comboBox.setEnabled(false);
            uczen_comboBox.setEnabled(false);
            sala_comboBox.setEnabled(false);
            nauczyciel_comboBox.setEnabled(false);
            przedmiot_comboBox.setEnabled(false);

//            String key = new String();
            comboBoxMap.forEach((k,v) -> {if(selectedText.contains(k)){
                comboBoxMap.get(k).setEnabled(true);
            }});
//            if (comboBoxMap.containsKey(key)) {
//                comboBoxMap.get(key).setEnabled(true);
//            }
        }

        if (e.getSource() == function_button) {
            int index = functionDesc_comboBox.getSelectedIndex();

            String selectedText = functionDesc_comboBox.getSelectedItem().toString();
            int position;
            String key;
            String argument = "";
            boolean flag = false;
            for (Map.Entry<String, JComboBox<?>> pair : comboBoxMap.entrySet()) {
                if(pair.getValue().isEnabled()){
                    flag = true;
                    position = pair.getValue().getSelectedItem().toString().indexOf(' ');
                    String id = pair.getValue().getSelectedItem().toString().substring(0,position);
                    argument = argument + id + ",";
                }
            }

            if (flag) {
                argument = argument.substring(0, argument.length() - 1);
            }


            if ((selectedText.equals("IDu:   Pokaz nieobecnosci ucznia") || selectedText.equals("IDuIDp:   Pokaz szczegoly ocen ucznia")) && argument.charAt(0)=='0') {
                textArea.setText("\nNie mozna pokazac nieobecnosci dla wszystkich uczniow\n     Wybierz konkretnego ucznia");
            } else {
                String commmand = "SELECT * FROM " + functionNames.get(index) + "(" + argument + ")";
                textToDisplay = data.ExecuteCommand(commmand);
                textArea.setText("\n" + textToDisplay);
            }
        }

        if (e.getSource() == admin_textField){
            String command = admin_textField.getText();
            if (!command.isEmpty() && Character.isWhitespace(command.charAt(0))){
                textArea.setText("W polu musi byc cos napisane lub usun bialy znak z poczatku linii");
                return;
            }
            int position = command.indexOf(' ');
            if(position==-1){
                textArea.setText("\nBLAD WE WPROWADZONEJ KOMENDZIE");
                return;
            }
            String condition = command.substring(0,position).toUpperCase();

            if(condition.equals("SELECT")){
                textToDisplay = data.ExecuteCommand(command);
                textArea.setText("\n" + textToDisplay);
            } else if (condition.equals("INSERT")) {
                textToDisplay =data.InsertCommand(command);
                textArea.setText("\n" + textToDisplay);
            } else if (condition.equals("DELETE")) {
                textToDisplay =data.DeleteCommand(command);
                textArea.setText("\n" + textToDisplay);
            } else if (condition.equals("UPDATE")) {
                textToDisplay =data.UpdateCommand(command);
                textArea.setText("\n" + textToDisplay);
            } else {
                textArea.setText("\nBLAD WE WPROWADZONEJ KOMENDZIE");
            }

        }

        if(e.getSource() == password_button){
            accessWindows();
        }

        if(e.getSource() == resetAccess_button){
            for(Component comp : advancedAccessList){
                comp.setEnabled(false);
            }
            admin_textField.setEnabled(false);
        }

        if (e.getSource() == resetDatabase_button){
            textToDisplay = data.RunFile("src\\delete.sql");
            textToDisplay = textToDisplay + "\n" + data.RunFile("src\\insert0.sql");
            textToDisplay = textToDisplay + "\n" + data.RunFile("src\\plan.sql");
            updateComboBoxes();
            textArea.setText(textToDisplay + "\nZreseotwano Baze");
        }

        if(e.getSource() == exampleInsert_button){
            textToDisplay = data.RunFile("src\\insert1.sql");
            if (textToDisplay.charAt(0) == '0') {
                updateComboBoxes();
                textToDisplay = textToDisplay +  "\nDodano przykladowe dane jak: 1 Klasa, 15 Uczen, 35 Plan, 30 Ocena, 30 Nieobecnosc";
            }
                textArea.setText(textToDisplay);

        }

        if(e.getSource() == file_csv_button){
            JFileChooser fileChooser = new JFileChooser();
            fileChooser.setCurrentDirectory(new File(System.getProperty("user.home"))); // Ustaw katalog domyslny
            int returnValue = fileChooser.showOpenDialog(this);

            if (returnValue == JFileChooser.APPROVE_OPTION) {
                File file = fileChooser.getSelectedFile();
                try {
                    String sqlInsert = convertCsvToInsert(file);

                    textArea.setText(data.InsertCommand(sqlInsert));
                } catch (IOException ex) {
                    textArea.setText("Blad wczytywania pliku:\n" + ex.getMessage());
                }

            }
        }

        if(e.getSource() == file_sql_button){
            JFileChooser fileChooser = new JFileChooser();
            fileChooser.setCurrentDirectory(new File(System.getProperty("user.home"))); // Ustaw katalog domyslny
            int returnValue = fileChooser.showOpenDialog(this);

            if (returnValue == JFileChooser.APPROVE_OPTION) {
                File file = fileChooser.getSelectedFile();

                textToDisplay = data.RunFile(file.getAbsolutePath());
                if (textToDisplay.charAt(0) == '0') {
                    updateComboBoxes();
                }
                textArea.setText(textToDisplay);
            }
        }
    }

    /**
     * Tworzy i wyswietla okno dialogowe do wprowadzania hasla w celu uzyskania dostepu do zaawansowanych funkcji.
     * Uzytkownik moze wprowadzic haslo administratora lub poziomu zaawansowanego, aby odblokowac dodatkowe opcje.
     * Po poprawnym wpisaniu hasla, odpowiednie komponenty interfejsu zostaja odblokowane.
     */
    private void accessWindows() {
        JDialog dialogWindow = new JDialog(this, "ACCESS WINDOW", true);  // true oznacza tryb modalny
        dialogWindow.setSize(200, 100);
        dialogWindow.setLocationRelativeTo(this);
        dialogWindow.setLayout(new GridLayout(3,1));

        dialogWindow.setLocation(this.getLocation().x+(int)this.getSize().getWidth()/2,this.getLocation().y+(int)this.getSize().getHeight()/2);

        JTextField passwd_textField = new JTextField("Wpisz haslo");
        JButton passwdDialog_button = new JButton("Sprawdz");
        JTextArea passwd_textArea = new JTextArea();
        passwd_textArea.setEditable(false);

        passwdDialog_button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String password = passwd_textField.getText();
                if(password.isEmpty()){
                    passwd_textArea.setText("Wpisz haslo");
                }else if (password.equals(ADMIN)){
                    admin_textField.setEnabled(true);
                    for(Component comp : advancedAccessList){
                        comp.setEnabled(true);
                    }
                    textArea.setText("\n\nZALOGOWANO JAKO ADMIN");
                    dialogWindow.dispose();
                } else if (password.equals(ADVANCE)) {
                    for(Component comp : advancedAccessList){
                        comp.setEnabled(true);
                    }
                    textArea.setText("\n\nZWIEKSZONO DOSTEP, ODBLOKOWANO NOWE ELEMENTY");
                    dialogWindow.dispose();
                }
                else {
                    passwd_textArea.setText("Bledne Haslo");
                }
            }
        });


        dialogWindow.add(passwd_textField);
        dialogWindow.add(passwdDialog_button);
        dialogWindow.add(passwd_textArea);
        dialogWindow.setVisible(true);
    }

    /**
     * Wyswietla okno dialogowe do dodawania rekordow do bazy danych.
     * Pozwala uzytkownikowi wybrac tabele i wprowadzic wartosci do pol.
     */
    private void insertWindow() {
        JFrame inputDialog = new JFrame("INSERT WINDOW");
        inputDialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        inputDialog.setSize(300, 400);
        inputDialog.setLocationRelativeTo(this);
        inputDialog.setAlwaysOnTop(true);

        inputDialog.setLocation(this.getLocation().x+(int)this.getSize().getWidth()/2,this.getLocation().y+(int)this.getSize().getHeight()/2);

        String[] tableNames_array = new String[allColumnTableNames.size()];
        for (int i = 0; i < tableNames_array.length; i++) {
            tableNames_array[i] = allColumnTableNames.get(i).get(0);
        }

        JPanel panel = new JPanel(new BorderLayout());
        JPanel top_panel = new JPanel(new GridLayout(2,1));
        GridLayout grid = new GridLayout();
        JPanel center_panel = new JPanel(grid);

        ArrayList<JCheckBox> checkbox_list = new ArrayList<JCheckBox>();
        ArrayList<JTextField> textField_list = new ArrayList<JTextField>();

        JButton insert_button = new JButton("DODAJ");
        insert_button.setEnabled(false);

        //Dropdown menu z nazwami tabel
        JComboBox insertTableNames_comboBox = new JComboBox(tableNames_array);
        insertTableNames_comboBox.setSelectedItem(null);
        insertTableNames_comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                insert_button.setEnabled(true);
                center_panel.removeAll();
                checkbox_list.clear();
                textField_list.clear();
                //Dynamiczne tworzenie pojawiania sie checkboxow i pol do wypelnienia
                for (int i = 0; i < allColumnTableNames.size(); i++) {
                    //Warunek sprawdzajacy czy to co zaznaczylem z dropdown menu jest tym co szukam w tablicy wszystkich nazw
                    if (insertTableNames_comboBox.getSelectedItem() == allColumnTableNames.get(i).get(0)) {
                        //Tworzy tymczasowe zmienne dla wygody
                        ArrayList<String> table = allColumnTableNames.get(i);
                        ArrayList<String> types = allColumnTableTypes.get(i);
                        int size = table.size();
//                        System.out.println(size);
                        //Ustawiam dynamicznie layout zalezny od elementow w tabeli
                        int begin_index = 2;
                        grid.setRows(size - 2); //pomniejszam o dwa bo wiekszosc tabel ma jako pierwsza kolumne automatycznie generowane id a drugie pomniejszenie to po prostu size-1 musi byc
                        grid.setColumns(3);
                        if (table.get(0).equals("oplaty")) {
                            size = size - 1;
                        }
                        if (table.get(0).equals("nauczyciel_przedmiot")) {
                            grid.setRows(size - 1);
                            begin_index = 1;
                        }
                        for (int j = begin_index; j < size; j++) {
                            JCheckBox check = new JCheckBox(table.get(j));
                            check.setSelected(true);
                            JTextField text = new JTextField();
                            //Dodaje akcje do zaznaczania checkboxow
                            check.addActionListener(new ActionListener() {
                                @Override
                                public void actionPerformed(ActionEvent e) {
                                    text.setEnabled(check.isSelected());
                                }
                            });
                            JLabel varType = new JLabel(types.get(j));
                            checkbox_list.add(check);
                            textField_list.add(text);
                            center_panel.add(check);
                            center_panel.add(text);
                            center_panel.add(varType);
                        }
                        break;
                    }
                }

                center_panel.revalidate(); // Odswiezenie ukladu
                center_panel.repaint();
            }
        });


        insert_button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String returnString = "INSERT INTO ";
                String tableName = insertTableNames_comboBox.getSelectedItem().toString();
                String columns = "(";
                String values = " VALUES (";
                for (int i = 0; i < grid.getRows(); i++) {
                    if (checkbox_list.get(i).isSelected()) {
                        columns = columns + checkbox_list.get(i).getText() + ",";
                        values = values + "'" + textField_list.get(i).getText() + "'" + ",";
                    }
                }
                if (columns.charAt(columns.length() - 1) == ',') {
                    columns = columns.substring(0, columns.length() - 1);
                }
                if (values.charAt(values.length() - 1) == ',') {
                    values = values.substring(0, values.length() - 1);
                }
                columns = columns + ")";
                values = values + ")";
                returnString = returnString + tableName + columns + values;

                String result = data.InsertCommand(returnString);

                if (result.charAt(0) == '0') {
                    updateComboBoxes();
                }

                textArea.setText("\n" + result);
//                System.out.println(returnString);
            }
        });

        JLabel label1 = new JLabel("DODAJ DO TABELI");
        label1.setHorizontalAlignment(SwingConstants.CENTER);

        top_panel.add(label1);
        top_panel.add(insertTableNames_comboBox);
        panel.add(top_panel, BorderLayout.NORTH);
        panel.add(center_panel, BorderLayout.CENTER);
        panel.add(insert_button, BorderLayout.SOUTH);

        insertTableNames_comboBox.setEditable(true);
        inputDialog.add(panel);


        inputDialog.setVisible(true);

    }

    /**
     * Wyswietla okno dialogowe do usuwania rekordow na podstawie warunku WHERE.
     * Uzytkownik wybiera tabele i kolumne, po ktorej ma nastapic usuniecie.
     */
    private void deleteWindow() {
        JFrame inputDialog = new JFrame("DELETE WINDOW");
        inputDialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        inputDialog.setSize(300, 200);
        inputDialog.setLocationRelativeTo(this);
        inputDialog.setAlwaysOnTop(true);

        inputDialog.setLocation(this.getLocation().x+(int)this.getSize().getWidth()/2,this.getLocation().y+(int)this.getSize().getHeight()/2);

        String[] tableNames_array = new String[allColumnTableNames.size()];
        for (int i = 0; i < tableNames_array.length; i++) {
            tableNames_array[i] = allColumnTableNames.get(i).get(0);
        }

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(7,1));
        JComboBox<String> deleteTable_comboBox = new JComboBox<String>();
        JComboBox<String> deleteColumn_comboBox = new JComboBox<String>();

        deleteTable_comboBox.setMaximumSize(new Dimension(200, 50));
        deleteColumn_comboBox.setMaximumSize(new Dimension(200, 50));

        JLabel label1 = new JLabel("USUN Z TABELI");
        label1.setHorizontalAlignment(SwingConstants.CENTER);
        JLabel label2 = new JLabel("WARUNEK (WHERE)");
        label2.setHorizontalAlignment(SwingConstants.CENTER);
        JLabel label3 = new JLabel("=");
        label3.setHorizontalAlignment(SwingConstants.CENTER);

        JTextField deleteText_textField = new JTextField();

        JButton deleteButton_button = new JButton("USUN");
        deleteButton_button.setEnabled(false);

        for (int i = 0; i < tableNames_comboBox.getItemCount(); i++) {
            deleteTable_comboBox.addItem(tableNames_comboBox.getItemAt(i));
        }

        deleteTable_comboBox.setSelectedItem(null);
        deleteTable_comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if (deleteTable_comboBox.getSelectedItem() != null) {
//                    System.out.println("+");

                    if (deleteColumn_comboBox.getItemCount() > 0) {
                        deleteColumn_comboBox.removeAllItems();
                    }
                    deleteColumn_comboBox.addItem("");
                    //Dodanie nazw kolumn do dropdown menu z listy list stringow wszystkich nazw kolumn
                    for (ArrayList<String> stringList : allColumnTableNames) {
                        if (Objects.equals(stringList.get(0), deleteTable_comboBox.getSelectedItem().toString())) {
                            for (int i = 1; i < stringList.size(); i++) {
                                deleteColumn_comboBox.addItem(stringList.get(i));
                            }
                        }
                    }
                    deleteColumn_comboBox.setSelectedItem(null);
                }
            }
        });

        deleteColumn_comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if (deleteColumn_comboBox.getSelectedItem() != null && !deleteColumn_comboBox.getSelectedItem().toString().isEmpty()) {
//                    System.out.println("udalo sie");
                    deleteButton_button.setEnabled(true);
                }
            }
        });

        deleteButton_button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String table = deleteTable_comboBox.getSelectedItem().toString();
                String column = deleteColumn_comboBox.getSelectedItem().toString();
                String condition = "'" + deleteText_textField.getText() + "'";
                String command = "DELETE FROM " + table + " WHERE " + column + " = " + condition;
//                System.out.println(command);
                String result = data.DeleteCommand(command);

                if (result.charAt(0) == '0') {
                    updateComboBoxes();
                }

                textArea.setText("\n" + result);

            }
        });

        panel.add(label1);
        panel.add(deleteTable_comboBox);
        panel.add(label2);
        panel.add(deleteColumn_comboBox);
        panel.add(label3);
        panel.add(deleteText_textField);
        panel.add(deleteButton_button);

        inputDialog.add(panel);

        inputDialog.setVisible(true);
    }

    /**
     * Wyswietla okno dialogowe do edytowania rekordow na podstawie warunku WHERE.
     * Pozwala uzytkownikowi wybrac tabele i zaktualizowac konkretne kolumny.
     */
    private void updateWindow() {
        JFrame inputDialog = new JFrame("UPDATE WINDOW");
        inputDialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        inputDialog.setSize(300, 500);
        inputDialog.setLocationRelativeTo(this);
        inputDialog.setAlwaysOnTop(true);

        inputDialog.setLocation(this.getLocation().x+(int)this.getSize().getWidth()/2,this.getLocation().y+(int)this.getSize().getHeight()/2 - 100);

        String[] tableNames_array = new String[allColumnTableNames.size()];
        for (int i = 0; i < tableNames_array.length; i++) {
            tableNames_array[i] = allColumnTableNames.get(i).get(0);
        }

        JPanel panel = new JPanel(new BorderLayout());
        JPanel top_panel = new JPanel(new GridLayout(2,1));
        JPanel bottom_panel = new JPanel(new GridLayout(5,1));
        GridLayout grid = new GridLayout();
        JPanel center_panel = new JPanel(grid);

        JLabel tabelaLabel = new JLabel("TABELA");
        JLabel warunekLabel = new JLabel("WARUNEK ZMIANY (WHERE)");
        JLabel rownaLabel = new JLabel("=");

        tabelaLabel.setHorizontalAlignment(SwingConstants.CENTER);
        warunekLabel.setHorizontalAlignment(SwingConstants.CENTER);
        rownaLabel.setHorizontalAlignment(SwingConstants.CENTER);

        JTextField whereTextField = new JTextField("WPISZ WARUNEK PO KTORYM SZUKASZ");

        ArrayList<JCheckBox> checkbox_list = new ArrayList<JCheckBox>();
        ArrayList<JTextField> textField_list = new ArrayList<JTextField>();

        JButton update_button = new JButton("ZMIEN");
        update_button.setEnabled(false);

        JComboBox<String> updateColumn_comboBox = new JComboBox<String>();
        updateColumn_comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                update_button.setEnabled(true);
            }
        });

        //Dropdown menu z nazwami tabel
        JComboBox updateTableNames_comboBox = new JComboBox(tableNames_array);
        updateTableNames_comboBox.setSelectedItem(null);
        updateTableNames_comboBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                center_panel.removeAll();
                checkbox_list.clear();
                textField_list.clear();
                //Dynamiczne tworzenie pojawiania sie checkboxow i pol do wypelnienia
                for (int i = 0; i < allColumnTableNames.size(); i++) {
                    //Warunek sprawdzajacy czy to co zaznaczylem z dropdown menu jest tym co szukam w tablicy wszystkich nazw
                    if (updateTableNames_comboBox.getSelectedItem() == allColumnTableNames.get(i).get(0)) {
                        //Tworzy tymczasowe zmienne dla wygody
                        ArrayList<String> table = allColumnTableNames.get(i);
                        ArrayList<String> types = allColumnTableTypes.get(i);
                        int size = table.size();
//                        System.out.println(size);
                        //Ustawiam dynamicznie layout zalezny od elementow w tabeli
                        int begin_index = 2;
                        grid.setRows(size - 2); //pomniejszam o dwa bo wiekszosc tabel ma jako pierwsza kolumne automatycznie generowane id a drugie pomniejszenie to po prostu size-1 musi byc
                        grid.setColumns(3);
                        if (table.get(0).equals("oplaty")) {
                            size = size - 1;
                        }
                        if (table.get(0).equals("nauczyciel_przedmiot")) {
                            grid.setRows(size - 1);
                            begin_index = 1;
                        }
                        for (int j = begin_index; j < size; j++) {
                            JCheckBox check = new JCheckBox(table.get(j));
                            check.setSelected(true);
                            JTextField text = new JTextField();
                            //Dodaje akcje do zaznaczania checkboxow
                            check.addActionListener(new ActionListener() {
                                @Override
                                public void actionPerformed(ActionEvent e) {
                                    text.setEnabled(check.isSelected());
                                }
                            });

                            JLabel varType = new JLabel(types.get(j));
                            checkbox_list.add(check);
                            textField_list.add(text);
                            center_panel.add(check);
                            center_panel.add(text);
                            center_panel.add(varType);
                        }
                        if (updateTableNames_comboBox.getSelectedItem() != null) {

                            if (updateColumn_comboBox.getItemCount() > 0) {
                                updateColumn_comboBox.removeAllItems();
                            }
//                            updateColumn_comboBox.addItem("");
                            //Dodanie nazw kolumn do dropdown menu z listy list stringow wszystkich nazw kolumn
                            for (ArrayList<String> stringList : allColumnTableNames) {
                                if (Objects.equals(stringList.get(0), updateTableNames_comboBox.getSelectedItem().toString())) {
                                    for (int j = 1; j < stringList.size(); j++) {
                                        updateColumn_comboBox.addItem(stringList.get(j));
                                    }
                                }
                            }
                            updateColumn_comboBox.setSelectedItem(null);
                        }
                        break;
                    }
                }

                center_panel.revalidate(); // Odswiezenie ukladu
                center_panel.repaint();
            }
        });


        update_button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String command = "UPDATE ";
                String tableName = updateTableNames_comboBox.getSelectedItem().toString();
                String set = " SET ";
                int rows = grid.getRows();
                if(tableName.equals("oplaty")){
                    rows=rows-1;
                }
                command = command + tableName + set;
                for (int i = 0; i < rows; i++) {
                    if (checkbox_list.get(i).isSelected()) {
                        command = command + checkbox_list.get(i).getText() +
                                "=" + "'" + textField_list.get(i).getText() + "'" + ",";
                    }
                }

                if (command.charAt(command.length() - 1) == ',') {
                    command = command.substring(0, command.length() - 1);
                }

                command = command + " WHERE " + updateColumn_comboBox.getSelectedItem().toString() + " = " + whereTextField.getText();

                String result = data.UpdateCommand(command);

                if (result.charAt(0) == '0') {
                    updateComboBoxes();
                }

                textArea.setText("\n" + result);
//                System.out.println(command);
            }
        });

        top_panel.add(tabelaLabel);
        top_panel.add(updateTableNames_comboBox);
        bottom_panel.add(warunekLabel);
        bottom_panel.add(updateColumn_comboBox);
        bottom_panel.add(rownaLabel);
        bottom_panel.add(whereTextField);
        bottom_panel.add(update_button);
        panel.add(top_panel, BorderLayout.NORTH);
        panel.add(center_panel, BorderLayout.CENTER);
        panel.add(bottom_panel,BorderLayout.SOUTH);

        updateTableNames_comboBox.setEditable(true);
        inputDialog.add(panel);


        inputDialog.setVisible(true);

    }

    /**
     * Dodaje elementy z listy do podanego komponentu JComboBox.
     * @param comboBox Lista rozwijana, do ktorej maja zostac dodane elementy.
     * @param items Lista elementow do dodania.
     */
    private void addItemsToComboBox(JComboBox<String> comboBox, ArrayList<String> items) {
        for (String item : items) {
            comboBox.addItem(item);
        }
    }

    /**
     * Zamyka wszystkie otwarte okna aplikacji poza glownym oknem.
     * Zapobiega pozostawieniu niepotrzebnych okien dialogowych otwartych w tle.
     */
    private void closeAllOtherWindows() {
        for (Window window : JFrame.getWindows()) {
            if (window != this) {
                window.dispose();
            }
        }
    }

    /**
     * Aktualizuje zawartosc list rozwijanych (JComboBox) na podstawie aktualnych danych w bazie.
     * Pobiera dane z tabel i odswieza liste dostepnych klas, nauczycieli, uczniow oraz sal.
     * Po aktualizacji elementy ponownie staja sie widoczne.
     */
    private void updateComboBoxes() {
        klasa_comboBox.setVisible(false);
        nauczyciel_comboBox.setVisible(false);
        uczen_comboBox.setVisible(false);
        sala_comboBox.setVisible(false);

        klasa_comboBox.removeAllItems();
        nauczyciel_comboBox.removeAllItems();
        uczen_comboBox.removeAllItems();
        sala_comboBox.removeAllItems();

        uczen_comboBox.addItem("0     Wszyscy");

        addItemsToComboBox(klasa_comboBox, data.getOneWholeColumn("klasa", "klasa_num || klasa_letter"));
        addItemsToComboBox(sala_comboBox, data.getOneWholeColumn("sala", "sala_name"));
        addItemsToComboBox(uczen_comboBox, data.getOneWholeColumn("uczen", "nazwisko || ' ' || imie"));
        addItemsToComboBox(nauczyciel_comboBox, data.getOneWholeColumn("nauczyciel", "nazwisko || ' ' || imie"));

        klasa_comboBox.setVisible(true);
        nauczyciel_comboBox.setVisible(true);
        uczen_comboBox.setVisible(true);
        sala_comboBox.setVisible(true);
    }

    /**
     * Konwertuje plik CSV na zapytanie SQL INSERT.
     * @param file Plik CSV do przetworzenia.
     * @return Zapytanie SQL INSERT w postaci tekstowej.
     */
    private static String convertCsvToInsert(File file) throws IOException {
        ArrayList<String> lines = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                lines.add(line);
            }
        }

        if (lines.size() < 3) {
            throw new IOException("Plik CSV ma za malo linii.");
        }

        String tableName = lines.get(0).trim();
        String columns = lines.get(1).trim();
        ArrayList<String> values = new ArrayList<>();

        for (int i = 2; i < lines.size(); i++) {
            String[] rowData = lines.get(i).split(",");
            for (int j = 0; j < rowData.length; j++) {
                rowData[j] = "'" + rowData[j].trim().replace("'", "''") + "'";
            }
            values.add("(" + String.join(", ", rowData) + ")");
        }

        return "INSERT INTO " + tableName + " (" + columns + ") VALUES " + String.join(", ", values) ;
    }
}
