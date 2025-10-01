import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:passaabola/data/constants.dart';
import '../data/auth_roles.dart';
import 'jogadora_dashboard_page.dart';

/// PÁGINA DE JOGADORAS DE UM TIME ESPECÍFICO
///
/// Esta página é responsável por:
/// 1. Receber um time como parâmetro
/// 2. Buscar as jogadoras desse time na API
/// 3. Exibir as jogadoras em uma lista
/// 4. Mostrar informações detalhadas de cada jogadora
class JogadorasTimePage extends StatefulWidget {
  // Parâmetro obrigatório: dados do time selecionado
  final Map<String, dynamic> team;

  const JogadorasTimePage({
    super.key,
    required this.team, // Obrigatório: time que foi clicado
  });

  @override
  State<JogadorasTimePage> createState() => _JogadorasTimePageState();
}

class _JogadorasTimePageState extends State<JogadorasTimePage> {
  // CONFIGURAÇÕES DA API
  final String apiKey = '47886f91ab8bc012bf6d156b05bd4514';
  final String baseUrl = 'https://v3.football.api-sports.io';

  // ESTADO DA PÁGINA
  List<dynamic> players = []; // Lista de jogadoras
  bool isLoading = false; // Se está carregando
  String? errorMessage; // Mensagem de erro se houver

  /// MÉTODO INITSTATE
  ///
  /// Este método é chamado automaticamente quando a página é criada.
  /// Aqui iniciamos o carregamento das jogadoras.
  @override
  void initState() {
    super.initState();
    _fetchPlayers(); // Chama a função para buscar jogadoras
  }

  /// FUNÇÃO PARA BUSCAR JOGADORAS
  ///
  /// Esta função:
  /// 1. Pega o ID do time
  /// 2. Faz requisição para a API
  /// 3. Processa a resposta
  /// 4. Atualiza a interface
  Future<void> _fetchPlayers() async {
    print('🔄 Iniciando busca de jogadoras...');

    // Ativa o indicador de carregamento
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Pega o ID do time que foi passado como parâmetro
      final teamId = widget.team['id'];
      final url = '$baseUrl/players?team=$teamId&season=2023';

      print('🏈 Buscando jogadoras do time ID: $teamId');
      print('🔗 URL da requisição: $url');

      // Faz a requisição HTTP para a API
      final response = await http.get(
        Uri.parse(url),
        headers: {'x-apisports-key': apiKey},
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Conteúdo da resposta: ${response.body}');

      // Verifica se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        // Converte a resposta JSON em um objeto Dart
        final data = json.decode(response.body);

        // Verifica se há dados na resposta
        if (data['response'] != null) {
          setState(() {
            players = data['response']; // Salva as jogadoras
          });
          print('✅ Jogadoras encontradas: ${players.length}');
        } else {
          print('⚠️ Nenhuma jogadora encontrada na resposta');
        }
      } else {
        // Se a requisição falhou, lança uma exceção
        throw Exception('Erro ao carregar jogadoras: ${response.statusCode}');
      }
    } catch (e) {
      // Se algo deu errado, mostra o erro
      setState(() {
        errorMessage = 'Erro ao carregar jogadoras: $e';
      });
      print('❌ Erro ao buscar jogadoras: $e');
    } finally {
      // Sempre desativa o carregamento, mesmo se der erro
      setState(() {
        isLoading = false;
      });
      print('🏁 Busca de jogadoras finalizada');
    }
  }

  /**
   * MÉTODO BUILD - CONSTRÓI A INTERFACE
   * 
   * Este método define como a página vai aparecer na tela.
   * Ele é chamado sempre que o estado da página muda.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRA SUPERIOR (AppBar)
      appBar: AppBar(
        title: Text(widget.team['name'] ?? 'Jogadoras'), // Nome do time
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),

      // CORPO DA PÁGINA
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CARD COM INFORMAÇÕES DO TIME
            _buildTeamHeader(),
            const SizedBox(height: 16),

            // LISTA DE JOGADORAS
            Expanded(child: _buildPlayersList()),
          ],
        ),
      ),
    );
  }

  /**
   * WIDGET PARA MOSTRAR INFORMAÇÕES DO TIME
   * 
   * Cria um card bonito com logo, nome e ID do time
   */
  Widget _buildTeamHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Logo do time (ou ícone se não tiver logo)
            widget.team['logo'] != null
                ? Image.network(
                    widget.team['logo'],
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.sports_soccer, size: 60);
                    },
                  )
                : const Icon(Icons.sports_soccer, size: 60),
            const SizedBox(width: 16),

            // Informações do time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.team['name'] ?? 'Nome não disponível',
                    style: KTextStyle.titleText.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: ${widget.team['id']}',
                    style: KTextStyle.bodySecondaryText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * WIDGET PARA MOSTRAR A LISTA DE JOGADORAS
   * 
   * Este método decide o que mostrar baseado no estado:
   * - Carregando: mostra spinner
   * - Erro: mostra mensagem de erro
   * - Vazio: mostra mensagem de "nenhuma jogadora"
   * - Com dados: mostra a lista de jogadoras
   */
  Widget _buildPlayersList() {
    if (isLoading) {
      // Se está carregando, mostra um spinner
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      // Se houve erro, mostra mensagem de erro com botão para tentar novamente
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPlayers, // Tenta buscar novamente
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (players.isEmpty) {
      // Se não há jogadoras, mostra mensagem informativa
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma jogadora encontrada'),
            SizedBox(height: 8),
            Text(
              'Este time pode não ter jogadoras cadastradas na temporada 2023',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Se há jogadoras, mostra a lista
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        return _buildPlayerCard(players[index]);
      },
    );
  }

  /**
   * WIDGET PARA MOSTRAR UMA JOGADORA
   * 
   * Cria um card para cada jogadora com suas informações
   */
  Widget _buildPlayerCard(Map<String, dynamic> playerData) {
    final player = playerData['player'];
    // final statistics = playerData['statistics']; // Removido pois não está sendo usado

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        // Foto da jogadora (ou ícone se não tiver)
        leading: player['photo'] != null
            ? Image.network(
                player['photo'],
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 50);
                },
              )
            : const Icon(Icons.person, size: 50),

        // Nome da jogadora
        title: Text(
          player['name'] ?? 'Nome não disponível',
          style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),

        // Informações adicionais
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (player['age'] != null) Text('Idade: ${player['age']}'),
            if (player['position'] != null)
              Text('Posição: ${player['position']}'),
            if (player['nationality'] != null)
              Text('Nacionalidade: ${player['nationality']}'),
          ],
        ),

        // Seta indicando que é clicável (para futuras funcionalidades)
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          // Apenas olheiro pode abrir a dashboard detalhada
          final role = await RoleService().getCurrentUserRole();
          if (role == UserRole.olheiro) {
            if (!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JogadoraDashboardPage(playerData: playerData),
              ),
            );
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recurso disponível apenas para olheiros.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
