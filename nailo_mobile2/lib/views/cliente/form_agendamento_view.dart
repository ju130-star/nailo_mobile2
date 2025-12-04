import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/services/notificacao_service.dart';

// --- WIDGET PRINCIPAL ---

class FormAgendamentoView extends StatefulWidget {
  final String proprietariaId;

  const FormAgendamentoView({
    super.key,
    required this.proprietariaId,
  });

  @override
  State<FormAgendamentoView> createState() => _FormAgendamentoViewState();
}

class _FormAgendamentoViewState extends State<FormAgendamentoView> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();

  // Estados
  List<Servico> _servicosDisponiveis = [];
  Servico? _servicoSelecionado;
  bool _carregandoServicos = true;
  DateTime? _dataSelecionada;
  String? _horaSelecionada;
  List<String> _horariosDisponiveis = [];
  bool _carregandoHorarios = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null); 
    _carregarServicos();
  }
  
  // --- LÓGICA DE DADOS (FIRESTORE) ---

  Future<void> _carregarServicos() async {
    setState(() => _carregandoServicos = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('idProprietaria', isEqualTo: widget.proprietariaId)
          .get();

      final List<Servico> servicos = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; 
        return Servico.fromMap(data); 
      }).toList();

      setState(() {
        _servicosDisponiveis = servicos;
        _carregandoServicos = false;
        if (_servicosDisponiveis.isNotEmpty) {
           _servicoSelecionado = _servicosDisponiveis.first;
           if (_dataSelecionada != null) {
             _calcularHorariosDisponiveis(_dataSelecionada!);
           }
        }
      });
      
    } catch (e) {
      print("ERRO FIRESTORE CRÍTICO ao carregar serviços: $e");
      setState(() => _carregandoServicos = false);
    }
  }

  // --- CORREÇÃO: remover horários já ocupados do Firestore ---
  Future<void> _calcularHorariosDisponiveis(DateTime data) async {
    if (_servicoSelecionado == null || _servicoSelecionado!.duracao <= 0) return;
  
    setState(() {
      _carregandoHorarios = true;
      _horaSelecionada = null;
      _horariosDisponiveis = [];
    });

    List<String> horariosGerados = [];

    final duracao = _servicoSelecionado!.duracao;

    DateTime inicioJornada = DateTime(data.year, data.month, data.day, 9, 0);
    DateTime fimJornada = DateTime(data.year, data.month, data.day, 17, 0);
    DateTime slot = inicioJornada;

    while (slot.add(Duration(minutes: duracao)).isBefore(fimJornada.add(const Duration(minutes: 1)))) {
      bool isAfterNow = slot.isAfter(DateTime.now());

      // BLOQUEAR ALMOÇO 12h às 13h
      if (slot.hour == 12) {
        slot = slot.add(const Duration(hours: 1)); 
        continue;
      }

      if (data.day != DateTime.now().day || isAfterNow) {
        horariosGerados.add(DateFormat('HH:mm').format(slot));
      }

      slot = slot.add(Duration(minutes: duracao));
    }

    // 🔥 BUSCAR AGENDAMENTOS OCUPADOS
    final snapshot = await FirebaseFirestore.instance
        .collection('agendamentos')
        .where('idProfissional', isEqualTo: widget.proprietariaId)
        .get();

    List<String> ocupados = [];

    for (var doc in snapshot.docs) {
      DateTime d = (doc['data'] as Timestamp).toDate();
      if (d.year == data.year && d.month == data.month && d.day == data.day) {
        ocupados.add(DateFormat('HH:mm').format(d));
      }
    }

    print("HORÁRIOS OCUPADOS: $ocupados");

    // Remover horários ocupados
    horariosGerados.removeWhere((h) => ocupados.contains(h));

    setState(() {
      _horariosDisponiveis = horariosGerados;
      _carregandoHorarios = false;
    });
  }

  // Função para abrir o seletor de data
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('pt', 'BR'),
      selectableDayPredicate: (DateTime day) {
        if (day.weekday == DateTime.sunday) return false;
        return true;
      },
    );

    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
        _dataController.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
      });
      _calcularHorariosDisponiveis(picked);
    }
  }

  // --- SALVAR AGENDAMENTO + NOTIFICAÇÃO ---
  void _salvarAgendamento() async {
    // 1. Obter o ID do Cliente logado (O USUÁRIO QUE ESTÁ USANDO A TELA)
    final User? clienteLogado = FirebaseAuth.instance.currentUser;
    
    // Verificações
    if (clienteLogado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Cliente não logado.")),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || 
        _servicoSelecionado == null || 
        _dataSelecionada == null || 
        _horaSelecionada == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos.")),
      );
      return;
    }

    final data = _dataSelecionada!;
    final hora = _horaSelecionada!;
    final servico = _servicoSelecionado!;

    final fullDateTime = DateTime(
      data.year, data.month, data.day,
      int.parse(hora.split(':')[0]),
      int.parse(hora.split(':')[1])
    );
    final dataUtc = fullDateTime.toUtc(); 

    try {
      // 🎯 PASSO 1: BUSCAR O NOME DA PROPRIETÁRIA (ID está em widget.proprietariaId)
      final proprietariaDoc = await FirebaseFirestore.instance
          .collection('usuarios') // Coleção CORRETA: 'usuarios'
          .doc(widget.proprietariaId)
          .get();

      String nomeProprietaria = 'Profissional Desconhecido';
      if (proprietariaDoc.exists && proprietariaDoc.data()!.containsKey('nome')) {
        nomeProprietaria = proprietariaDoc.data()!['nome'];
      }
      
      // 🎯 PASSO 2: BUSCAR O NOME DO CLIENTE (ID está em clienteLogado.uid)
      final clienteDoc = await FirebaseFirestore.instance
          .collection('usuarios') // Coleção CORRETA: 'usuarios'
          .doc(clienteLogado.uid)
          .get();
          
      String nomeCliente = 'Cliente Desconhecido';
      if (clienteDoc.exists && clienteDoc.data()!.containsKey('nome')) {
        nomeCliente = clienteDoc.data()!['nome'];
      }

      // 🎯 PASSO 3: SALVAR AGENDAMENTO com todos os campos necessários
      await FirebaseFirestore.instance.collection('agendamentos').add({
        'idProprietaria': widget.proprietariaId,
        'nomeProprietaria': nomeProprietaria, // ✅ Nome da Profissional
        'idCliente': clienteLogado.uid,
        'nomeCliente': nomeCliente, // ✅ Nome do Cliente
        'idServico': servico.id,
        'nomeServico': servico.nome,
        // É importante que o modelo Agendamento exija 'preco' e 'duracao'
        'preco': servico.preco, 
        'duracao': servico.duracao, 
        'data': dataUtc, 
        'status': 'agendado', // Mudei para 'agendado' para consistência com seu modelo
        'criadoEm': DateTime.now().toUtc(),
        'atualizadoEm': DateTime.now().toUtc(),
      });

      // 🔥 ENVIAR NOTIFICAÇÃO
      await NotificacaoService().enviarNotificacao(
        idUsuario: widget.proprietariaId,
        mensagem: "Novo agendamento em ${DateFormat('dd/MM HH:mm').format(fullDateTime)}",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento salvo com sucesso!")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar agendamento: $e")),
      );
    }
  }

  // --- UI AUXILIAR ---
  
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      labelStyle: const TextStyle(color: Color(0xFF107A73)),
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF48CFCB)) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF48CFCB)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF48CFCB), width: 2),
      ),
    );
  }

  Widget _buildHorarioSelector() {
    if (_carregandoHorarios) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
        ),
      );
    }

    if (_dataSelecionada == null) {
      return const Text(
        "Selecione uma data para ver os horários.",
        style: TextStyle(fontSize: 14, color: Colors.black54),
      );
    }

    if (_horariosDisponiveis.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Nenhum horário disponível para este dia.",
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: _horariosDisponiveis.map((h) {
        bool sel = _horaSelecionada == h;
        return ChoiceChip(
          label: Text(h),
          selected: sel,
          selectedColor: const Color(0xFF48CFCB),
          labelStyle: TextStyle(
            color: sel ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          onSelected: (_) => setState(() => _horaSelecionada = h),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Novo Agendamento 💅"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "ID da Profissional: ${widget.proprietariaId}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              const Text(
                "Dados do Agendamento:",
                style: TextStyle(
                  color: Color(0xFF107A73),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Serviço
              _carregandoServicos
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF48CFCB)))
                  : DropdownButtonFormField<Servico>(
                      value: _servicoSelecionado,
                      decoration: _inputDecoration("Serviço"),
                      items: _servicosDisponiveis.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text("${s.nome} (${s.duracao} min)"),
                        );
                      }).toList(),
                      onChanged: (s) {
                        setState(() {
                          _servicoSelecionado = s;
                          _dataSelecionada = null;
                          _dataController.clear();
                          _horariosDisponiveis = [];
                        });
                      },
                    ),

              const SizedBox(height: 20),

              // Data
              GestureDetector(
                onTap: () => _selecionarData(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataController,
                    decoration: _inputDecoration("Data", icon: Icons.calendar_today),
                    validator: (_) => _dataSelecionada == null ? "Escolha a data" : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Horários
              _buildHorarioSelector(),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CFCB),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _salvarAgendamento,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Salvar Agendamento",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}