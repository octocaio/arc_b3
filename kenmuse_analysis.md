#### 1. Práticas para GitHub ARC
- Ken Muse explicou que grande parte das práticas recomendadas para ARC são, na verdade, melhores práticas de Kubernetes.
- O ARC é simples e foca em escalabilidade, mas depende de um ambiente Kubernetes bem configurado e administrado.
- É essencial que a equipe do cliente tenha um especialista certificado em Kubernetes, capaz de ajustar e solucionar problemas no cluster conforme o perfil de workload.
- Recomenda-se iniciar em um ambiente Kubernetes "limpo", instalando apenas o ARC, para facilitar o monitoramento e tuning.
- É importante seguir atentamente a documentação do ARC, especialmente sobre processos de upgrade e requisitos de self-hosted runners.

#### 2. Docker in Docker (DinD) e performance
- Caiocqueiroz levantou a possibilidade de mitigar lentidão do DinD usando Docker Bind Mount, permitindo ações no runner utilizarem o engine Docker do Node.
- Ken Muse alertou sobre riscos de segurança: montar o Docker como serviço central (daemonset) permite que qualquer processo no node acesse o Docker com privilégios elevados.
- Compartilhar o mesmo runtime do Docker pode causar conflitos entre jobs e containers, dificultando o gerenciamento.
- O uso de DinD, apesar de mais lento, oferece melhor isolamento e segurança.

#### 3. Performance do DinD e alternativas
- O principal gargalo de performance não é o DinD em si, mas sim o ambiente da VM ou o que está sendo executado dentro do DinD.
- O DinD não aproveita o cache de imagens do Kubernetes; cada instância constrói seu próprio cache, e isso não pode ser contornado com volume mounts.
- Uma alternativa sugerida é usar "init containers" para pré-carregar imagens específicas no DinD, o que pode melhorar a performance se todos os jobs forem usar a mesma imagem. Caso contrário, pode não trazer benefícios.

#### 4. Recomendações Gerais
- Foco em boas práticas de Kubernetes para o ARC.
- Cuidado com alternativas ao DinD que tragam riscos de segurança.
- Monitorar e ajustar o cluster conforme o perfil dos workloads.
- Seguir a documentação oficial do ARC e dos runners.
