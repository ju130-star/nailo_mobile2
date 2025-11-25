import 'package:flutter/material.dart';

class FormAgendamentoView extends StatefulWidget {
  final String proprietariaId; // <-- ADICIONADO

  const FormAgendamentoView({
    super.key,
    required this.proprietariaId, // <-- ADICIONADO
  });

  @override
  State<FormAgendamentoView> createState() => _FormAgendamentoViewState();
}

class _FormAgendamentoViewState extends State<FormAgendamentoView> {
  final _formKey = GlobalKey<FormState>();

  final _servicoController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Novo Agendamento 💅"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 🔥 Mostra o ID da profissional (só p/ teste agora)
                Text(
                  "Agendando com profissional ID: ${widget.proprietariaId}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Preencha os dados do agendamento:",
                  style: TextStyle(
                    color: Color(0xFF107A73),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Campo Serviço
                TextFormField(
                  controller: _servicoController,
                  decoration: _inputDecoration("Serviço"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o serviço" : null,
                ),
                const SizedBox(height: 16),

                // Campo Data
                TextFormField(
                  controller: _dataController,
                  decoration: _inputDecoration("Data (DD/MM/AAAA)"),
                  keyboardType: TextInputType.datetime,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe a data" : null,
                ),
                const SizedBox(height: 16),

                // Campo Hora
                TextFormField(
                  controller: _horaController,
                  decoration: _inputDecoration("Horário (HH:MM)"),
                  keyboardType: TextInputType.datetime,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o horário" : null,
                ),

                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48CFCB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Agendamento salvo com sucesso!"),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
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
      ),
    );
  }

  // Estilo dos campos
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      labelStyle: const TextStyle(color: Color(0xFF107A73)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF48CFCB)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF48CFCB), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _servicoController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }
}
