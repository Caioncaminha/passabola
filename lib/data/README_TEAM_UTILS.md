# TeamUtils - Funções Utilitárias para Times

A classe `TeamUtils` fornece funções utilitárias para verificar o status de times do usuário atual.

## Funções Disponíveis

### `isUserInTeam()`
Verifica se o usuário atual está em algum time.

**Retorno:** `Future<bool>`
- `true` se o usuário estiver em um time
- `false` se o usuário não estiver em nenhum time

**Exemplo:**
```dart
final isInTeam = await TeamUtils.isUserInTeam();
if (isInTeam) {
  print('Usuário está em um time');
} else {
  print('Usuário não está em nenhum time');
}
```

### `getUserTeamId()`
Obtém o ID do primeiro time do usuário atual.

**Retorno:** `Future<String?>`
- ID do time se o usuário estiver em um time
- `null` se o usuário não estiver em nenhum time

**Exemplo:**
```dart
final teamId = await TeamUtils.getUserTeamId();
if (teamId != null) {
  print('ID do time: $teamId');
} else {
  print('Usuário não está em nenhum time');
}
```

### `getUserTeam()`
Obtém o objeto Team do primeiro time do usuário atual.

**Retorno:** `Future<Team?>`
- Objeto Team se o usuário estiver em um time
- `null` se o usuário não estiver em nenhum time

**Exemplo:**
```dart
final team = await TeamUtils.getUserTeam();
if (team != null) {
  print('Nome do time: ${team.name}');
  print('Capitão: ${team.captainName}');
} else {
  print('Usuário não está em nenhum time');
}
```

### `canUserCreateTeam()`
Verifica se o usuário pode criar um novo time (não está em nenhum time).

**Retorno:** `Future<bool>`
- `true` se o usuário pode criar um time
- `false` se o usuário já está em um time

**Exemplo:**
```dart
final canCreate = await TeamUtils.canUserCreateTeam();
if (canCreate) {
  // Mostrar botão de criar time
  showCreateTeamButton();
} else {
  // Esconder botão de criar time
  hideCreateTeamButton();
}
```

## Uso com FutureBuilder

Para usar essas funções em widgets, recomenda-se usar `FutureBuilder`:

```dart
FutureBuilder<bool>(
  future: TeamUtils.canUserCreateTeam(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    final canCreate = snapshot.data ?? false;
    if (!canCreate) return const SizedBox.shrink();
    
    return ElevatedButton(
      onPressed: () => createTeam(),
      child: const Text('Criar Time'),
    );
  },
)
```

## Tratamento de Erros

Todas as funções incluem tratamento de erros interno e retornam valores padrão seguros em caso de falha:

- `isUserInTeam()` retorna `false` em caso de erro
- `getUserTeamId()` retorna `null` em caso de erro
- `getUserTeam()` retorna `null` em caso de erro
- `canUserCreateTeam()` retorna `false` em caso de erro

## Exemplo Completo

Veja o arquivo `lib/widgets/team_utils_example.dart` para um exemplo completo de como usar essas funções em um widget.
