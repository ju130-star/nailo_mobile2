import 'package:nailo_mobile2/models/servico.dart';

import '../services/servico_service.dart';

class ServicoController {

  // Listar todos os serviços
  Future<List<Servico>> listarServicos() async {
    return await ServicoService.listarServicos();
  }

  // Adicionar um novo serviço
  Future<void> adicionarServico(Servico servico) async {
    await ServicoService.adicionarServico(servico);
  }

  // Deletar um serviço pelo id
  Future<void> deletarServico(String id) async {
    await ServicoService.deletarServico(id);
  }
}
