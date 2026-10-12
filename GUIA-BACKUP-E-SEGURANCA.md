# Guia de segurança e backup — K d'praia Cangas

Última revisão: 12/10/2026

## 1. Versão estável do site

Foi criada a branch `versao-estavel-2026-10-12` para marcar uma versão testada do código.

- Loja Varejo: https://amorafut.github.io/kd-praia-cangas/
- Loja Atacado: https://amorafut.github.io/kd-praia-cangas/atacado/
- Repositório: https://github.com/amorafut/kd-praia-cangas

Antes de mudanças grandes, crie outra branch com a data ou registre uma versão/tag no GitHub. Não apague a branch estável antiga até a nova versão ser testada.

## 2. Backup dos dados do Supabase

O GitHub guarda o código do site, mas não faz backup automático dos pedidos, clientes e produtos armazenados no Supabase. Faça exportações periódicas dos dados dos dois projetos, separadamente.

### Projeto Varejo
1. Entre no painel do Supabase e abra o projeto do Varejo.
2. Acesse **Table Editor**.
3. Abra cada tabela importante (principalmente pedidos, itens dos pedidos e produtos).
4. Use a opção de exportar/baixar os dados em CSV, quando disponível.
5. Salve os arquivos numa pasta identificada como `Backup-Varejo-AAAA-MM-DD`.

### Projeto Atacado
Repita os mesmos passos no projeto do Atacado e salve em outra pasta: `Backup-Atacado-AAAA-MM-DD`.

**Atenção:** nunca misture os arquivos de Varejo e Atacado. Confira o nome do projeto antes de exportar.

## 3. Onde guardar

Mantenha pelo menos duas cópias dos backups, por exemplo:
- uma no computador;
- outra em armazenamento seguro na nuvem.

Os CSVs podem conter nomes, e-mails, telefones e endereços de clientes. Não os publique no GitHub nem os compartilhe por links públicos.

## 4. Frequência sugerida

- **Semanal:** exportar pedidos e itens de pedidos.
- **Mensal:** exportar produtos e demais tabelas importantes.
- **Antes de alterações importantes:** confirmar que existe um backup recente.

Se houver muitos pedidos, faça backup com maior frequência.

## 5. Segurança

- Nunca coloque senhas, tokens secretos ou chaves `service_role` no repositório.
- Não apague tabelas ou registros para “limpar” o sistema sem confirmar que existe backup.
- Depois de exportar, confira se os arquivos foram baixados e se não estão vazios.

## 6. Observação importante

Este guia é um procedimento manual; ele não executa nem agenda os backups automaticamente. A branch estável protege uma versão do código, mas não substitui o backup dos dados do Supabase.
