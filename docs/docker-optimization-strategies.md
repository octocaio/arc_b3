# 🚀 Estratégias de Otimização Docker para GitHub Actions Runners

## 📋 **Cenários de Deployment**

### **Cenário A: Containerd Bind Mount (AKS - Produção)**
- **Realidade**: Cliente usa AKS que roda `containerd`
- **Solução**: Bind mount do socket containerd
- **Status**: ✅ Implementado

### **Cenário B: Docker-in-Docker Otimizado (Fallback)**
- **Realidade**: Quando bind mount não é possível
- **Solução**: DinD com otimizações específicas
- **Status**: 📝 Documentado para referência

---

## 🎯 **Cenário A: Containerd Bind Mount (Implementado)**

### **Configuração**
```yaml
# Bind mount do socket containerd (AKS)
volumeMounts:
- name: containerd-sock
  mountPath: /run/containerd/containerd.sock
  readOnly: false

volumes:
- name: containerd-sock
  hostPath:
    path: /run/containerd/containerd.sock
    type: Socket
```

### **Vantagens**
- ✅ **Performance máxima**: Sem overhead de DinD
- ✅ **Uso direto do runtime**: Acesso nativo ao containerd
- ✅ **Menor uso de recursos**: CPU e memória otimizados
- ✅ **Cache compartilhado**: Layers compartilhadas entre builds

### **Considerações**
- ⚠️ **Dependência do runtime**: Funciona apenas com containerd
- ⚠️ **Permissões**: Requer configuração de security context
- ⚠️ **Compatibilidade**: Docker CLI precisa ser configurado para containerd

---

## 🛠️ **Cenário B: Docker-in-Docker Otimizado (Documentação)**

### **Estratégia 1: DinD com Cache Persistente**

```yaml
spec:
  template:
    spec:
      # Habilitar DinD otimizado
      dockerEnabled: true
      dockerdWithinRunnerContainer: true
      
      # 🔑 OTIMIZAÇÃO: Volume persistente para cache
      volumes:
      - name: docker-cache
        persistentVolumeClaim:
          claimName: docker-cache-pvc
      
      volumeMounts:
      - name: docker-cache
        mountPath: /var/lib/docker
        
      # 🔑 OTIMIZAÇÃO: Configurações do dockerd
      dockerEnv:
      - name: DOCKER_DRIVER
        value: "overlay2"
      - name: DOCKER_STORAGE_DRIVER  
        value: "overlay2"
      - name: DOCKERD_ROOTLESS
        value: "false"
```

### **Estratégia 2: DinD com Registry Mirror**

```yaml
spec:
  template:
    spec:
      # 🔑 OTIMIZAÇÃO: Mirror registry para cache de imagens
      dockerRegistryMirror: "https://mirror.gcr.io"
      
      # 🔑 OTIMIZAÇÃO: MTU otimizado para rede
      dockerMTU: 1500
      
      # 🔑 OTIMIZAÇÃO: Recursos dedicados para dockerd
      dockerdContainerResources:
        requests:
          cpu: "100m"
          memory: "256Mi"
        limits:
          cpu: "500m"
          memory: "1Gi"
```

### **Estratégia 3: DinD com BuildKit Otimizado**

```yaml
spec:
  template:
    spec:
      # 🔑 OTIMIZAÇÃO: Variáveis para BuildKit
      dockerEnv:
      - name: DOCKER_BUILDKIT
        value: "1"
      - name: BUILDKIT_PROGRESS
        value: "plain"
      - name: BUILDKIT_CACHE_MOUNT_NAMESPACE
        value: "runner-cache"
        
      # 🔑 OTIMIZAÇÃO: Cache BuildKit persistente  
      volumes:
      - name: buildkit-cache
        hostPath:
          path: /tmp/buildkit-cache
          type: DirectoryOrCreate
          
      volumeMounts:
      - name: buildkit-cache
        mountPath: /tmp/buildkit-cache
```

---

## 📊 **Comparação de Performance**

