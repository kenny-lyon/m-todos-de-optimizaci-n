# ============================================================================
# EJERCICIO 4: M/M/1 POBLACIÓN FINITA - SISTEMA DE COMPUTADORAS
# ============================================================================

using Statistics, Printf

# Función para sistema M/M/1 con población finita
function finite_population_analysis(N, lambda, mu, s=1)
    # Calcular probabilidades de estado estacionario
    rho = lambda / mu
    
    # Calcular P0 para población finita usando fórmula binomial
    sum_terms = 0.0
    for n in 0:N
        sum_terms += binomial(N, n) * rho^n
    end
    P0 = 1 / sum_terms
    
    # Probabilidades para cada estado
    probabilities = zeros(N+1)
    for n in 0:N
        probabilities[n+1] = binomial(N, n) * rho^n * P0
    end
    
    # Medidas de rendimiento
    L = sum(n * probabilities[n+1] for n in 0:N)
    Lq = sum(max(0, n-s) * probabilities[n+1] for n in 0:N)
    
    # Tasa efectiva de llegadas (depende del estado del sistema)
    lambda_eff = sum((N-n) * lambda * probabilities[n+1] for n in 0:N)
    
    # Tiempos de espera
    W = L / lambda_eff
    Wq = Lq / lambda_eff
    
    # Utilización del servidor
    server_utilization = 1 - P0
    
    # Número promedio de unidades operativas
    operating_units = N - L
    
    return (
        N = N,
        lambda = lambda,
        mu = mu,
        rho = rho,
        P0 = P0,
        probabilities = probabilities,
        L = L,
        Lq = Lq,
        W = W,
        Wq = Wq,
        lambda_eff = lambda_eff,
        server_utilization = server_utilization,
        operating_units = operating_units,
        availability = operating_units / N
    )
end

# Función para mostrar distribución de probabilidades
function mostrar_distribucion_probabilidades(result)
    println("\n=== DISTRIBUCIÓN DE PROBABILIDADES ===")
    println("Estado | Probabilidad |  %   | Visualización")
    println("-------|--------------|------|---------------")
    
    for n in 0:result.N
        prob = result.probabilities[n+1]
        pct = prob * 100
        bars = "█" ^ Int(round(prob * 50))  # Escala para visualización
        
        @printf("%6d | %12.6f | %4.2f | %s\n", n, prob, pct, bars)
    end
    
    println("\nLeyenda: Estado = número de computadoras en el sistema de reparación")
end

# Función principal del ejercicio 4
function ejercicio_4()
    println("=" ^ 60)
    println("EJERCICIO 4: SISTEMA DE COMPUTADORAS (M/M/1/∞/5)")
    println("=" ^ 60)
    
    # Parámetros del problema
    N = 5  # computadoras
    lambda = 60/85  # fallas por hora por máquina (85 min entre fallas)
    mu = 4  # reparaciones por hora (15 min por reparación)

    println("=== PARÁMETROS DEL SISTEMA ===")
    @printf("N = %d computadoras\n", N)
    @printf("λ = %.4f fallas/hora por computadora\n", lambda)
    @printf("μ = %.1f reparaciones/hora\n", mu)
    @printf("Tiempo promedio entre fallas: %.1f minutos\n", 85)
    @printf("Tiempo promedio de reparación: %.1f minutos\n", 15)
    @printf("ρ = λ/μ = %.4f\n", lambda/mu)

    # Realizar análisis
    results = finite_population_analysis(N, lambda, mu)

    println("\n=== RESPUESTAS A LAS PREGUNTAS ===")
    @printf("a) Computadoras promedio en espera de ajuste: %.4f\n", results.Lq)
    @printf("b) Computadoras promedio que no funcionan: %.4f\n", results.L)
    @printf("c) Probabilidad de sistema vacío: %.4f = %.2f%%\n", results.P0, results.P0*100)
    @printf("d) Tiempo promedio en cola: %.4f horas = %.2f minutos\n", 
            results.Wq, results.Wq*60)
    @printf("e) Tiempo promedio en sistema: %.4f horas = %.2f minutos\n", 
            results.W, results.W*60)

    println("\n=== MÉTRICAS ADICIONALES DEL SISTEMA ===")
    @printf("Utilización del técnico: %.3f = %.1f%%\n", 
            results.server_utilization, results.server_utilization*100)
    @printf("Tasa efectiva de llegadas: %.4f máquinas/hora\n", results.lambda_eff)
    @printf("Computadoras operativas promedio: %.4f\n", results.operating_units)
    @printf("Disponibilidad del sistema: %.2f%%\n", results.availability*100)
    @printf("Tiempo ocioso del técnico: %.1f%% del tiempo\n", (1-results.server_utilization)*100)

    # Mostrar distribución de probabilidades
    mostrar_distribucion_probabilidades(results)

    # Análisis de rendimiento
    println("\n=== ANÁLISIS DE RENDIMIENTO ===")
    @printf("Throughput del sistema: %.4f reparaciones/hora\n", results.lambda_eff)
    @printf("Tiempo de ciclo promedio: %.2f horas\n", results.W)
    @printf("Productividad del sistema: %.1f%% de capacidad teórica\n", 
            results.availability*100)
    
    # Análisis económico básico
    println("\n=== IMPACTO OPERACIONAL ===")
    perdida_productividad = results.L / N * 100
    @printf("Pérdida de productividad: %.2f%% por máquinas no operativas\n", perdida_productividad)
    @printf("En un turno de 8 horas:\n")
    @printf("  - Horas-máquina perdidas: %.2f horas\n", results.L * 8)
    @printf("  - Horas técnico ocupado: %.2f horas\n", results.server_utilization * 8)
    @printf("  - Horas técnico ocioso: %.2f horas\n", (1-results.server_utilization) * 8)
    
    return results
