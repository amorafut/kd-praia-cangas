# K d'praia Cangas — site de catálogo

## Incluído
- Catálogo responsivo de cangas (prioridade) e produtos de exemplo de bolsas.
- Busca, filtros, ordenação, página/modal individual, carrinho persistente no navegador.
- Finalização por WhatsApp com resumo do pedido e frete combinado manualmente.
- Painel para cadastrar, editar e excluir produtos e fotos.
- Integração opcional com Supabase Auth, Database e Storage.
- Logomarca horizontal no cabeçalho/rodapé e logomarca circular na seção da marca.
- Arquivos das logomarcas otimizados em `assets/`.

## Publicação no GitHub Pages
1. Crie um repositório NOVO e público no GitHub, por exemplo `kd-praia-cangas`. Não use o repositório da Amora Fut para manter as marcas separadas.
2. Envie `index.html`, `supabase-config.js`, `supabase-schema.sql`, `LEIA-ME.md` e a pasta `assets/` para a raiz do repositório.
3. Em Settings → Pages, habilite deploy a partir da branch `main`, pasta `/ (root)`.
4. O endereço seguirá o formato `https://SEU-USUARIO.github.io/NOME-DO-REPOSITORIO/`.

## Configurar banco e painel seguro (Supabase)
1. Crie um projeto no Supabase.
2. No SQL Editor, execute todo o conteúdo de `supabase-schema.sql`.
3. Em Authentication, crie o usuário do administrador com e-mail e senha.
4. Copie o UUID do usuário criado e execute o `insert into public.admin_users ...` comentado no final do SQL.
5. Copie a Project URL e a chave publicável/anon do Supabase para `supabase-config.js`. Nunca use `service_role` no site.
6. Faça commit e aguarde o GitHub Pages publicar.
7. Entre no painel pelo ícone de engrenagem, usando o e-mail e a senha criados no Supabase.

## WhatsApp
O número comercial foi configurado como `5585997102886` (55 + DDD 85 + número). Confira se é o número correto antes de divulgar.

## Importante antes de vender
- O painel só é realmente protegido e compartilhado entre dispositivos depois de configurar o Supabase corretamente e adicionar o usuário à tabela `admin_users`.
- Não publique a chave `service_role`. O navegador deve usar apenas a chave publicável/anon, com as políticas RLS do SQL.
- O carrinho fica no navegador do cliente; o pedido é encaminhado ao WhatsApp. Não existe gateway de pagamento ou cálculo automático de frete neste projeto.
- Os produtos iniciais são exemplos; substitua por fotos, preços, medidas e descrições reais.
- Para publicar fotos de produtos, o bucket `product-images` é público para leitura e somente administradores autorizados podem gravar.
