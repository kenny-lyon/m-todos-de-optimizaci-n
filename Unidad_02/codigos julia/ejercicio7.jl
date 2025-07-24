# ============================================================================
# EJERCICIO 7: M/M/s COLA FINITA - CITY CAB (MODELO DE PÉRDIDAS)
# ============================================================================

using Statistics, Printf

# Función para modelo M/M/s/s (Erlang B - modelo de pérdidas)
function erlang_b_analysis(lambda, mu, s)
    rho = lambda / mu  # Tráfico ofrecido (en Erlangs)
    
    # Calcular probabilidades usando fórmula de Erlang B
    # P_n = (rho^n / n!) / sum(rho^k / k! for k=0 to s)
    
    # Calcular denominador (función de normalización)
    denominator = sum(rho^k / factorial(k) for k in 0:s)
    
    # Probabilidades de estado
    probabilities = zeros(s+1)
    for n in 0:s
        probabilities[n+1] = (rho^n / factorial(n)) / denominator
    end
    
    # Métricas del sistema
    P_blocking = probabilities[s+1]  # Probabilidad de bloqueo (sistema lleno)
    lambda_effective = lambda * (1 - P_blocking)  # Tasa efectiva de llegadas
    utilization_per_server = lambda_effective / (s * mu)  # Utilización por servidor
    L = lambda_effective / mu  # Número promedio en sistema
    W = 1 / mu  # Tiempo promedio de servicio (no hay cola)
    
    return (
        s = s,
        lambda = lambda,
        mu = mu,
        rho = rho,
        probabilities = probabilities,
        P_blocking = P_blocking,
        lambda_effective = lambda_effective,
        utilization_per_server = utilization_per_server,
        L = L,
        W = W
    )
end

# Función para mostrar distribución de probabilidades detallada
function mostrar_distribucion_erlang_b(result)
    println("\n=== DISTRIBUCIÓN DE PROBABILIDADES (ERLANG B) ===")
    println("Despacha. | ρⁿ/n!   | Prob.Estado | Prob.% | Prob.Acum% | Visual")
    println("Ocupados  |         |             |        |            |       ")
    println("----------|---------|-------------|--------|------------|--------")
    
    acum = 0.0
    for n in 0:result.s
        rho_factorial = result.rho^n / factorial(n)
        prob = result.probabilities[n+1]
        pct = prob * 100
        acum += prob
        visual = "█" ^ Int(round(prob * 40))  # Visualización
        
        @printf("%9d | %7.5f | %11.6f | %6.2f | %10.2f | %s\n",
               n, rho_factorial, prob, pct, acum*100, visual)
    end
    
    println("\nInterpretación:")
    println("  - Estado n: n despachadores ocupados simultáneamente")
    println("  - P($result.s) = Probabilidad de bloqueo (señal ocupado)")
    println("  - No hay cola: las llamadas bloqueadas se pierden")
end

# Función principal del ejercicio 7
function ejercicio_7()
    println("=" ^ 60)
    println("EJERCICIO 7: CITY CAB (MODELO M/M/s/s - ERLANG B)")
    println("=" ^ 60)
    
    lambda, mu = 40, 30  # llamadas/hora, llamadas/hora por despachador
    
    println("=== PARÁMETROS DEL SISTEMA ===")
    println("λ = $lambda llamadas/hora")
    println("μ = $mu llamadas/hora por despachador")
    @printf("Tráfico ofrecido = %.3f Erlangs\n", lambda/mu)
    println("Modelo: M/M/s/s (sin cola, llamadas bloqueadas se pierden)")
    
    println("\n=== PARTE A: PROBABILIDADES DE SEÑAL OCUPADO ===")
    println("Despachadores | P(Bloqueo) | Llamadas Perdidas/h | Utilización/Desp")
    println("--------------|------------|---------------------|------------------")
    
    results = []
    
    for s in 2:4
        result = erlang_b_analysis(lambda, mu, s)
        lost_calls = lambda * result.P_blocking
        
        @printf("%13d | %9.1f%% | %18.2f | %15.1f%%\n", 
               s, result.P_blocking*100, lost_calls, 
               result.utilization_per_server*100)
        
        push!(results, result)
    end
    
    # Análisis detallado para cada configuración
    for result in results
        println("\n" * "="^50)
        println("ANÁLISIS DETALLADO: $(result.s) DESPACHADORES")
        println("="^50)
        
        @printf("Tráfico ofrecido: %.3f Erlangs\n", result.rho)
        @printf("Probabilidad de bloqueo: %.4f = %.2f%%\n", 
               result.P_blocking, result.P_blocking*100)
        @printf("Llamadas efectivamente atendidas: %.2f/hora\n", result.lambda_effective)
        @printf("Llamadas perdidas: %.2f/hora\n", lambda * result.P_blocking)
        @printf("Utilización por despachador: %.1f%%\n", 
               result.utilization_per_server*100)
        @printf("Despachadores ocupados promedio: %.3f\n", result.L)
        
        # Mostrar distribución detallada
        mostrar_distribucion_erlang_b(result)
    end
    
    return results
