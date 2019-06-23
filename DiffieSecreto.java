import java.math.*;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.util.Scanner;
class DiffieSecreto {
    public static void main(String[] args) {        
        try
        {
        //SE GENERAN LOS ARCHIVOS DONDE SERAN ALMACENADOS LOS RESULTADOS PARA EL CLIENTE Y EL SERVIDOR
        //CABE DESTACAR QUE NO POSEE AYUDA YA QUE SE USA DE MANERA INTERNA CON EL SCRIPT DIFFIE-HELLMAN DESARROLLADO EN RUBY
        FileWriter archivoCliente = new FileWriter("./salidaCliente.txt");
        FileWriter archivoServidor = new FileWriter("./salidaServidor.txt");
        
        //ESTA ES LA SECCIÓN DEL CLIENTE
        //AQUI SE OBTIENE EL SECRETO DEL CLIENTE DE LA LINEA DE COMANDOS
        int secretoCliente =Integer.parseInt(args[0]);
        //SE OBTIENE EL VALOR PUBLICO DEL SERVIDOR
        BigInteger valorPublico = new BigInteger(args[1]);
        //SE OBTIENE EL MODULO PRIMO PARA AMBAS PARTES
        BigInteger moduloPrimo = new BigInteger(args[2]);
        //SE CALCULA EL VALOR PUBLICO DEL SERVIDOR ELEVADO A LA POTENCIA DEL SECRETO DEL CLIENTE
        BigInteger potenciaCliente  = valorPublico.pow(secretoCliente);
        //SE CALCULA EL RESULTADO CALCULANDO EL MODULO DE LA OPERACION ANTERIOR FRENTE AL NUMERO PRIMO
        BigInteger resultado = potenciaCliente.mod(moduloPrimo);
        //SE ESCRIBE EL RESULTADO Y SE CIERRA EL ARCHIVO
        archivoCliente.write(resultado.toString());
        archivoCliente.close();
        //ESTA ES LA SECCIÓN DEL SERVIDOR
        //AQUI SE OBTIENE EL SECRETO DEL SERVIDOR DE LA LINEA DE COMANDOS
        int secretoServidor =Integer.parseInt(args[3]);
        //SE OBTIENE EL VALOR PUBLICO DEL CLIENTE
        BigInteger valorPublico2 = new BigInteger(args[4]);
        //SE CALCULA EL VALOR PUBLICO DEL CLIENTE ELEVADO A LA POTENCIA DEL SECRETO DEL SERVIDOR
        BigInteger potenciaServidor  = valorPublico2.pow(secretoServidor);
        //SE CALCULA EL RESULTADO CALCULANDO EL MODULO DE LA OPERACION ANTERIOR FRENTE AL NUMERO PRIMO
        BigInteger resultado2 = potenciaServidor.mod(moduloPrimo);
        //SE ESCRIBE EL RESULTADO Y SE CIERRA EL ARCHIVO
        archivoServidor.write(resultado2.toString());
        archivoServidor.close();
        }
        catch(Exception ex){
            ex.printStackTrace();
        }
    }
}
