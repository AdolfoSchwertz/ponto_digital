import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class Ponto{

  static const nomeTabela = 'pontos';
  static const campoId = 'id';
  static const campoDataHora = 'horario';
  static const campoLocalizacao = 'localizacao';


  int? id;
  DateTime? dataPonto= DateTime.now();
  String localizacao;


  Ponto({
    required this.id,
    required this.localizacao,
    this.dataPonto});

  String get dataCadastroFormatado{
    // if (horaCadastro == null){
    //   return ' ';
    // }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }



  // Map<String, dynamic> toMap() => {
  //   campoId: id == 0 ? null: id,
  //   campoNome: nome,
  //   campoDescricao: descricaoo,
  //   campoDiferenciais: diferenciais,
  //   campoData:
  //   dataCadastro == null ? null : DateFormat("yyyy-MM-dd").format(dataCadastro!),
  //   campoFinalizada: finalizada ? 1 : 0
  // };
  //
  // factory PontoTuristico.fromMap(Map<String, dynamic> map) => PontoTuristico(
  //   id: map[campoId] is int ? map[campoId] : null,
  //   descricaoo: map[campoDescricao] is String ? map[campoDescricao] : '',
  //   diferenciais: map[campoDiferenciais] is String ? map[campoDiferenciais] : '',
  //   nome: map[campoNome] is String ? map[campoNome] : '',
  //   dataCadastro: map[campoData] is String
  //       ? DateFormat("yyyy-MM-dd").parse(map[campoData])
  //       : null,
  //   finalizada: map[campoFinalizada] == 1,
  // );






}