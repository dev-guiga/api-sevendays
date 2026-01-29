# Plano de melhorias do projeto (Rails) — versao objetiva

Documento especifico do projeto atual, com melhorias alinhadas ao Rails Way. Cada item traz: problema, objetivo, acao concreta e criterio de pronto. Prioridade do mais critico ao menos critico.

## 1) Autenticacao e sessao (PRIORIDADE: MUITO ALTA)
**Problema**: fluxo de autenticacao inconsistente e possivel conflito com helpers padrao.
**Objetivo**: um unico caminho de auth, previsivel e seguro.
**Acoes**:
- Remover overrides que conflitam com o mecanismo de auth.
- Centralizar `current_user` e `authenticate_user!` em um fluxo unico.
- Revisar login/logout para garantir sessao consistente.
**Pronto quando**:
- Login/logout funcionam em todos os endpoints.
- `current_user` vem sempre da mesma fonte.
- Testes de auth passam sem mocks inconsistentes.

## 2) Tratativa de erros (PRIORIDADE: ALTA)
**Problema**: respostas de erro variam por controller e nao ha padrao unico.
**Objetivo**: erros previsiveis e consistentes.
**Acoes**:
- Criar resposta padrao: `{ error: { code, message, details } }`.
- Centralizar `rescue_from` para erros comuns (not found, validation, authorization).
- Garantir status HTTP corretos em todas as acoes.
**Pronto quando**:
- Todos os erros retornam no mesmo formato.
- Status HTTP e mensagens sao consistentes.

## 3) RESTful e rotas (PRIORIDADE: ALTA)
**Problema**: endpoints customizados fogem do padrao REST.
**Objetivo**: rotas idiomaticas e faceis de manter.
**Acoes**:
- Migrar para `resources` quando possivel.
- Remover verbos no path e alinhar actions padrao.
- Documentar claramente excecoes inevitaveis.
**Pronto quando**:
- Rotas principais seguem recursos e acoes REST.
- Documentacao reflete o padrao.

## 4) Services (PRIORIDADE: MEDIA)
**Problema**: services fora do padrao e nomes inconsistentes.
**Objetivo**: padrao unico e previsivel.
**Acoes**:
- Mover para `app/services`.
- Renomear para singular (ex: `CreateDiaryService`).
- Adotar interface padrao: `call` + retorno consistente (`success?`, `errors`, `payload`).
**Pronto quando**:
- Todos os services seguem o mesmo padrao de pasta, nome e interface.

## 5) Models e regras de negocio (PRIORIDADE: MEDIA)
**Problema**: metodos longos e validacoes nao idiomaticas.
**Objetivo**: modelos menores e mais testaveis.
**Acoes**:
- Quebrar metodos longos em validadores/metodos menores.
- Remover validacoes de timestamps.
- Usar `enum` para status.
**Pronto quando**:
- Metodos complexos estao divididos.
- Validacoes refletem apenas regras de negocio.

## 6) Controllers e resposta JSON (PRIORIDADE: MEDIA)
**Problema**: controllers com logica excessiva e renders inconsistentes.
**Objetivo**: controllers finos e padronizados.
**Acoes**:
- Controllers apenas orquestram (chamam service/queries).
- Respostas seguem o mesmo formato JSON.
- Evitar render sem `return` em callbacks.
**Pronto quando**:
- Controllers estao simples e consistentes.
- JSON de resposta segue o mesmo esquema.

## 7) Testes e CI (PRIORIDADE: MEDIA)
**Problema**: cobertura parcial e pipeline desalinhada com o runner real.
**Objetivo**: confiabilidade e feedback rapido.
**Acoes**:
- Garantir que CI rode o mesmo runner usado localmente.
- Adicionar specs para services e request specs.
- Cobrir fluxos principais (auth, CRUD principal, erros).
**Pronto quando**:
- CI passa com a mesma suite usada localmente.
- Fluxos criticos cobertos.

## 8) Infra e configuracao (PRIORIDADE: BAIXA)
**Problema**: pequenos desalinhamentos entre config local e docker.
**Objetivo**: setup previsivel.
**Acoes**:
- Alinhar configs de DB com ambiente containerizado.
- Garantir que CORS esteja correto para consumo externo.
**Pronto quando**:
- Ambiente local sobe sem ajustes manuais.

## 9) Documentacao (PRIORIDADE: BAIXA)
**Problema**: README sem guia pratico.
**Objetivo**: onboarding rapido.
**Acoes**:
- Adicionar setup, comandos essenciais e exemplos de requests.
- Listar endpoints principais e fluxos basicos.
**Pronto quando**:
- Novo dev consegue rodar e testar em poucos minutos.

## Checklist de avaliacao (OK / Medio / Ruim)
1. Autenticacao e sessao
2. Tratativa de erros
3. RESTful e rotas
4. Services
5. Models e regras de negocio
6. Controllers e JSON
7. Testes e CI
8. Infra e configuracao
9. Documentacao

## Resultado esperado
- Codigo mais idiomatico e previsivel.
- Menos duplicacao e menor complexidade nos controllers.
- Regras de negocio isoladas e testaveis.
- API consistente e facil de consumir.
