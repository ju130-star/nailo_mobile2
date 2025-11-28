import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/models/servico.dart';

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
    setState(() {
      _carregandoServicos = true;
    });
    
    print("DEBUG FIRESTORE: Buscando serviços para Proprietária ID: ${widget.proprietariaId}"); 
    
    try {
      // 🛠️ CORREÇÃO CRÍTICA: Trocando 'servicos' por 'services'
      final snapshot = await FirebaseFirestore.instance
          .collection('services') // AGORA USANDO 'services'
          .where('idProprietaria', isEqualTo: widget.proprietariaId)
          .get();
      
      print("DEBUG FIRESTORE: Encontrados ${snapshot.docs.length} serviços."); 

      final List<Servico> servicos = snapshot.docs.map((doc) {
        // Correção para não mudar o Servico.fromMap, injetando o ID no mapa de dados
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
      setState(() {
        _carregandoServicos = false;
      });
    }
  }

  // Função para calcular horários disponíveis (MOCK/Simulação)
  void _calcularHorariosDisponiveis(DateTime data) async {
  if (_servicoSelecionado == null || _servicoSelecionado!.duracao <= 0) return;

  setState(() {
    _carregandoHorarios = true;
    _horaSelecionada = null;
  });

  List<String> mockSlots = [];
  final duracao = _servicoSelecionado!.duracao;

  // 1️⃣ Buscar horários já ocupados no Firestore
  final inicioDoDia = DateTime(data.year, data.month, data.day, 0, 0, 0);
  final fimDoDia = DateTime(data.year, data.month, data.day, 23, 59, 59);

  final agendamentosDia = await FirebaseFirestore.instance
      .collection("agendamentos")
      .where("idProprietaria", isEqualTo: widget.proprietariaId) // profissional
      .where("data", isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
      .where("data", isLessThanOrEqualTo: Timestamp.fromDate(fimDoDia))
      .get();

  // Lista de horários ocupados no formato HH:mm
  List<String> horariosOcupados = agendamentosDia.docs.map((d) {
    final timestamp = d['data'] as Timestamp;
    final date = timestamp.toDate();
    return DateFormat("HH:mm").format(date);
  }).toList();

  print("⛔ HORÁRIOS OCUPADOS: $horariosOcupados");

  // 2️⃣ Calcular horários disponíveis
  DateTime inicioJornada = DateTime(data.year, data.month, data.day, 9, 0);
  DateTime fimJornada = DateTime(data.year, data.month, data.day, 17, 0);
  DateTime slot = inicioJornada;

  while (slot.add(Duration(minutes: duracao)).isBefore(fimJornada.add(const Duration(minutes: 1)))) {
    bool isSlotInFuture = slot.isAfter(DateTime.now());

    // BLOQUEAR horário de almoço (12:00 às 13:00)
    if (slot.hour == 12) {
      slot = slot.add(const Duration(hours: 1));
      continue;
    }

    String horarioFormatado = DateFormat('HH:mm').format(slot);

    // ❌ SE O HORÁRIO JÁ ESTIVER OCUPADO → pula
    if (horariosOcupados.contains(horarioFormatado)) {
      slot = slot.add(Duration(minutes: duracao));
      continue;
    }

    if (data.day != DateTime.now().day || isSlotInFuture) {
      mockSlots.add(horarioFormatado);
    }

    slot = slot.add(Duration(minutes: duracao));
  }

  // Atualizar o estado
  Future.delayed(const Duration(milliseconds: 300), () {
    setState(() {
      _horariosDisponiveis = mockSlots;
      _carregandoHorarios = false;
    });
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
      // BLOQUEAR DOMINGO (weekday == 7)
      if (day.weekday == DateTime.sunday) {
        return false; // dia não selecionável
      }
      return true; // todos os outros dias selecionáveis
    },
  );

  if (picked != null && picked != _dataSelecionada) {
    setState(() {
      _dataSelecionada = picked;
      _dataController.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
    });
    _calcularHorariosDisponiveis(picked);
  }
}
  
  // Função que salva o agendamento no Firestore
  void _salvarAgendamento() {
    if (!_formKey.currentState!.validate() || _servicoSelecionado == null || _dataSelecionada == null || _horaSelecionada == null) {
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
    
    // 🎯 SALVAMENTO NO FIRESTORE
    FirebaseFirestore.instance.collection('agendamentos').add({
      'idProfissional': widget.proprietariaId,
      'idServico': servico.id,
      'nomeServico': servico.nome,
      'precoServico': servico.preco, 
      'duracaoServico': servico.duracao, 
      'data': fullDateTime,
      'status': 'Pendente', 
      // TODO: Adicionar o ID do cliente logado
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento salvo com sucesso!")),
      );
      Navigator.pop(context);
    }).catchError((error) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar agendamento: $error")),
      );
    });
  }

  // --- WIDGETS DE UI AUXILIARES ---
  
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

  // Dropdown de Serviços
  Widget _buildServicoDropdown() {
    if (_servicosDisponiveis.isEmpty && !_carregandoServicos) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent)
        ),
        child: const Text("⚠️ Nenhum serviço encontrado. Verifique a coleção 'services' no Firestore e se o ID da Profissional está correto. (veja o console para DEBUG)", 
          style: TextStyle(color: Colors.red, fontSize: 14)
        ),
      );
    }
    
    return DropdownButtonFormField<Servico>(
      value: _servicoSelecionado,
      decoration: _inputDecoration("Serviço"),
      items: _servicosDisponiveis.map((servico) {
        return DropdownMenuItem<Servico>(
          value: servico,
          child: Text(
            "${servico.nome} (R\$ ${servico.preco.toStringAsFixed(2)}) - ${servico.duracao} min",
            style: const TextStyle(color: Color(0xFF107A73)),
          ),
        );
      }).toList(),
      onChanged: (Servico? newValue) {
        setState(() {
          _servicoSelecionado = newValue;
          _dataSelecionada = null;
          _dataController.clear();
          _horariosDisponiveis = [];
        });
      },
      validator: (value) => value == null ? "Selecione um serviço" : null,
      isExpanded: true,
    );
  }
  
  // Campo de Data
  Widget _buildDataField() {
    return GestureDetector(
      onTap: () {
        if (_servicoSelecionado == null) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Selecione um serviço antes de escolher a data.")),
           );
           return;
        }
        _selecionarData(context);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dataController,
          decoration: _inputDecoration("Data (DD/MM/AAAA)", icon: Icons.calendar_today),
          validator: (value) => _dataSelecionada == null ? "Selecione uma data" : null,
        ),
      ),
    );
  }

  // Seleção de Horário (Chips)
  Widget _buildHorarioSelector() {
    if (_dataSelecionada == null) {
      return const Text("Selecione uma data para ver os horários.", style: TextStyle(fontSize: 14, color: Colors.black54));
    }

    if (_carregandoHorarios) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
      ));
    }

    if (_horariosDisponiveis.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12)),
        child: const Text("Não há horários disponíveis para este dia/serviço.", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecione um horário:", style: TextStyle(color: Color(0xFF107A73), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _horariosDisponiveis.map((hora) {
            bool isSelected = _horaSelecionada == hora;
            return ChoiceChip(
              label: Text(hora),
              selected: isSelected,
              selectedColor: const Color(0xFF48CFCB).withOpacity(0.8),
              backgroundColor: const Color(0xFFFAFAFA),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF107A73),
                fontWeight: FontWeight.bold
              ),
              onSelected: (bool selected) {
                setState(() {
                  _horaSelecionada = selected ? hora : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  // --- BUILD PRINCIPAL ---

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
          padding: const EdgeInsets.all(16.0),
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
              
              // 1. Dropdown de Serviço
              _carregandoServicos
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF48CFCB)))
                  : _buildServicoDropdown(),
                  
              const SizedBox(height: 16),
              
              // 2. Campo de Data
              _buildDataField(),
              
              const SizedBox(height: 16),

              // 3. Seleção de Horário
              _buildHorarioSelector(),

              const SizedBox(height: 30),

              // 4. Botão Salvar
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CFCB),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }
}