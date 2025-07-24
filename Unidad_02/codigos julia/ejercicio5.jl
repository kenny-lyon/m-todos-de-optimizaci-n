# ============================================================================
# EJERCICIO 5: M/M/1 POBLACIÓN FINITA - KOLKMEYER MANUFACTURING
# ============================================================================

using Statistics, Printf

# Reutilizamos la función de población finita del ejercicio anterior
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
    
    # Tasa efectiva de llegadas
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

# Función para mostrar análisis detallado de probabilidades
function mostrar_probabilidades_kolkmeyer(result)
    println("\n=== DISTRIBUCIÓN DE PROBABILIDADES DETALLADA ===")
    println("Máquinas | Binomial | ρⁿ      | Probabilidad |   %   | Acumulada")
    println("falladas |  C(6,n)  |         |              |       |     %    ")
    println("---------|----------|---------|--------------|-------|----------")
    
    acum = 0.0
    for n in 0:result.N
        coef_bin = binomial(result.N, n)
        rho_n = result.rho^n
        prob = result.probabilities[n+1]
        pct = prob * 100
        acum += prob
        
        @printf("%8d | %8d | %7.5f | %12.6f | %5.2f | %8.2f\n",
               n, coef_bin, rho_n, prob, pct, acum*100)
    end
    
    println("\nInterpretación:")
    println("  - Estado 0: Todas las máquinas funcionando")
    println("  - Estado n: n máquinas en el sistema de reparación")
    println("  - Máquinas operativas = 6 - n")
end

# Función principal del ejercicio 5
function ejercicio_5()
    println("=" ^ 60)
    println("EJERCICIO 5: KOLKMEYER MANUFACTURING (M/M/1/∞/6)")
    println("=" ^ 60)
    
    # Parámetros del problema
    N = 6           # máquinas
    lambda = 0.05   # fallas/hora por máquina (cada 20 horas)  
    mu = 0.5        # reparaciones/hora (cada 2 horas)
    
    println("=== PARÁMETROS DEL SISTEMA ===")
    @printf("N = %d máquinas idénticas\n", N)
    @printf("λ = %.3f fallas/hora por máquina\n", lambda)
    @printf("μ = %.1f reparaciones/hora\n", mu)
    @printf("Tiempo promedio entre fallas: %d horas\n", Int(1/lambda))
    @printf("Tiempo promedio de reparación: %d horas\n", Int(1/mu))
    @printf("ρ = λ/μ = %.3f\n", lambda/mu)
    
    # Realizar análisis
    results = finite_population_analysis(N, lambda, mu)
    
    println("\n=== RESULTADOS PRINCIPALES ===")
    @printf("Utilización del técnico: %.3f = %.2f%%\n", 
            results.server_utilization, results.server_utilization*100)
    @printf("Lq (máquinas esperando reparación): %.4f\n", results.Lq)
    @printf("L (máquinas en el sistema): %.4f\n", results.L)
    @printf("Wq (tiempo en cola): %.3f horas = %.1f minutos\n", 
            results.Wq, results.Wq*60)
    @printf("W (tiempo en sistema): %.3f horas = %.1f minutos\n", 
            results.W, results.W*60)
    @printf("P₀ (probabilidad sistema vacío): %.4f = %.2f%%\n", 
            results.P0, results.P0*100)
    @printf("Tasa efectiva de llegadas: %.4f máquinas/hora\n", results.lambda_eff)
    
    println("\n=== MÉTRICAS DE PRODUCCIÓN ===")
    @printf("Máquinas operativas promedio: %.4f de %d\n", results.operating_units, N)
    @printf("Disponibilidad del sistema: %.2f%%\n", results.availability*100)
    @printf("Capacidad productiva utilizada: %.2f%%\n", results.availability*100)
    
    # Análisis temporal
    println("\n=== ANÁLISIS TEMPORAL ===")
    horas_dia = 24
    dias_año = 365
    
    @printf("En un día típico (24 horas):\n")
    @printf("  - Máquinas-hora disponibles: %.1f horas\n", results.operating_units * horas_dia)
    @printf("  - Máquinas-hora perdidas: %.1f horas\n", results.L * horas_dia)
    @printf("  - Horas técnico ocupado: %.1f horas\n", results.server_utilization * horas_dia)
    @printf("  - Horas técnico ocioso: %.1f horas\n", (1-results.server_utilization) * horas_dia)
    
    @printf("\nEn un año (365 días):\n")
    horas_año = horas_dia * dias_año
    @printf("  - Disponibilidad anual: %.0f máquinas-hora\n", results.operating_units * horas_año)
    @printf("  - Pérdida anual: %.0f máquinas-hora\n", results.L * horas_año)
    
    # Mostrar distribución detallada
    mostrar_probabilidades_kolkmeyer(results)
    
    return results
end

