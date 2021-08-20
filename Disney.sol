// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {
    //  --------------------- Declaraciones inciales-------------------

    // instancia del contrato
    ERC20Basic private token;

    // direccion de disney (owner)
    address payable public owner;

    // constructor
    constructor() public {
        token = new ERC20Basic(90);
        owner = msg.sender;
    }

    // Estructuraa de datos para almacenar a los cliente s de disney

    struct cliente {
        uint256 token_comprados;
        string[] atracciones_disfrutadas;
    }

    // mapping para el registro de cientes
    mapping(address => cliente) public Clientes;

    //  --------------------- Gestion de Token -------------------

    // Funcion para establecer el valor del token

    function PrecioTokens(uint256 _numTokens) internal pure returns (uint256) {
        // conversion de tokens a ethers: 1 Token -> 1e18 Ethers
        return _numTokens * (1 ether);
    }

    // funcion para comprar tokens el disney y disfrutar de sus atracciones
    function comprarTokens(uint256 _numTokens) public payable {
        // establcer el precio del token
        uint256 coste = PrecioTokens(_numTokens);
        // verificar que el precio sea menor al saldo del cliente
        require(msg.value >= coste, "El precio es mayor al saldo del cliente");

        // diferencia de lo que el cliente paga y lo que se le da al disney

        uint256 diferencia = msg.value - coste;

        // disney retorna el dinero al cliente
        msg.sender.transfer(diferencia);

        // obtenemos el numero de tokens disponible
        uint256 Balance = balanceOf();
        require(_numTokens <= Balance, "Compra menos tokens");

        // se transfieren los tokens al cliente
        token.transfer(msg.sender, _numTokens);

        // Registo de tokens comprados
        Clientes[msg.sender].token_comprados += _numTokens;
    }

    function balanceOf() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // funciona para visualar los token disponibles de un cliente en especifico

    function misTokens() public view returns (uint256) {
        return token.balanceOf(msg.sender);
    }

    // Funciona para generar mas tokens

    function generarTokens(uint256 _numTokens)
        public
        UnicamenteOwner(msg.sender)
    {
        return token.increaseTotalSupply(_numTokens);
    }

    // modificador para controlar las funciones ejecutables por disney
    modifier UnicamenteOwner(address _direccion) {
        require(
            _direccion == owner,
            "Solo el owner puede ejecutar esta funcion"
        );
        _;
    }

    //  --------------------- Gestion de Disney -------------------

    // eventos

    event disfruta_atraciones(string, uint256, address);
    event nuevas_atraciones(string, uint256);
    event baja_atraciones(string);

    // structura de la atraccion
    struct atraccion {
        string nombre;
        uint256 precio;
        bool estado_atracion;
    }

    // Mapping para relacionar nombre de atraciones con la estructura de datos de la atracion

    mapping(string => atraccion) public MappingAtracciones;

    string[] Atraciones;

    // Mapping para almacenar una identidad (cliente con su historial de disney)
    mapping(address => string[]) public MappingHistorialAtraciones;

    // Start Wars -> 2 tokens
    // Toy Story -> 3 tokens
    // Piratas del caribe -> 10 tokens

    // crear nuevas atracion para disney, solo es ejecutable por disney
    function NuevaAtraccion(string memory _nombreAtraccion, uint256 _precio)
        public
        UnicamenteOwner(msg.sender)
    {
        MappingAtracciones[_nombreAtraccion] = atraccion(
            _nombreAtraccion,
            _precio,
            true
        );

        // Almacenamiento  de atracciones
        Atraciones.push(_nombreAtraccion);

        // emision del evento para la nueva atracion
        emit nuevas_atraciones(_nombreAtraccion, _precio);
    }

    // Dar de bajaa las atraciones en disney, solo es ejecutable por disney
    function BajaAtraccion(string memory _nombreAtraccion)
        public
        UnicamenteOwner(msg.sender)
    {
        // El Estado de la atracion pasa a FALSE -> no esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atracion = false;

        emit baja_atraciones(_nombreAtraccion);
    }

    function DarDeAltaAtraccion(string memory _nombreAtraccion)
        public
        UnicamenteOwner(msg.sender)
    {
        // El Estado de la atracion pasa a FALSE -> no esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atracion = true;

        emit baja_atraciones(_nombreAtraccion);
    }

    // visualixar las atraciones de disney
    function AtracionesDisponibles() public view returns (string[] memory) {
        return Atraciones;
    }

    // funcion para subirse a una atracion de disney y pagar
    function subirseAtraccion(string memory _nombreAtraccion) public {
        // precion de la atracion el tokes
        uint256 precio = MappingAtracciones[_nombreAtraccion].precio;

        // verificar el estado de la atracion para poder subirse
        require(
            MappingAtracciones[_nombreAtraccion].estado_atracion == true,
            "Atraccion no disponible"
        );

        // verificar que el cliente tenga los tokens necesarios para pagar
        require(precio <= misTokens(), "No tienes los tokens suficientes");

        /*
            EL CLIENTE PAGA LA ATRACCION EN TOKES:
            
            - HA SIDO NECESARIO CREAR UN FUNCION EN ERC20.SOL CON EL NOMBRE DE transferDisney DEBIDO A QUE EN CASO DE USAR TRANFERSFROM
            LAS DIRECCION ENCOGIAN  PARA REALIZAR LA ATRACNION ERA EQUIVOCADA YA QUE EL MSG.SENDER QUE RECIBIA EL METODO TRANFERS O TRAMFERS 
            FROM ERA LA DIRECCION DEL CONTRATO
        */

        token.transferDisney(msg.sender, address(this), precio);

        MappingHistorialAtraciones[msg.sender].push(_nombreAtraccion);

        // emision del evento para la nueva atracion
        emit disfruta_atraciones(_nombreAtraccion, precio, msg.sender);
    }

    // visualiza el historial de atracciones de un cliente
    function Historial() public view returns (string[] memory) {
        return MappingHistorialAtraciones[msg.sender];
    }

    // funcion para devolver un token en cualquier momento
    function devolverToken(uint256 _numTokens) public payable {
        // verificar numero de token a devolver sea positvo
        require(_numTokens > 0, "Numero de tokens negativo");

        // el usuario debe tener el numero de token que sea devolver
        require(_numTokens <= misTokens(), "No tienes los tokens suficientes");

        // el cliente devuelve los tokens
        token.transferDisney(msg.sender, address(this), _numTokens);

        // devolucion de los ether al cliente

        msg.sender.transfer(PrecioTokens(_numTokens));
    }

    //  --------------------- Gestion de Disney Comida -------------------

    // eventos

    event disfruta_comida(string, uint256, address);
    event nuevas_comida(string, uint256, bool);
    event bajar_comida(string);
    event alta_comida(string);

    // structura de la atraccion
    struct comida {
        string nombre;
        uint256 precio;
        bool estado_comida;
    }

    // Mapping para relacionar nombre de atraciones con la estructura de datos de la comida
    mapping(string => comida) public MappingComidas;

    string[] comidas;

    // Mapping para almacenar una identidad (cliente con su historial de disney)
    mapping(address => string[]) public MappingHistorialComidas;

    // crear nuevas atracion para disney, solo es ejecutable por disney

    function NuevaComida(string memory _nombreComida, uint256 _precio)
        public
        UnicamenteOwner(msg.sender)
    {
        // creacion de una comida nueva
        MappingComidas[_nombreComida] = comida(_nombreComida, _precio, true);
        // almacenar en un aray de las comidadas
        comidas.push(_nombreComida);
        // emision del evento para la nueva comida
        emit nuevas_comida(_nombreComida, _precio, true);
    }

    // Dar de bajaa las comida en disney, solo es ejecutable por disney
    function BajaComida(string memory _nombreComida)
        public
        UnicamenteOwner(msg.sender)
    {
        // El Estado de la atracion pasa a FALSE -> no esta en uso
        MappingComidas[_nombreComida].estado_comida = false;
        emit bajar_comida(_nombreComida);
    }

    function DarDeAltaComida(string memory _nombreComida)
        public
        UnicamenteOwner(msg.sender)
    {
        // El Estado de la atracion pasa a FALSE -> no esta en uso
        MappingComidas[_nombreComida].estado_comida = true;
        emit alta_comida(_nombreComida);
    }

    function ComidasDisponibles() public view returns (string[] memory) {
        return comidas;
    }

    // funcion para subirse a una atracion de disney y pagar
    function ComprarComidas(string memory _nombreComida) public {
        // precion de la atracion el tokes
        uint256 precio = MappingComidas[_nombreComida].precio;

        // verificar el estado de la atracion para poder subirse
        require(
            MappingComidas[_nombreComida].estado_comida == true,
            "comida no disponible"
        );

        // verificar que el cliente tenga los tokens necesarios para pagar
        require(precio <= misTokens(), "No tienes los tokens suficientes");

        /*
            EL CLIENTE PAGA LA ATRACCION EN TOKES:
            
            - HA SIDO NECESARIO CREAR UN FUNCION EN ERC20.SOL CON EL NOMBRE DE transferDisney DEBIDO A QUE EN CASO DE USAR TRANFERSFROM
            LAS DIRECCION ENCOGIAN  PARA REALIZAR LA ATRACNION ERA EQUIVOCADA YA QUE EL MSG.SENDER QUE RECIBIA EL METODO TRANFERS O TRAMFERS 
            FROM ERA LA DIRECCION DEL CONTRATO
        */

        token.transferDisney(msg.sender, address(this), precio);

        MappingHistorialComidas[msg.sender].push(_nombreComida);

        // emision del evento para la nueva atracion
        emit disfruta_comida(_nombreComida, precio, msg.sender);
    }

    // visualiza el historial de atracciones de un cliente
    function HistorialComida() public view returns (string[] memory) {
        return MappingHistorialComidas[msg.sender];
    }
}
