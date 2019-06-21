#Aqui se utiliza el protocolo de estación a estación

#LA SIGUIENTE LIBRERIA PERMITE TRABAJAR LOS NUMEROS PRIMOS, SE ENCUENTRA INTEGRADA EN RUBY POR DEFECTO
require 'prime'
#LA SIGUIENTE LIBRERIA PERMITE TRABAJAR CON DIFERENTES ALGORITMOS DE CIFRADO DE CLAVES, ASI COMO FIRMAS
#DIGITALES, ENTRE OTRAS OPCIONES
require 'openssl'
#LA SIGUIENTE LIBRERIA PERMITE MOSTRAR DE MANERA ESTRUCTURADA LAS OPCIONES DE LINEA DE COMANDO, ASÍ
#COMO LA RECEPCIÓN DE PARAMETROS O SECCIÓN DE AYUDA
require 'optparse'

#EL SIGUIENTE BLOQUE HACE USO DE UNA LIBRERIA NATIVA DE RUBY PARA DETERMINAR SI UN NUMERO ES O NO ES PRIMO
#EN EL CASO DE QUE NO SEA PRIMO, SE PROCEDE A AÑADIR 1 AL NUMERO PRESENTADO COMO PARAMETRO


def esPrimo? (n)
  if Prime.prime?(n) then
      return n
  else
      n+=1
      esPrimo?(n)
  end
end

#OPCIONES DE LINEA DE COMANDOS: NUMERO PRIMO, NUMERO GENERADOR, PEM CLIENTE Y PEM SERVIDOR
Options = Struct.new(:nCliente, :nPrimo, :nGen, :aPem, :aPass, :sPem, :sPass)

#EL CODIGO SE ENCUENTRA DENTRO DE LA CLASE PARSER, QUE ES LA ENCARGADA DE CAPTURAR LAS BANDERAS DE LA LINEA DE COMANDOS

