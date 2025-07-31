# Caching no GitHub Actions: Melhores Práticas & Exemplos com Node.js

---

## 1. Introdução ao Cache em GitHub Actions

- **Cache** acelera pipelines, reduz downloads e builds repetitivos.
- Benefícios:
  - Menos tempo de execução.
  - Redução de custo em infra.
  - Menor dependência de disponibilidade de terceiros.

---

## 2. Como funciona o cache (`actions/cache`)

- Utiliza a **action oficial**: `actions/cache`
- Armazena arquivos/pastas entre execuções de workflow.
- Chave de cache (`key`) define quando usar/restaurar o cache.
- Restore keys permitem fallback para caches parecidos.

**Fluxo:**
1. Tenta restaurar cache.
2. Se não existir, executa normalmente.
3. Salva novo cache ao final, se necessário.

---

## 3. Melhores Práticas de Cache

- **Chaves específicas**: Inclua hash de dependências (ex: `package-lock.json`).
- **Evite cache obsoleto**: Atualize chave ao mudar dependências.
- **Limite tamanho**: Não faça cache de pastas gigantes (ex: `node_modules` inteiro de mono-repo).
- **Segurança**: Não faça cache de arquivos sensíveis.
- **Restore keys**: Permite fallback para versões anteriores.
- **Limpe cache quando necessário**: Mude chave para forçar atualização.

---

## 4. Exemplo Prático: Cache de Dependências Node.js

```yaml
name: CI with Node.js Cache

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache node_modules
        uses: actions/cache@v4
        with:
          path: node_modules
          key: node-modules-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            node-modules-${{ runner.os }}-

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

**Explicação:**
- O cache é salvo/restaurado usando o hash do `package-lock.json`: muda quando dependências mudam.
- Fallback para outros caches da mesma OS caso não exista chave exata.
- O comando `npm ci` garante instalação limpa.

---

## 5. Debugging de Cache

- **Visualize logs no GitHub Actions:**  
  Procure por mensagens como:
  - `Cache not found for input keys...`
  - `Cache restored from key...`
  - `Cache saved with key...`
- **Forçar atualização:**  
  - Alterar chave manualmente.
- **Problemas comuns:**  
  - Caminho (`path`) errado.
  - Chave não muda quando deveria.
  - Tamanho do cache ultrapassa limite (5GB por cache).

**Dica:**  
Adicione step para inspecionar se o cache foi restaurado:

```yaml
      - name: Checar se node_modules existe após cache
        run: ls -la node_modules
```

---

## 6. Armadilhas Comuns

- Cache "stale": Chave não muda, dependências mudam => conflitos ou erros.
- Cache grande demais: Pode ser ignorado ou demorado.
- Cache em branches diferentes: Chaves podem não bater.
- Cache de arquivos temporários/sensíveis: Evite!

---

## 7. Recursos & Q&A

- [Documentação oficial do GitHub Actions Cache](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [Exemplos de cache para outras linguagens](https://github.com/actions/cache/blob/main/examples.md)
- [Limites de cache do GitHub Actions](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows#cache-limits)

**Perguntas?**

---