end

# Función para análisis de sensibilidad
function analisis_sensibilidad_poblacion_finita(N, mu)
    println("\n=== ANÁLISIS DE SENSIBILIDAD ===")
    println("Impacto de la tasa de fallas en el sistema:")
    
    # Diferentes escenarios de confiabilidad (tiempo entre fallas)
    tiempo_entre_fallas = [60, 70, 85, 100, 120, 150]  # minutos
    
    println("Tiempo entre | λ (fallas/h) | Disponibilidad | L (avg no-op) | Utilizac. Técnico")
    println("fallas (min) | por máquina  |    sistema     |   máquinas    |      (%)        ")
    println("-------------|--------------|----------------|---------------|------------------")
    
    for tiempo in tiempo_entre_fallas
        lambda = 60 / tiempo
        result = finite_population_analysis(N, lambda, mu)
        
        @printf("%12d | %12.4f | %13.1f%% | %13.3f | %15.1f%%\n",
               tiempo, lambda, result.availability*100, result.L, result.server_utilization*100)
    end
    
    println("\n📊 Conclusión: Mayor confiabilidad (↑tiempo entre fallas) mejora significativamente la disponibilidad")
end

# Función para comparar diferentes números de técnicos
function comparar_tecnicos(N, lambda)
    println("\n=== COMPARACIÓN: ¿VALE LA PENA UN SEGUNDO TÉCNICO? ===")
    mu = 4  # reparaciones por hora por técnico
    
    # Un técnico
    result_1 = finite_population_analysis(N, lambda, mu, 1)
    
    # Dos técnicos (aproximación: duplicamos μ efectivo, pero es más complejo)
    # Para simplicidad, asumimos que 2 técnicos = μ_total = 2*μ
    result_2 = finite_population_analysis(N, lambda, 2*mu, 1)
    
    println("Métrica                    | 1 Técnico | 2 Técnicos | Mejora")
    println("---------------------------|-----------|------------|--------")
    @printf("Disponibilidad sistema     | %8.1f%% | %9.1f%% | %+5.1f%%\n",
           result_1.availability*100, result_2.availability*100, 
           (result_2.availability - result_1.availability)*100)
    @printf("Máquinas no-operativas     | %9.3f | %10.3f | %+6.1f%%\n",
           result_1.L, result_2.L, (result_2.L - result_1.L)/result_1.L*100)
    @printf("Tiempo promedio reparación | %8.1f min | %8.1f min | %+6.1f%%\n",
           result_1.W*60, result_2.W*60, (result_2.W - result_1.W)/result_1.W*100)
    @printf("Utilización técnico(s)     | %8.1f%% | %9.1f%% | %+6.1f%%\n",
           result_1.server_utilization*100, result_2.server_utilization*100,
           (result_2.server_utilization - result_1.server_utilization)*100)
    
    # Análisis económico simple
    costo_segundo_tecnico = 50000  # $/año ejemplo
    valor_hora_maquina = 100       # $/hora ejemplo
    horas_año = 8760
    
    ahorro_anual = (result_1.L - result_2.L) * horas_año * valor_hora_maquina
    
    println("\n=== ANÁLISIS ECONÓMICO APROXIMADO ===")
    @printf("Costo anual segundo técnico: \$%,.0f\n", costo_segundo_tecnico)
    @printf("Ahorro por mayor disponibilidad: \$%,.0f/año\n", ahorro_anual)
    
    if ahorro_anual > costo_segundo_tecnico
        @printf("✓ RECOMENDACIÓN: Contratar segundo técnico (ROI: %.1f%%)\n", 
               (ahorro_anual/costo_segundo_tecnico - 1)*100)
    else
        @printf("✗ RECOMENDACIÓN: Mantener un técnico (pérdida: \$%,.0f/año)\n", 
               costo_segundo_tecnico - ahorro_anual)
    end
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
resultado = ejercicio_4()

# Ejecutar análisis de sensibilidad
analisis_sensibilidad_poblacion_finita(5, 4)

# Comparar escenarios de técnicos
comparar_tecnicos(5, 60/85)

println("\n" * "=" ^ 60)
println("ANÁLISIS POBLACIÓN FINITA COMPLETADO")
println("=" ^ 60)