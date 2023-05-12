import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../dao/ponto_dao.dart';
import '../models/ponto.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget{
  HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _localizacaoAtual;
  final _controller = TextEditingController();

  String get _textoLocalizacao =>
      _localizacaoAtual == null ? '' :
      'Latitude: ${_localizacaoAtual!
          .latitude}  |  Longetude: ${_localizacaoAtual!.longitude}';


  final _pontos = <Ponto>[];
  var _carregando = false;
  final _dao = PontoDao();

  @override
  void initState() {
    // super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Pontos')),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar Ponto',
        child: const Icon(Icons.add),
        onPressed: _obterLocalizacaoAtual,
      ),
    );
  }

  Widget _criarBody() {
    if (_carregando) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Carregando seus registros de ponto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_pontos.isEmpty) {
      return Center(
        child: Text(
          'Nenhum registro de ponto encontrado',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme
                .of(context)
                .primaryColor,
          ),
        ),
      );
    }
    return ListView.builder(
        itemCount: _pontos.length,
        itemBuilder: (BuildContext context, int index) {
          final ponto = _pontos[index];
          return ListTile(
            title: Text(
              '${ponto.id} - ${ponto.dataPonto}',

            ),
            subtitle: Text(ponto.localizacao == null
                ? 'Registro sem localizacao'
                : 'Localizacao - ${ponto.localizacao}',

            ),
          );
        });
  }

  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas) {
      return;
    }

    _localizacaoAtual = await Geolocator.getCurrentPosition();

    String _textoLocalizacao = 'Latitude: ${_localizacaoAtual!
        .latitude}, Longitude: ${_localizacaoAtual!.longitude}';

    DateTime dataHoraAtual = DateTime.now();
    String textoDataHoraAtual = DateFormat('dd/MM/yyyy HH:mm:ss').format(
        dataHoraAtual);

    Ponto novoPonto = Ponto(
        id: null,
        localizacao: _textoLocalizacao,
        dataPonto: dataHoraAtual
    );
    await _dao.salvar(novoPonto);


    _atualizarLista();

    setState(() {

    });
  }



  void _abrirNoMapaExterno() {
    if (_controller.text
        .trim()
        .isEmpty) {
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  void _abrirCoordenadasNoMapaExterno() {
    if (_localizacaoAtual == null) {
      return;
    }
    MapsLauncher.launchCoordinates(
        _localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilotado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilotado) {
      await _mostrarMensagemDialog(
          'Para utilizar esse recurso, você deverá habilitar o serviço de localização '
              'no dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        _mostrarMensagem(
            'Não será possível utilizar o recusro por falta de permissão');
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await _mostrarMensagemDialog(
          'Para utilizar esse recurso, você deverá acessar as configurações '
              'do appe permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarMensagemDialog(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text('Atenção'),
            content: Text(mensagem),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _atualizarLista() async {
    setState(() {
      _carregando = true;
    });
    //Carregar os valores do SharedPreferences

    final pontos = await _dao.listar();
    setState(() {
      _pontos.clear();
      _carregando = false;
      if (pontos.isNotEmpty) {
        _pontos.addAll(pontos);
      }
    });
  }
}