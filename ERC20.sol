// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

// Junior Rojas: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Jose Perez: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Maria Santos: 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
// Direccion del Smart Contract: 0xF87708D5d75aC2B593b87C2dE8B7909Af827a580

interface IRC20 {
    // devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns (uint256);

    // devuelve la cantidad de tokens para una direccion indicada por parametros
    function balanceOf(address account) external view returns (uint256);

    // devuelve el numero de token que el spender podra gastar en nombrede propetario de la direccion
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // devuelve un valor boleanos resultado de la operacion de compra
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
        
     function transferDisney(address _cliente, address receiver, uint256 numTokens)
        external
        returns (bool);

    // devuelve un valor boleanos resultado de la operacion de gasto
    function approve(address spender, uint256 amount) external returns (bool);

    // devuelve un valor boleanos resultado de la operacion de una cantida de tokens usando el metodo de allowance()
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Tranfer(address indexed from, address indexed to, uint256 value);

    // Evento que se debe emitir cuando se establece una asignacion con el metodo allowance()
    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20Basic is IRC20 {
    string public constant name = "Junior Token 2";
    string public constant symbol = "JT2";
    uint8 public constant decimal = 2;

    event Tranfer(address indexed from, address indexed to, uint256 tokens);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 tokens
    );

    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(uint256 initialSupply) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function increaseTotalSupply(uint256 newTokenAmout) public {
        totalSupply_ += newTokenAmout;
        balances[msg.sender] += newTokenAmout;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens)
        public
        override
        returns (bool)
    {
        // verificamos que tenga los token que quieren enviar
        require(numTokens <= balances[msg.sender]);
        
        // le restamos los token a que envia
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        
        
        // le agregamos lo token a los que reciben
        balances[recipient] = balances[recipient].add(numTokens);
        
        // emitimos el evento de tranfer cuando l transacion es exitosa
        emit Tranfer(msg.sender, recipient, numTokens);
        
        return true;
    }
    
     function transferDisney(address _cliente, address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        // verificamos que tenga los token que quieren enviar
        require(numTokens <= balances[_cliente]);
        
        // le restamos los token a que envia
        balances[_cliente] = balances[_cliente].sub(numTokens);
        
        
        // le agregamos lo token a los que reciben
        balances[receiver] = balances[receiver].add(numTokens);
        
        // emitimos el evento de tranfer cuando l transacion es exitosa
        emit Tranfer(_cliente, receiver, numTokens);
        
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approve(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        
         // verificamos que tenga los token que quieren enviar
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        // le restamos los token al verdedor 
        balances[owner] = balances[owner].sub(numTokens);
        
        // me lo quito a mi como intermediario de la venta 
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        
        
        // le agrego los token al comprador
        balances[buyer] = balances[buyer].add(numTokens);
        
        // emitimos los cambios
        emit Tranfer(owner, buyer, numTokens);
        
        return true;
    }
    

}
