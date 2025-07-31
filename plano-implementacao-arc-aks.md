# Plano de Implementação: ARC no AKS com Otimização Docker

## Objetivo
Implementar um ambiente Azure Kubernetes Service (AKS) com Actions Runner Controller (ARC) para testar a otimização de pipelines, substituindo Docker-in-Docker (DinD) por bind mount do socket Docker do host.

## Contexto do Problema
- **Problema Atual**: Pipelines lentas devido ao uso de Docker-in-Docker (DinD)
- **Solução Proposta**: Usar bind mount do socket Docker do host (`/var/run/docker.sock`)
- **Benefícios Esperados**: Redução significativa do tempo de execução das pipelines

## Fase 1: Preparação do Ambiente Azure

### 1.1 Pré-requisitos
- [x] Azure CLI instalado e configurado (v2.68.0)
- [x] kubectl instalado (v1.32.1)
- [x] Helm instalado (v3.18.3)
- [x] Conta GitHub com permissões administrativas (organização: octocaio)
- [x] GitHub Personal Access Token (PAT) com escopo `repo` e `admin:org`

### 1.2 Configuração da Infraestrutura Azure (usando Terraform)
- [x] Criar estrutura Terraform para IaC
- [x] Executar terraform plan para validar configuração
- [x] Executar terraform apply para criar cluster AKS
- [x] Configurar kubectl para acessar o cluster
- [x] Verificar conectividade e funcionamento do cluster

### 1.3 Especificações do Cluster AKS
```yaml
Configurações Implementadas:
- Node Size: Standard_D2s_v3 (2 vCPUs, 8 GB RAM) - ajustado para quota disponível
- Node Count: 2 inicial, autoscaling 1-3 nodes (otimizado para teste)
- Kubernetes Version: 1.31.10 (última versão estável)
- Network Plugin: Azure CNI ✅
- Enable Container Insights: true ✅
- Enable Azure Policy: true ✅
- Log Analytics: aks-arc-test-logs ✅
- High Availability: Nodes distribuídos em zonas 1, 2, 3 ✅
```
**Status**: ✅ Concluída

## Fase 2: Instalação e Configuração do ARC

### 2.1 Instalação do ARC Controller
- [x] Adicionar repositório Helm do ARC
- [x] Instalar cert-manager (pré-requisito do ARC)
- [x] Criar namespace actions-runner-system
- [x] Instalar o ARC Controller via Helm
- [x] Criar secret controller-manager com GitHub PAT
- [x] Verificar pods do controller estão rodando
- [x] Configurar RBAC necessário (já incluído no Helm chart)

### 2.2 Configuração do GitHub Integration
- [x] Criar namespace para runners (github-runners)
- [x] Configurar secret com GitHub PAT
- [x] Criar RunnerDeployment básico para teste
- [x] Resolver erro de autenticação (401 Bad credentials)
  - ✅ Identificado problema: Fine-grained PAT não suporta runners
  - ✅ Criado Classic PAT com escopo admin:org
  - ✅ Testado API do GitHub com sucesso
- [x] Testar conectividade com GitHub
  - ✅ Runner conectado (versão 2.327.1)
  - ✅ Status: Listening for Jobs
  - ✅ Pod rodando (2/2 Ready)

### 2.3 Configuração do Runner com Docker Socket
- [x] Criar imagem customizada do runner
  - ✅ Dockerfile otimizado criado
  - ✅ Docker CLI instalado (sem daemon)
  - ✅ Usuário runner configurado no grupo docker
  - ✅ Imagem construída com sucesso (arc-runner-optimized:latest)
- [ ] Configurar bind mount do socket Docker
- [ ] Implementar security contexts apropriados
- [ ] Testar acesso ao Docker do host

## Fase 3: Implementação da Solução Docker Optimizada

### 3.1 Container Image Customizada
```dockerfile
# Exemplo da estrutura do Dockerfile
FROM ghcr.io/actions/actions-runner:latest
USER root
# Instalar Docker CLI (sem Docker daemon)
RUN apt-get update && apt-get install -y docker.io
# Configurar permissões para acessar socket
RUN usermod -aG docker runner
USER runner
```

### 3.2 RunnerScaleSet Configuration
```yaml
# Configuração para bind mount do socket Docker
spec:
  template:
    spec:
      containers:
      - name: runner
        volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
        securityContext:
          privileged: false
          runAsUser: 1000
      volumes:
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
          type: Socket
```

### 3.3 Configurações de Segurança
- [ ] Implementar Pod Security Standards
- [ ] Configurar Network Policies
- [ ] Implementar RBAC granular
- [ ] Configurar monitoring e logging

## Fase 4: Testes e Validação

### 4.1 Testes Funcionais
- [ ] Teste básico de execução de job
- [ ] Teste de build de container
- [ ] Teste de execução de containers durante pipeline
- [ ] Validação de conectividade de rede

### 4.2 Testes de Performance
- [ ] Benchmark: Pipeline com DinD vs Bind Mount
- [ ] Medição de tempo de startup de containers
- [ ] Análise de uso de recursos (CPU/Memory)
- [ ] Teste de escala automática

### 4.3 Pipeline de Teste
```yaml
# Exemplo de workflow para teste
name: Test Docker Performance
on: [push]
jobs:
  test-docker:
    runs-on: self-hosted
    steps:
    - uses: actions/checkout@v4
    - name: Build Test Container
      run: |
        docker build -t test-app .
        docker run --rm test-app npm test
    - name: Performance Test
      run: |
        time docker run --rm alpine echo "Performance test"
```

## Fase 5: Otimização e Monitoramento

### 5.1 Monitoramento
- [ ] Configurar Azure Monitor
- [ ] Implementar dashboards de performance
- [ ] Configurar alertas para problemas
- [ ] Monitoramento de recursos do cluster

### 5.2 Otimizações Adicionais
- [ ] Configurar cache de imagens Docker
- [ ] Implementar image pull policies otimizadas
- [ ] Configurar resource limits adequados
- [ ] Otimizar scheduling de pods

## Fase 6: Documentação e Entrega

### 6.1 Documentação
- [ ] Guia de deployment
- [ ] Troubleshooting guide
- [ ] Best practices documentadas
- [ ] Comparativo de performance DinD vs Bind Mount

### 6.2 Entrega
- [ ] Ambiente funcional em produção
- [ ] Documentação completa
- [ ] Scripts de automação
- [ ] Plano de migração para outros ambientes

## Cronograma Estimado
- **Fase 1**: 1-2 dias
- **Fase 2**: 2-3 dias
- **Fase 3**: 3-4 dias
- **Fase 4**: 2-3 dias
- **Fase 5**: 1-2 dias
- **Fase 6**: 1 dia

**Total**: 10-15 dias úteis

## Riscos e Mitigações

### Riscos Identificados
1. **Segurança**: Acesso ao socket Docker do host
   - **Mitigação**: Implementar security contexts rigorosos e Pod Security Standards

2. **Performance**: Concorrência no socket Docker
   - **Mitigação**: Configurar limits de recursos e monitoring

3. **Compatibilidade**: Versões do Docker/Kubernetes
   - **Mitigação**: Testes extensivos e uso de versões LTS

## Próximos Passos
1. Revisar e aprovar este plano
2. Configurar ambiente de desenvolvimento
3. Iniciar Fase 1: Preparação do Ambiente Azure

---

**Status**: 🟡 Aguardando aprovação e início da implementação
**Última Atualização**: 31/07/2025
