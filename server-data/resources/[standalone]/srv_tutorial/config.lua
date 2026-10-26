-- Servidor: the in-game tutorial, opened with /tutorial (aliases /ajuda, /guia).
--
-- Built on `lib.registerContext` and `lib.alertDialog` rather than a custom NUI page, deliberately:
-- those two ARE this project's standard layout - the monochrome GFX reskin, the search box past 8
-- rows and the arrow/Enter/Backspace navigation all come for free, and there is no build step or
-- deployed bundle to keep in sync (CLAUDE.md rule 9 has bitten this project before).
--
-- EVERY number and command below was read out of the live config it describes, not remembered.
-- The sources are named per section so a future edit can re-check them:
--
--   pay per stop            srv_jobs/config.lua
--   input prices, brick     srv_<farm>/config.lua (seedPrice/leafPrice/precursorPrice/
--                           inputPrice/materialPrice, brickPrice)
--   times                   growthMinutes / processingMinutes in the same files
--   gang ownership          ownerGang in the same files (ADR-125)
--   keys                    docs/operations.md, itself checked against the resources
--
-- A tutorial that drifts from the config is worse than no tutorial, so if a number moves, it moves
-- here in the same change. See ADR-129.

Config = {}

--- Sections, in the order they appear. `body` is ox_lib alert markdown.
Config.sections = {
    {
        id = 'start',
        icon = 'flag-checkered',
        title = 'Primeiros Passos',
        description = 'Como começar no servidor.',
        body = [[
**1. Documentos.** Vá à Prefeitura e tire seu RG e a habilitação. Sem habilitação você não
compra veículo.

**2. Dinheiro inicial.** Pegue um emprego legal na Prefeitura. Todos pagam por entrega
concluída — você não precisa ficar online esperando salário.

**3. Veículo.** Com dinheiro e habilitação, compre na concessionária. Use a garagem para
guardar e retirar.

**4. Celular.** Você começa com um. Nele estão contatos, banco, garagem e mensagens.

**5. Interação.** A tecla **E** resolve quase tudo no mundo — portas, balcões, estações de
trabalho. O menu redondo (**Z**) tem as ações de roleplay.
]],
    },
    {
        id = 'keys',
        icon = 'keyboard',
        title = 'Teclas',
        description = 'O que cada tecla faz.',
        body = [[
| Tecla | Ação |
|:---|:---|
| **E** | Interagir (portas, balcões, estações) |
| **Z** | Menu redondo — ações, roupas, veículo, gangue |
| **H** | Mãos ao alto (segurar) |
| **X** ou **F6** | Parar a animação atual |
| **↓** | Assoviar |
| **→** | Reação de decepção |
| **F5** | Menu completo de emotes |
| **K** | Agachar |
| **Y** | Piloto automático (no carro) |
| **R** | Recarregar arma |
| **Alt esquerdo** | Mira de interação |
| **Caps Lock** | Falar no rádio (segurar) |
| **1–5** | Atalhos do inventário |
| **M** | Celular |
| **F10** | Placar do servidor |
| **F11** | Alcance da voz — sussurro, normal, grito |

Todas podem ser trocadas nas configurações de teclas do próprio FiveM.
]],
    },
    {
        id = 'commands',
        icon = 'terminal',
        title = 'Comandos',
        description = 'Você não precisa decorar nenhum — está tudo no Z.',
        body = [[
**Não decore comandos. Aperte Z.**

Tudo que você faria por comando está no menu redondo, organizado por assunto:

| No menu **Z** | Faz o mesmo que |
|:---|:---|
| Comunicação → Ação | `/me` |
| Comunicação → Fora do Personagem | `/ooc` |
| Comunicação → Chamar Polícia | `/911p` |
| Comunicação → Chamar Ambulância | `/911e` |
| Comunicação → Falar com a Administração | `/report` |
| Meu Personagem → Documento | `/documento` (substitui `/job` e `/gang`) |
| Meu Personagem → Cancelar Ação | `/cancelprogress` |
| Cidadão → Entrar no Porta-Malas | `/getintrunk` |
| Cidadão → Interação → Colocar no Porta-Malas | `/putintrunk` |
| Ações | emotes, danças e reações |
| Menu de Emotes → Estilos de Andar | `/w` |
| Menu de Emotes → Expressões Faciais | `/f` |
| Menu de Emotes → Abrir Menu | `/em` (ou F5) |

As opções que precisam de texto — uma ação, um chamado, uma denúncia — abrem uma caixinha
para você escrever. É o mesmo resultado do comando.

**Os comandos continuam funcionando.** Se você prefere digitar, nada foi tirado. O menu é um
segundo caminho, não uma substituição.
]],
    },
    {
        id = 'legaljobs',
        icon = 'briefcase',
        title = 'Empregos Legais',
        description = 'Cinco empregos, pagamento por entrega.',
        body = [[
Pegue qualquer um na **Prefeitura**. Nenhum é exclusivo — troque quando quiser. O pagamento é
por parada concluída, então rende enquanto você joga, não enquanto você espera.

| Emprego | Por entrega |
|:---|:---|
| Guincho | **$375** |
| Caminhoneiro | $150 |
| Taxista | $120 |
| Motorista de Ônibus | $100 |
| Lixeiro | $90 |

O guincho paga mais porque exige mais: o trabalho real de rebocar, e não só dirigir até um
ponto.

Todos seguem o mesmo formato — pegue o veículo marcado, siga o GPS até cada parada, conclua,
receba.
]],
    },
    {
        id = 'illegal',
        icon = 'cannabis',
        title = 'Produção Ilegal',
        description = 'As seis produções e quem manda em cada uma.',
        body = [[
São seis locais de produção, e **cada um pertence a uma gangue**:

| Produção | Gangue dona |
|:---|:---|
| Maconha | Families |
| Cocaína | Cartel |
| Metanfetamina | Lost MC |
| Crack | Ballas |
| Armas | Triads |
| Munição | Vagos |

**Só membros da gangue dona** podem comprar o insumo, entrar no local, trabalhar as estações,
prensar e vender no atacado.

**Sem gangue você ainda tem trabalho ilegal:** comprar no varejo e rodar a rota de venda na
rua continua aberto a todo mundo. O que a gangue controla é a *produção*, não o comércio.

Escolha uma seção abaixo para o passo a passo de cada tipo.
]],
    },
    {
        id = 'drugs',
        icon = 'flask',
        title = 'Farms de Droga',
        description = 'Maconha, cocaína, metanfetamina e crack.',
        body = [[
As quatro funcionam com os mesmos números — nenhuma é melhor que a outra.

**O ciclo**

1. **Compre o insumo** com o vendedor do local — **$300** por unidade.
2. **Trabalhe uma estação** com o insumo. Leva **3 horas reais** (a maconha cresce no mesmo
   tempo).
3. **Colete** o resultado: **5 unidades** por estação.
4. **Prense** 5 unidades para virar 1 tijolo, na bancada do local.
5. **Venda o tijolo** ao comprador do local — **$3.500** cada.

**A conta:** 5 insumos custam $1.500 e viram um tijolo de $3.500. Lucro de **$2.000** por
ciclo, mais o tempo de espera.

**Varejo.** Cada tijolo vendido reabastece o estoque de rua do comprador. Aí qualquer um —
com gangue ou sem — pode comprar doses no varejo e sair vendendo na rua.

Trabalhar várias estações ao mesmo tempo é o que faz a diferença: o tempo é o mesmo para uma
ou para nove.
]],
    },
    {
        id = 'guns',
        icon = 'gun',
        title = 'Armas e Munição',
        description = 'As duas produções rápidas.',
        body = [[
Funcionam diferente das drogas: **muito mais rápidas**, e o que sai fica com você — não há
comprador NPC.

**Armas** (Triads)

1. Compre **sucata** com o vendedor — $150 cada.
2. Estação: **4 sucatas → 1 peça de arma**, em 2 minutos.
3. Bancada: **4 peças → 1 arma**, em 2 minutos. Você escolhe entre 10 armas.

**Munição** (Vagos)

1. Compre **cobre** com o vendedor — $120 cada.
2. Estação: **4 cobres → 1 peça de munição**, em 2 minutos.
3. Bancada: **4 peças → um pacote de 200 balas**, em 2 minutos. Seis calibres.

**Importante:** toda arma sai **não registrada**. Ela é ilegal por definição — a polícia
identifica isso.

Como não há comprador NPC, a saída é vender para outro jogador. Use a troca segura do menu de
interação, que só conclui quando os dois confirmam.
]],
    },
    {
        id = 'gangs',
        icon = 'users',
        title = 'Gangues',
        description = 'Como funcionam e o que elas têm.',
        body = [[
São seis gangues, cada uma com quatro patentes: **Recruta, Executor, Chefia e Chefe**.

**Como entrar.** Só o Chefe de uma gangue pode contratar. Procure a liderança no jogo.

**O que a gangue tem**

- **Território:** a produção do local dela é exclusiva dos membros.
- **Baú compartilhado:** abre pelo menu **Z** → Gangue → Baú, e **só funciona dentro do
  território da gangue**. Cabe dinheiro também.
- **Conta bancária:** toda gangue tem uma no Fleeca. Só o **Chefe** administra — ele escolhe
  a conta no `[E]` do caixa.

Um Executor não enxerga a conta da gangue. Isso é regra do servidor, não configuração de
menu.
]],
    },
    {
        id = 'economy',
        icon = 'sack-dollar',
        title = 'Economia',
        description = 'Onde ganha, onde gasta.',
        body = [[
**Dinheiro em espécie x banco**

Espécie você carrega e **pode perder** — a polícia apreende, um assalto leva. O banco é
seguro. Guarde o que não vai usar.

**Onde ganhar**

- Empregos legais — $90 a $375 por entrega, sem risco.
- Produção ilegal — ~$2.000 por ciclo de droga, com risco e exigindo gangue.
- Venda de rua no varejo — aberto a todos.
- Roubos — lojas e casas, exigem polícia em serviço.

**Onde gastar**

- Veículos, roupas e o guarda-roupa.
- Insumo das farms.
- Ferramentas na loja de ferramentas: lockpick, algemas, corda, kits de reparo.
- Manutenção: **Kit de Reparo** (motor), **Kit de Lataria** (amassados), **Kit de Limpeza**
  (sujeira) — cada um resolve uma coisa só.

**Conselho:** o legal paga menos mas nunca te faz perder o que já tem. O ilegal paga mais e
pode custar tudo que você está carregando.
]],
    },
    {
        id = 'police',
        icon = 'shield-halved',
        title = 'Polícia e Prisão',
        description = 'O que acontece quando dá errado.',
        body = [[
**Ser abordado.** Segure **X** para levantar as mãos. Isso trava seu disparo — é o sinal
claro de que você não vai reagir.

**Algemas e corda.** Ambas prendem do mesmo jeito. A diferença é sair:

- **Corda:** qualquer pessoa solta.
- **Algema:** só o policial que algemou tem a chave. Outra pessoa precisa de **lockpick**, e
  há chance de quebrar tentando.

**Apreensão.** A polícia pode revistar você e apreender dinheiro em espécie e itens ilegais.
O que está no banco não é alcançável.

**Cadeia.** Condenado, você cumpre tempo na prisão. Há o que fazer lá dentro.

**Arma não registrada.** Toda arma de produção ilegal é. Ser pego com uma é problema por si
só.
]],
    },
}
