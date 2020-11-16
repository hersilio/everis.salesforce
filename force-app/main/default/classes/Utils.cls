public class Utils {
    public static Boolean ValidCnpj(String cnpj) {
        return cnpj != null && RemoveCharacters(cnpj).length() == 14;
    }

    public static Boolean ValidCpf(String cpf) {
        return cpf != null && RemoveCharacters(cpf).length() == 11;
    }

    public static string RemoveCharacters(String value){
        return value.replaceAll('[^0-9]','');
    }
}
