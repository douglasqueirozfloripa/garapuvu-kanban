import 'package:flutter/material.dart';

import 'app.dart';

/// Ponto de entrada do aplicativo Garapuvu Kanban.
///
/// Mantido propositalmente minusculo: toda a configuracao do app (tema, rotas,
/// injecao de dependencia) mora em [GarapuvuKanbanApp], em `app.dart`. Assim os
/// testes conseguem montar o app inteiro sem passar por `main`.
void main() {
  runApp(const GarapuvuKanbanApp());
}
