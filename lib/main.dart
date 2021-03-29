
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';
import 'cus_slid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'PKCoins'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpClient;
  Web3Client ethClient;
  bool data = false;
  final myAddress = "0x20B85673252CAb8D906C11C69Ac85b6122794b8d";
  int myAmount = 0;
  var myData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/6367f1b23fbc4152ac50d267663a776e",
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x9C4805F58dF96Ab471E0003F9c200a3D38cadF3e";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKcoin"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(String targetaddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetaddress);
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    setState(() {
      data=true;
    });
  }

  Future<String> submit(String functionName , List<dynamic> args) async
  {
    EthPrivateKey credentials = EthPrivateKey.fromHex("a9bf134facdd642a02e1f6e008cb21901e28952c0541df466e76cb8cda3ed296");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credentials, Transaction.callContract(contract: contract, function: ethFunction, parameters: args) , fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String> sendCoin() async{
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance" , [bigAmount]);
    print("Deposited");
    return response;
  }

  Future<String> withdrawCoin() async{
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance" , [bigAmount]);
    print("Withdrawn");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .black
            .size(context.screenWidth, context.percentHeight * 30)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "ThinkArtCoinz".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 5).heightBox,
          VxBox(
            child: VStack([
              "Balance".text.gray700.xl2.semiBold.makeCentered(),
              10.heightBox,
              data
                  ? "\$${myData}".text.bold.xl6.makeCentered()
                  : CircularProgressIndicator().centered(),
            ]),
          )
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 15)
              .rounded
              .shadowXl
              .make()
              .p16(),
          30.heightBox,
          SliderWidget(
            min: 0,
            max: 100,
            finalval: (value) {
              myAmount = (value * 100).round();
              print(myAmount);
            },
          ).centered(),
          HStack(
            [
              RaisedButton.icon(
                      onPressed: () {
                        setState(() {
                          getBalance(myAddress);
                        });
                      },
                      color: Colors.blue,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: "Refresh".text.white.make(),
                      shape: Vx.roundedSm)
                  .h(50),
              RaisedButton.icon(
                      onPressed: () {
                        setState(() {
                          sendCoin();
                        });
                      },
                      color: Colors.green,
                      icon: Icon(
                        Icons.call_made_outlined,
                        color: Colors.white,
                      ),
                      label: "Deposit".text.white.make(),
                      shape: Vx.roundedSm)
                  .h(50),
              RaisedButton.icon(
                      onPressed: () {
                        setState(() {
                          withdrawCoin();
                        });
                      },
                      color: Colors.red,
                      icon: Icon(
                        Icons.call_received_outlined,
                        color: Colors.white,
                      ),
                      label: "Withdraw".text.white.make(),
                      shape: Vx.roundedSm)
                  .h(50),
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).p16(),
        ]),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