end

# Función para análisis de nivel de servicio
function analisis_nivel_servicio(results)
    println("\n" * "=" ^ 60)
    println("PARTE B: ANÁLISIS DE NIVEL DE SERVICIO")
    println("=" ^ 60)
    
    println("Requisito: No más del 12% de señales de ocupado")
    
    target_blocking = 0.12
    
    println("\nEvaluación del cumplimiento:")
    println("Despachadores | P(Bloqueo) | Cumple Requisito | Margen")
    println("--------------|------------|------------------|--------")
    
    compliant_options = []
    
    for result in results
        meets_target = result.P_blocking <= target_blocking
        status = meets_target ? "✓ SÍ" : "✗ NO"
        margen = (target_blocking - result.P_blocking) * 100
        
        @printf("%13d | %9.1f%% | %16s | %+6.1f%%\n", 
               result.s, result.P_blocking*100, status, margen)
        
        if meets_target
            push!(compliant_options, result)
        end
    end
    
    # Recomendación
    println("\n=== RECOMENDACIÓN ===")
    if !isempty(compliant_options)
        optimal = minimum(compliant_options, by = r -> r.s)
        
        println("✓ CONFIGURACIÓN RECOMENDADA:")
        @printf("  Número de despachadores: %d\n", optimal.s)
        @printf("  Probabilidad de bloqueo: %.1f%% (< %.1f%% requerido)\n", 
               optimal.P_blocking*100, target_blocking*100)
        @printf("  Llamadas perdidas: %.2f por hora\n", 
               optimal.lambda * optimal.P_blocking)
        @printf("  Nivel de servicio: %.1f%%\n", (1-optimal.P_blocking)*100)
        
        # Análisis económico básico
        println("\n=== ANÁLISIS ECONÓMICO ===")
        ingreso_por_llamada = 15  # $ por servicio ejemplo
        costo_despachador_hora = 25  # $ por hora ejemplo
        
        ingresos_hora = optimal.lambda_effective * ingreso_por_llamada
        costos_hora = optimal.s * costo_despachador_hora
        perdida_ingresos = optimal.lambda * optimal.P_blocking * ingreso_por_llamada
        
        @printf("Ingresos por hora: \$%.2f\n", ingresos_hora)
        @printf("Costos por hora: \$%.2f\n", costos_hora)
        @printf("Pérdida por bloqueos: \$%.2f/hora\n", perdida_ingresos)
        @printf("Utilidad neta: \$%.2f/hora\n", ingresos_hora - costos_hora)
        
    else
        println("✗ NINGUNA CONFIGURACIÓN CUMPLE EL REQUISITO")
        println("  Se necesitan más despachadores o reducir la demanda")
    end
end

# Función para análisis de sensibilidad del tráfico
function analisis_sensibilidad_trafico(mu, target_servers)
    println("\n=== ANÁLISIS DE SENSIBILIDAD: VARIACIÓN DE DEMANDA ===")
    println("¿Cómo afectan los cambios en la demanda al nivel de servicio?")
    
    # Diferentes niveles de demanda
    demandas = [30, 35, 40, 45, 50, 55]  # llamadas/hora
    
    println("Demanda | Tráfico | P(Bloqueo) | Llamadas | Nivel")
    println("(ll/h)  | (Erlangs)| con $target_servers desp | Perdidas/h| Servicio")
    println("--------|---------|------------|----------|----------")
    
    for lambda in demandas
        result = erlang_b_analysis(lambda, mu, target_servers)
        perdidas = lambda * result.P_blocking
        nivel_servicio = (1 - result.P_blocking) * 100
        
        @printf("%7d | %8.2f | %9.1f%% | %8.2f | %7.1f%%\n",
               lambda, lambda/mu, result.P_blocking*100, perdidas, nivel_servicio)
    end
    
    println("\n📊 Observación: El nivel de servicio es muy sensible a cambios en la demanda")
end

