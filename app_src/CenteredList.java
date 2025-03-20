import javax.swing.*;
import java.awt.*;

/**
 * Klasa CenteredList rozszerza DefaultListCellRenderer i umozliwia
 * wysrodkowanie tekstu w elementach listy rozwijanej JComboBox.
 */
public class CenteredList extends DefaultListCellRenderer {
    /**
     * Przeslonieta metoda renderowania komorek listy.
     * Wyrownuje tekst do srodka elementow JComboBox.
     * @param list Lista, do ktorej nalezy renderowana komorka.
     * @param value Wartosc do wyswietlenia.
     * @param index Indeks elementu w liscie.
     * @param isSelected Czy element jest zaznaczony.
     * @param cellHasFocus Czy element ma focus.
     * @return Sformatowany komponent JLabel.
     */
    @Override
    public Component getListCellRendererComponent(
            JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
        JLabel label = (JLabel) super.getListCellRendererComponent(list, value, index, isSelected, cellHasFocus);
        label.setHorizontalAlignment(SwingConstants.CENTER); // Wyrównanie tekstu do środka
        return label;
    }
}