| Método | CPU Overhead | Memory Overhead | Build Speed | Complexidade |
|--------|--------------|-----------------|-------------|--------------|
| **Containerd Bind Mount** | Muito Baixo | Muito Baixo | Muito Rápido | Baixa |
| **DinD Padrão** | Alto | Alto | Lento | Baixa |
| **DinD + Cache PVC** | Médio | Alto | Médio | Média |
| **DinD + Registry Mirror** | Alto | Alto | Médio | Média |
| **DinD + BuildKit** | Médio | Alto | Rápido | Alta |

---

## 🎯 **Recomendações por Cenário**

### **Para AKS/EKS/GKE (containerd)**
1. ✅ **Primeira escolha**: Containerd bind mount
2. 🔄 **Fallback**: DinD + BuildKit + Cache PVC

### **Para Clusters Legados (Docker Engine)**
1. ✅ **Primeira escolha**: Docker socket bind mount
2. 🔄 **Fallback**: DinD otimizado

### **Para Ambientes Restritivos**
1. ✅ **Única opção**: DinD com todas as otimizações
2. 📝 **Foco**: Cache persistente + Registry mirror

---

## 🔧 **Implementação das Otimizações DinD**

### **PVC para Cache Docker**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: docker-cache-pvc
  namespace: actions-runner-system
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: managed-premium
```

### **ConfigMap para Registry Mirror**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-daemon-config
  namespace: actions-runner-system
data:
  daemon.json: |
    {
      "registry-mirrors": ["https://mirror.gcr.io"],
      "storage-driver": "overlay2",
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
    }
```

### **RunnerDeployment Completo Otimizado**
```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: arc-runner-dind-optimized
  namespace: actions-runner-system
spec:
  replicas: 2
  template:
    spec:
      organization: octocaio
      image: aksarctestregistry.azurecr.io/arc-runner-optimized:latest
      
      # DinD otimizado
      dockerEnabled: true
      dockerdWithinRunnerContainer: true
      dockerRegistryMirror: "https://mirror.gcr.io"
      dockerMTU: 1500
      
      # Recursos para dockerd
      dockerdContainerResources:
        requests:
          cpu: "200m"
          memory: "512Mi"
        limits:
          cpu: "1000m"
          memory: "2Gi"
      
      # Cache persistente
      volumeMounts:
      - name: docker-cache
        mountPath: /var/lib/docker
      - name: buildkit-cache
        mountPath: /tmp/buildkit-cache
        
      volumes:
      - name: docker-cache
        persistentVolumeClaim:
          claimName: docker-cache-pvc
      - name: buildkit-cache
        hostPath:
          path: /tmp/buildkit-cache
          type: DirectoryOrCreate
      
      # Otimizações BuildKit
      dockerEnv:
      - name: DOCKER_BUILDKIT
        value: "1"
      - name: BUILDKIT_PROGRESS
        value: "plain"
      - name: BUILDKIT_CACHE_MOUNT_NAMESPACE
        value: "runner-cache"
      
      labels:
      - "dind-optimized"
      - "cache-enabled"
```

---

## 📈 **Métricas de Sucesso**

### **KPIs para Monitorar**
- ⏱️ **Build Time**: Redução de 40-60% vs DinD padrão
- 💾 **CPU Usage**: Redução de 30-50% vs DinD padrão  
- 🧠 **Memory Usage**: Redução de 20-40% vs DinD padrão
- 🚀 **Cache Hit Rate**: >80% para builds recorrentes
- 📦 **Registry Pull Time**: Redução de 50-70% com mirror

### **Comandos para Monitoramento**
```bash
# CPU e Memória dos runners
kubectl top pods -n actions-runner-system --sort-by=cpu

# Logs de performance do dockerd
kubectl logs -n actions-runner-system -l runner-deployment-name=arc-runner-dind-optimized -c dockerd

# Métricas de cache
kubectl exec -n actions-runner-system <pod-name> -- du -sh /var/lib/docker
```

---

## 🎯 **Próximos Passos**

1. ✅ **Implementar**: Containerd bind mount (cenário real)
2. 📝 **Documentar**: Resultados de performance
3. 🧪 **Testar**: Workloads representativos do cliente
4. 📊 **Comparar**: Métricas vs solução atual
5. 🚀 **Deploy**: Solução otimizada em produção