class Parser
  def self.parse(opciones)
    $args = Options.new("nCliente", "nPrimo", "nGen", "aPem", "aPass","sPem", "sPass")

    opt_parser = OptionParser.new do |opts|
      #ESTA VARIABLE CORRESPONDE A LAS OPCIONES QUE SE MUESTRAN AL EJECUTAR EL SCRIPT CON LA BANDERA -h
      opts.banner = "
      -------------------------------------
      |                                   |
      |           DIFFIE-HELLMAN          |
      |                                   |
      |     Juan Camilo Tamayo Molina     |
      |      Juan David Garcia Reyes      |
      |                                   |
      |            ___________            |
      |    Docente: Siler Amador Donado   |
      |              UAO-2019             |
      -------------------------------------

      Ejemplo de uso: 
      ruby diffie-hellman.rb [opciones]
      >ruby diffie-hellman.rb -c 354 -p 17 -g 3 -a nombreArchivoCliente.pem (Opcional) -p nombreArchivoServidor.pem (Opcional)' 
      >ruby diffie-hellman.rb -c 354 -p 17 -g 3 -a -p 
      >ruby diffie-hellman.rb -c (se genera de manera aleatoria) -p 17 -g 3 -a -p 
      >ruby diffie-hellman.rb -c 354 -p 17 -g 3 -a nombreArchivoCliente.pem -t claveCliente -p nombreArchivoServidor.pem -f claveServidor

      "

      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-s" el cual, en conjunto, recibirá el numero secreto del CLIENTE
      opts.on("-c", "--secretoCliente [SCLIENTE]", "Numero secreto o privado del cliente") do |n|
        if n.nil? || (n.eql? "") || (!n.to_i.is_a? Numeric) then
          puts 'numero secreto invalido o no asignado, será asignado uno al azár'
          $args.nCliente = Random.new.rand(247853..999999)
        else
          $args.nCliente = n.to_i
        end
      end


      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-p" el cual, en conjunto, recibirá un numero PRIMO
      opts.on("-p", "--primo [PRIMO]", "Numero primo acordado") do |n|

        if n.nil? || (n.eql? "") || (!n.to_i.is_a? Numeric) then
          puts 'numero primo invalido'
          puts opts
          exit
        else
          $args.nPrimo = n.to_i
        end
      end
      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-g" el cual, en conjunto, recibirá un numero GENERADOR
      opts.on("-g", "--gen [GEN]", "Numero generador acordado") do |n|
        
        if n.nil? || (n.eql? "") || (!n.to_i.is_a? Numeric) then
          puts 'numero generador invalido'
          puts opts
          exit
        else
          $args.nGen = n.to_i
        end
      end
      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-a" EL CUAL, EN CONJUNTO, RECIBIRÁ LA RUTA DE UN
      #ARCHIVO CON EXTENSIÓN .PEM PARA ASIGNAR AL CLIENTE
      opts.on("-a", "--pem [PEM]", "Archivo .PEM Opcional con información de llaves publica y privada del cliente") do |n|
        
        if n.nil? || (!File.file?(n)) then
          puts "AVISO: No fue otorgada una ruta de archivo PEM o el indicado no existe, se procede a
          configurar un juego de llaves por defecto cliente"
          $args.aPem = "none"
        else
          $args.aPem = n.to_s
        end
      end
      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-t" EL CUAL, EN CONJUNTO, RECIBIRÁ LA CONTRASEÑA DEL
      #ARCHIVO CON EXTENSIÓN .PEM DEL CLIENTE
      opts.on("-t", "--passCliente [PASS_CLIENTE]", "Contraseña de archivo .PEM del cliente") do |n|
        puts n
        if n.nil? || (n.to_s.eql? "") then
          puts "AVISO: No fue otorgada una contraseña para el archivo .PEM del cliente, se utilizará la clave por
          defecto  en caso de que se haya proveido uno"
          $args.aPass = "cliente"
        else
          $args.aPass = n.to_s
        end
      end
      
      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-s" EL CUAL, EN CONJUNTO, RECIBIRÁ LA RUTA DE UN
      #ARCHIVO CON EXTENSIÓN .PEM PARA ASIGNAR AL SERVIDOR
      opts.on("-s", "--pem_servidor [PEM_SERVIDOR]", "Archivo .PEM Opcional con información de llaves publica y privada del servidor") do |n|
        if n.nil?  || (!File.file?(n)) then
          puts "AVISO: No fue otorgada una ruta de archivo PEM o el indicado no existe, se procede a
          configurar un juego de llaves por defecto para el servidor"
          $args.sPem = "none"
        else
          $args.sPem = n.to_s
        end
      end

      #ESTA OPCIÓN PERMITE CAPTURAR EL PARAMETRO O BANDERA "-t" EL CUAL, EN CONJUNTO, RECIBIRÁ LA CONTRASEÑA DEL
      #ARCHIVO CON EXTENSIÓN .PEM DEL CLIENTE
      opts.on("-f", "--passServidor [PASS_SERVIDOR]", "Contraseña de archivo .PEM del servidor") do |n|
        
        if n.nil? || (n.to_s.eql? "") then
          puts "AVISO: No fue otorgada una contraseña para el archivo .PEM del servidor, se utilizará la clave por
          defecto en caso de que se haya proveido uno"
          $args.sPass = "servidor"
        else
          $args.sPass = n.to_s
        end
      end

      opts.on("-h", "--help", "Imprime la ayuda") do
        puts opts
        exit
      end

    end

    opt_parser.parse!(opciones)
    ##------------------------------
    #INICIO DE DIFFIE HELLMAN
    secretoCliente = $args.nCliente.to_i
    #EL NUMERO SECRETO DEL SERVIDOR ES GENERADO DE MANERA ALEATORIA ENTRE EL SIGUIENTE RANGO
    secretoServidor = Random.new.rand(247853..999999)
    puts "Secreto cliente: " + secretoCliente.to_s
    puts "Secreto servidor: " + secretoServidor.to_s
    moduloPrimo = esPrimo?($args.nPrimo)
    if moduloPrimo < (2**1023) then
      puts "Se recomienda un primo mayor a 1024 bits para mayor seguridad"
    end
    numeroGenerador = $args.nGen.to_i
    puts "Modulo Primo: "+ moduloPrimo.to_s
    puts "Numero generador: " + numeroGenerador.to_s

    #LAS SIGUIENTES LINEAS HACEN USO DE LA LIBRERIA DE OPENSSL PARA CREAR UN JUEGO DE LLAVES DSA TANTO
    #PARA EL CLIENTE COMO PARA EL SERVIDOR, EN EL CASO QUE NO SE PROVEA DE UN ARCHIVO .PEM AL MOMENTO
    #DE BRINDAR LOS PARAMETROS

    #CERTIFICADO DEL CLIENTE PARA VALIDACIONES DE LO RECIBIDO POR EL SERVIDOR
    #AQUI SE DETERMINA SI HAY UN ARCHIVO PEM PARA EL CLIENTE, SI NO SE PROPORCIONÓ O NO SE ENCUENTRA,
    #SE CREARÁ UN JUEGO DE LLAVES DE MANERA AUTOMATICA Y DE LONGITUD 2048 BITS
    if ($args.aPem.eql? "none") || ($args.aPem.eql? "aPem") then
      puts "Generando llaves para el cliente..."
      dsaCliente =(OpenSSL::PKey::DSA.new(2048, 'cliente'))
    else
      puts "Cargando PEM con llaves para el cliente..."
      dsaCliente = OpenSSL::PKey::DSA.new(File.read($args.aPem), $args.aPass)
    end
    pub_key_cliente = dsaCliente.public_key
    pub_key_der_cliente = pub_key_cliente.to_der 
  
    #FIN CERTIFICADO CLIENTE

    #CERTIFICADO DEL SERVIDOR PARA CIFRAR LA CLAVE PUBLICA 
    #AQUI SE DETERMINA SI HAY UN ARCHIVO PEM PARA EL SERVIDOR, SI NO SE PROPORCIONÓ O NO SE ENCUENTRA,
    #SE CREARÁ UN JUEGO DE LLAVES DE MANERA AUTOMATICA Y DE LONGITUD 2048 BITS
    if ($args.sPem.eql? "none")  || ($args.sPem.eql? "sPem") then
      puts "Generando llaves para el servidor..."
      dsaServidor = (OpenSSL::PKey::DSA.new(2048, 'servidor'))
    else
      puts "Cargando PEM con llaves para el servidor..."
      dsaServidor = OpenSSL::PKey::DSA.new(File.read($args.sPem), $args.sPass)
    end
    pub_key_servidor = dsaServidor.public_key 
    pub_key_der_servidor = pub_key_servidor.to_der

    #FIN CERTIFICADO SERVIDOR
    puts "calculando valor público para el cliente..."
    valorPublicoCliente = (numeroGenerador ** secretoCliente) % moduloPrimo
    puts "calculando valor público para el servidor..."
    valorPublicoServidor = (numeroGenerador ** secretoServidor) % moduloPrimo
    puts "VALOR PUBLICO DEL CLIENTE: " + valorPublicoCliente.to_s
    puts "VALOR PUBLICO DEL CLIENTE: " + valorPublicoServidor.to_s

    #SE SIMULA EL FUNCIONAMIENTO DEL SERVIDOR HABIENDO RECIBIDO LOS DATOS PERTINENTES DEL CLIENTE
    #AQUI SE FIRMA CON LA LLAVE DSA PRIVADA DEL SERVIDOR ALMACENADA ANTERIORMENTE, UNA CADENA CON LOS VALORES PUBLICOS DEL CLIENTE Y EL SERVIDOR
    valoresClienteServidor = valorPublicoCliente.to_s + valorPublicoServidor.to_s
    digestServidor = OpenSSL::Digest::SHA1.digest(valoresClienteServidor)
    firmaServidor = dsaServidor.syssign(digestServidor)
    #FIN FIRMA

    #AQUI SE COMPUTA EL SECRETO COMPARTIDO POR CADA ESTACIÓN
    puts "descifrando y computando el secreto compartido desde el cliente..."
    descifradoCliente = (valorPublicoServidor ** secretoCliente) % moduloPrimo
    puts "descifrando y computando el secreto compartido desde el servidor..."
    descifradoServidor = (valorPublicoCliente ** secretoServidor) % moduloPrimo

    #SE SIMULA EL FUNCIONAMIENTO DEL CLIENTE HABIENDO RECIBIDO TANTO EL VALOR PUBLICO COMO LA CADENA FIRMADA DESDE EL SERVIDOR
    #SE CREA UN DIGEST CONCATENANDO LOS VALORES PUBLICOS DEL CLIENTE Y EL SERVIDOR, COMO EN EL PROCESO ANTERIÓR, SOLO QUE AUN NO SE 
    #PROCEDE A FIRMAR
    valoresClienteServidor = valorPublicoCliente.to_s + valorPublicoServidor.to_s
    digestCliente = OpenSSL::Digest::SHA1.digest(valoresClienteServidor)
    #VALIDACIÓN DEL CLIENTE: SI LA VALIDACIÓN DE LA FIRMA DEL SERVIDOR FALLA, SE ABORTA EL PROCESO
    if dsaServidor.sysverify(digestCliente, firmaServidor) then
        puts "validado servidor!! (Firma validada)"
    else
        puts "ERROR"
        exit    
    end
    #AQUI SE FIRMA CON LA LLAVE DSA PRIVADA DEL CLIENTE ALMACENADA ANTERIORMENTE, UNA CADENA CON LOS VALORES PUBLICOS DEL CLIENTE Y EL SERVIDOR
    #PARA SER ENVIADA NUEVAMENTE AL SERVIDOR A MANERA DE HANDSHAKE
    firmaCliente = dsaCliente.syssign(digestCliente)

    #EL SERVIDOR VALIDA LA LLAVE DEL CLIENTE    
    if dsaCliente.sysverify(digestServidor, firmaCliente) then
        puts "validado cliente!! (Firma validada)"
    else
        puts "ERROR DE VALIDACIÓN"
        exit    
    end
    #SE IMPRIMEN LOS VALORES CALCULADOS POR CADA PARTE (CLIENTE Y SERVIDOR)
    puts "VALOR SECRETO CONOCIDO (CALCULO CLIENTE): " + descifradoCliente.to_s
    puts "VALOR SECRETO CONOCIDO (CALCULO SERVIDOR): " + descifradoServidor.to_s 


    #FIN DIFFIE HELLMAN
    ##------------------------------
  end
end
#ESTA LINEA PERMITE OBTENER LOS PARAMETROS DE LA LINEA DE COMANDOS PARA USAR CON OPTPARSE
options = Parser.parse(ARGV)
#FIN OPCIONES LINEA DE COMANDOS



    