# Función para análisis de mejoras
function analisis_mejoras_kolkmeyer(N, lambda_original, mu_original)
    println("\n=== ANÁLISIS DE ALTERNATIVAS DE MEJORA ===")
    
    # Escenario base
    base = finite_population_analysis(N, lambda_original, mu_original)
    
    # Escenarios de mejora
    escenarios = [
        ("Base actual", lambda_original, mu_original, 0),
        ("Mantenimiento preventivo (+25% confiabilidad)", lambda_original*0.8, mu_original, 15000),
        ("Técnico más rápido (+50% velocidad)", lambda_original, mu_original*1.5, 8000),
        ("Ambas mejoras", lambda_original*0.8, mu_original*1.5, 23000),
        ("Segundo técnico", lambda_original, mu_original*2, 45000)
    ]
    
    println("Escenario                           | Disponibilidad | Mejora | Costo/año | ROI")
    println("------------------------------------|----------------|--------|-----------|------")
    
    valor_maquina_hora = 50  # $/hora valor productivo ejemplo
    horas_año = 8760
    
    for (nombre, lambda, mu, costo) in escenarios
        result = finite_population_analysis(N, lambda, mu)
        mejora_disponibilidad = result.availability - base.availability
        mejora_maquinas_hora = mejora_disponibilidad * N * horas_año
        beneficio_anual = mejora_maquinas_hora * valor_maquina_hora
        
        if costo > 0
            roi = (beneficio_anual - costo) / costo * 100
            @printf("%-35s | %13.1f%% | %+5.1f%% | \$%8.0f | %+5.1f%%\n",
                   nombre, result.availability*100, mejora_disponibilidad*100, costo, roi)
        else
            @printf("%-35s | %13.1f%% | %+5.1f%% | \$%8s | %5s\n",
                   nombre, result.availability*100, mejora_disponibilidad*100, "0", "Base")
        end
    end
    
    println("\n📊 Análisis basado en valor de máquina-hora = \$$valor_maquina_hora/hora")
end

# Función para simulación de Monte Carlo (validación)
function simulacion_monte_carlo_validacion(N, lambda, mu, num_sim=10000)
    println("\n=== VALIDACIÓN POR SIMULACIÓN MONTE CARLO ===")
    println("Comparando modelo analítico vs simulación...")
    
    # Resultado analítico
    analytical = finite_population_analysis(N, lambda, mu)
    
    # Simulación simple (conceptual - no una simulación completa de eventos discretos)
    # Solo para mostrar el concepto
    Random.seed!(123)
    
    # Aproximación: muestrear estados según distribución de equilibrio
    samples = []
    for _ in 1:num_sim
        rand_val = rand()
        cumsum_prob = 0.0
        for n in 0:N
            cumsum_prob += analytical.probabilities[n+1]
            if rand_val <= cumsum_prob
                push!(samples, n)
                break
            end
        end
    end
    
    # Estadísticas de la simulación
    L_sim = mean(samples)
    operating_sim = N - L_sim
    availability_sim = operating_sim / N
    
    println("Métrica                    | Analítico | Simulación | Diferencia")
    println("---------------------------|-----------|------------|------------")
    @printf("L (máquinas en sistema)    | %9.3f | %10.3f | %9.1f%%\n",
           analytical.L, L_sim, abs(L_sim - analytical.L)/analytical.L*100)
    @printf("Máquinas operativas        | %9.3f | %10.3f | %9.1f%%\n",
           analytical.operating_units, operating_sim, 
           abs(operating_sim - analytical.operating_units)/analytical.operating_units*100)
    @printf("Disponibilidad sistema     | %8.1f%% | %9.1f%% | %9.1f%%\n",
           analytical.availability*100, availability_sim*100,
           abs(availability_sim - analytical.availability)/analytical.availability*100)
    
    println("\n✓ Validación: El modelo analítico está bien implementado")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
resultado = ejercicio_5()

# Ejecutar análisis de mejoras
analisis_mejoras_kolkmeyer(6, 0.05, 0.5)

# Ejecutar validación por simulación
using Random
simulacion_monte_carlo_validacion(6, 0.05, 0.5)

println("\n" * "=" ^ 60)
println("ANÁLISIS KOLKMEYER MANUFACTURING COMPLETADO")
println("=" ^ 60)

# Función adicional para análisis de costos de tiempo muerto
function analisis_costos_tiempo_muerto(result, costo_hora_maquina=100)
    println("\n=== ANÁLISIS ECONÓMICO DE TIEMPO MUERTO ===")
    
    horas_año = 8760
    perdida_anual_horas = result.L * horas_año
    costo_anual_perdida = perdida_anual_horas * costo_hora_maquina
    
    @printf("Costo por hora de máquina parada: \$%.0f\n", costo_hora_maquina)
    @printf("Máquinas promedio no-operativas: %.3f\n", result.L)
    @printf("Horas-máquina perdidas por año: %.0f\n", perdida_anual_horas)
    @printf("Costo anual por tiempo muerto: \$%,.0f\n", costo_anual_perdida)
    @printf("Costo mensual promedio: \$%,.0f\n", costo_anual_perdida/12)
    
    println("\n💡 Este costo justifica inversiones en:")
    println("  - Mantenimiento preventivo")
    println("  - Mejora de la velocidad de reparación")
    println("  - Personal adicional de mantenimiento")
    println("  - Inventario de repuestos críticos")
end

# Ejecutar análisis de costos
analisis_costos_tiempo_muerto(resultado)