# Función para comparar con sistema de colas
function comparar_con_sistema_colas(lambda, mu, s)
    println("\n=== COMPARACIÓN: MODELO DE PÉRDIDAS vs SISTEMA CON COLA ===")
    println("¿Qué pasaría si las llamadas esperaran en lugar de perderse?")
    
    # Sistema actual (pérdidas)
    perdidas = erlang_b_analysis(lambda, mu, s)
    
    println("Métrica                        | Modelo Pérdidas | Sistema con Cola")
    println("-------------------------------|-----------------|------------------")
    
    # Para el sistema con cola, usamos aproximaciones simples
    rho_sistema = lambda / (s * mu)
    if rho_sistema < 1
        @printf("Estabilidad del sistema        | %15s | %16s\n", "N/A", "Estable")
        @printf("Utilización por servidor       | %14.1f%% | %15.1f%%\n", 
               perdidas.utilization_per_server*100, rho_sistema*100)
        @printf("Llamadas atendidas por hora    | %15.1f | %16.1f\n", 
               perdidas.lambda_effective, lambda)
        @printf("Llamadas perdidas por hora     | %15.1f | %16.1f\n", 
               lambda * perdidas.P_blocking, 0.0)
        @printf("Tiempo promedio de servicio    | %14.1f min | %15.1f min\n", 
               perdidas.W*60, perdidas.W*60)
        
        println("\n💡 Insight: Sistema con cola atiende todas las llamadas pero")
        println("   genera tiempos de espera que pueden ser inaceptables")
    else
        println("Sistema con cola sería INESTABLE con esta configuración")
    end
end

# Función para análisis de capacidad
function analisis_capacidad_detallado(results)
    println("\n=== ANÁLISIS DE CAPACIDAD DETALLADO ===")
    
    println("Configuración | Capacidad | Demanda | Utilización | Eficiencia")
    println("              | Teórica   | Efectiva| Sistema     | Operacional")
    println("--------------|-----------|---------|-------------|-------------")
    
    for result in results
        capacidad_teorica = result.s * result.mu
        demanda_efectiva = result.lambda_effective
        utilizacion_sistema = demanda_efectiva / capacidad_teorica
        eficiencia = demanda_efectiva / result.lambda
        
        @printf("%2d despachad. | %9.0f | %7.1f | %10.1f%% | %10.1f%%\n",
               result.s, capacidad_teorica, demanda_efectiva, 
               utilizacion_sistema*100, eficiencia*100)
    end
    
    println("\nDefiniciones:")
    println("  • Capacidad Teórica: s × μ (máximo teórico)")
    println("  • Demanda Efectiva: llamadas realmente atendidas")
    println("  • Utilización Sistema: % de capacidad teórica usada")
    println("  • Eficiencia Operacional: % de demanda total atendida")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
results = ejercicio_7()

# Ejecutar análisis de nivel de servicio
analisis_nivel_servicio(results)

# Ejecutar análisis de sensibilidad
analisis_sensibilidad_trafico(30, 3)

# Comparar con sistema de colas
comparar_con_sistema_colas(40, 30, 3)

# Análisis de capacidad detallado
analisis_capacidad_detallado(results)

println("\n" * "=" ^ 60)
println("ANÁLISIS CITY CAB (ERLANG B) COMPLETADO")
println("=" ^ 60)

# Función adicional para recomendaciones operacionales
function recomendaciones_operacionales()
    println("\n=== RECOMENDACIONES OPERACIONALES ===")
    
    println("🎯 DECISIÓN PRINCIPAL:")
    println("   ✓ Operar con 3 despachadores para cumplir nivel de servicio")
    println("   ✓ Probabilidad de bloqueo: ~11% (dentro del límite 12%)")
    
    println("\n📊 MONITOREO RECOMENDADO:")
    println("   • Medir % real de llamadas con señal ocupado")
    println("   • Monitorear patrones horarios de demanda")
    println("   • Ajustar staffing según variaciones estacionales")
    println("   • Considerar sistema de cola para horas pico")
    
    println("\n⚠️  CONSIDERACIONES CRÍTICAS:")
    println("   • El modelo asume llegadas Poisson y servicios exponenciales")
    println("   • Validar supuestos con datos históricos reales")
    println("   • Evaluar impacto de bloqueos en satisfacción del cliente")
    println("   • Considerar alternativas tecnológicas (callback, cola virtual)")
    
    println("\n🚀 OPORTUNIDADES DE MEJORA:")
    println("   • Implementar sistema de callback automático")
    println("   • Optimizar tiempos de despacho (reducir μ)")
    println("   • Análisis predictivo para staffing dinámico")
    println("   • Integración con app móvil para reducir llamadas")
end

# Ejecutar recomendaciones
recomendaciones_operacionales()