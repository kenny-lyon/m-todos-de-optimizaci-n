# ============================================================================
# EJERCICIO 6: ANÁLISIS DE COSTOS - TIENDA DE ROPA
# ============================================================================

using Statistics, Printf

# Reutilizamos las funciones M/M/s del ejercicio 3
function calculate_P0(lambda, mu, s)
    rho = lambda / mu
    
    # Suma de los primeros s términos
    sum1 = sum((rho^n) / factorial(n) for n in 0:(s-1))
    
    # Término para n ≥ s
    system_rho = lambda / (s * mu)
    if system_rho >= 1
        return NaN  # Sistema inestable
    end
    
    term2 = (rho^s) / (factorial(s) * (1 - system_rho))
    
    return 1 / (sum1 + term2)
end

function mms_analysis(lambda, mu, s)
    system_rho = lambda / (s * mu)
    
    if system_rho >= 1
        return nothing  # Sistema inestable
    end
    
    P0 = calculate_P0(lambda, mu, s)
    if isnan(P0)
        return nothing
    end
    
    # Lq usando fórmula de Erlang C
    rho = lambda / mu
    Lq = ((rho^s) * system_rho) / (factorial(s) * (1 - system_rho)^2) * P0
    
    # Otras medidas
    Wq = Lq / lambda
    W = Wq + 1/mu
    L = lambda * W
    
    return (
        s = s,
        rho = system_rho,
        P0 = P0,
        Lq = Lq,
        L = L,
        Wq = Wq,
        W = W
    )
end

# Función para calcular costos de operación
function calcular_costos_retail(lambda, mu, s, server_cost, waiting_cost)
    metrics = mms_analysis(lambda, mu, s)
    if metrics === nothing
        return (
            servers = s,
            cost_servers = Inf,
            cost_waiting = Inf,
            total_cost = Inf,
            metrics = nothing,
            feasible = false
        )
    end
    
    cost_servers = s * server_cost
    cost_waiting = lambda * metrics.Wq * waiting_cost
    total = cost_servers + cost_waiting
    
    return (
        servers = s,
        cost_servers = cost_servers,
        cost_waiting = cost_waiting,
        total_cost = total,
        metrics = metrics,
        feasible = true
    )
end

# Función principal del ejercicio 6
function ejercicio_6()
    println("=" ^ 60)
    println("EJERCICIO 6: ANÁLISIS DE COSTOS - TIENDA DE ROPA")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda = 10    # clientes/hora
    mu = 5         # clientes/hora por cajera
    server_cost = 30    # $/hora por cajera
    waiting_cost = 100  # $/hora por cliente en espera
    
    println("=== PARÁMETROS DEL SISTEMA ===")
    println("λ = $lambda clientes/hora")
    println("μ = $mu clientes/hora por cajera")
    println("Costo cajera: \$$server_cost/hora")
    println("Costo espera: \$$waiting_cost/hora por cliente")
    println("(Equivale a pérdidas por ventas no realizadas)")
    
    # Análisis específico para 3 cajeras (parte a)
    println("\n=== PARTE A: ANÁLISIS CON 3 CAJERAS ===")
    result_3 = calcular_costos_retail(lambda, mu, 3, server_cost, waiting_cost)
    
    if result_3.feasible
        metrics_3 = result_3.metrics
        @printf("Sistema con 3 cajeras:\n")
        @printf("  ρ = %.3f (%.1f%% utilización por cajera)\n", metrics_3.rho, metrics_3.rho*100)
        @printf("  P₀ = %.4f (%.2f%% probabilidad sistema vacío)\n", metrics_3.P0, metrics_3.P0*100)
        @printf("  L = %.3f clientes promedio en sistema\n", metrics_3.L)
        @printf("  Lq = %.3f clientes promedio en cola\n", metrics_3.Lq)
        @printf("  W = %.4f horas = %.2f minutos en sistema\n", metrics_3.W, metrics_3.W*60)
        @printf("  Wq = %.4f horas = %.2f minutos en cola\n", metrics_3.Wq, metrics_3.Wq*60)
        
        @printf("\nCostos con 3 cajeras:\n")
        @printf("  Costo personal: \$%.2f/hora\n", result_3.cost_servers)
        @printf("  Costo espera: \$%.2f/hora\n", result_3.cost_waiting)
        @printf("  Costo total: \$%.2f/hora\n", result_3.total_cost)
    end
    
    # Análisis completo para diferentes números de cajeras (parte b)
    println("\n=== PARTE B: OPTIMIZACIÓN DEL NÚMERO DE CAJERAS ===")
    println("Cajeras | Utilización | Costo Personal | Costo Espera | Costo Total | Estado")
    println("--------|-------------|----------------|--------------|-------------|--------")
    
    results = []
    min_cost = Inf
    optimal_s = 0
    
    for s in 1:8
        result = calcular_costos_retail(lambda, mu, s, server_cost, waiting_cost)
        
        if result.feasible
            push!(results, result)
            
            @printf("%7d | %10.1f%% | %13.2f | %11.2f | %10.2f | %7s\n",
                   s, result.metrics.rho*100, result.cost_servers, 
                   result.cost_waiting, result.total_cost, "✓")
            
            if result.total_cost < min_cost
                min_cost = result.total_cost
                optimal_s = s
            end
        else
            rho_unstable = lambda / (s * mu)
            @printf("%7d | %10.1f%% | %13.2f | %11s | %10s | %7s\n",
                   s, rho_unstable*100, s * server_cost, "∞", "∞", "✗")
        end
    end
    
    # Mostrar solución óptima
    println("\n=== SOLUCIÓN ÓPTIMA ===")
    if optimal_s > 0
        optimal_result = calcular_costos_retail(lambda, mu, optimal_s, server_cost, waiting_cost)
        @printf("Número óptimo de cajeras: %d\n", optimal_s)
        @printf("Costo total mínimo: \$%.2f/hora\n", min_cost)
        
        # Desglose de costos
        pct_personal = optimal_result.cost_servers / min_cost * 100
        pct_espera = optimal_result.cost_waiting / min_cost * 100
        
        @printf("  - Costo personal: \$%.2f/hora (%.1f%%)\n", 
                optimal_result.cost_servers, pct_personal)
        @printf("  - Costo espera: \$%.2f/hora (%.1f%%)\n", 
                optimal_result.cost_waiting, pct_espera)
        
        # Métricas del sistema óptimo
        opt_metrics = optimal_result.metrics
        println("\n=== MÉTRICAS DEL SISTEMA ÓPTIMO ===")
        @printf("  ρ = %.3f (%.1f%% utilización por cajera)\n", 
                opt_metrics.rho, opt_metrics.rho*100)
        @printf("  L = %.3f clientes en sistema\n", opt_metrics.L)
        @printf("  Lq = %.3f clientes en cola\n", opt_metrics.Lq)
        @printf("  W = %.4f horas = %.2f minutos en sistema\n", 
                opt_metrics.W, opt_metrics.W*60)
        @printf("  Wq = %.4f horas = %.2f minutos en cola\n", 
                opt_metrics.Wq, opt_metrics.Wq*60)
        
        # Análisis de impacto en ventas
        println("\n=== IMPACTO EN VENTAS ===")
        clientes_perdidos_por_espera = opt_metrics.Lq * 0.1  # 10% se va por espera larga
        venta_promedio = 50  # $ por cliente
        perdida_ventas_hora = clientes_perdidos_por_espera * venta_promedio
        
        @printf("Estimación de impacto (asumiendo 10%% abandono por espera):\n")
        @printf("  Clientes que abandonan: %.2f por hora\n", clientes_perdidos_por_espera)
        @printf("  Perdida en ventas: \$%.2f/hora\n", perdida_ventas_hora)
        @printf("  Costo total real: \$%.2f/hora\n", min_cost + perdida_ventas_hora)
    end
    
    return results, optimal_s, min_cost
end

# Función para análisis de sensibilidad del costo de espera
function analisis_sensibilidad_espera(lambda, mu, server_cost)
    println("\n=== ANÁLISIS DE SENSIBILIDAD: COSTO DE ESPERA ===")
    println("¿Cómo cambia la decisión óptima con diferente valoración del tiempo de espera?")
    
    waiting_costs = [50, 75, 100, 125, 150, 200, 300]  # $/hora por cliente
    
    println("Costo Espera | Cajeras | Costo Total | Costo Personal | Costo Espera")
    println("(\$/h/cliente)| Óptimas |    (\$/h)   |     (\$/h)     |    (\$/h)   ")
    println("-------------|---------|-------------|----------------|-------------")
    
    for wc in waiting_costs
        # Encontrar óptimo para este costo
        best_s = 0
        best_cost = Inf
        best_result = nothing
        
        for s in 1:8
            result = calcular_costos_retail(lambda, mu, s, server_cost, wc)
            if result.feasible && result.total_cost < best_cost
                best_cost = result.total_cost
                best_s = s
                best_result = result
            end
        end
        
        @printf("%12d | %7d | %11.2f | %14.2f | %11.2f\n",
               wc, best_s, best_cost, best_result.cost_servers, best_result.cost_waiting)
    end
    
    println("\n📊 Observación: Mayor valoración del tiempo → Más cajeras óptimas")
end

# Función para análisis de break-even
function analisis_breakeven(lambda, mu, server_cost)
    println("\n=== ANÁLISIS DE BREAK-EVEN ===")
    println("¿Cuándo se justifica una cajera adicional?")
    
    # Comparar 3 vs 4 cajeras
    for cajeras in [3, 4, 5]
        result = calcular_costos_retail(lambda, mu, cajeras, server_cost, 100)
        if result.feasible
            # Calcular punto de equilibrio
            costo_adicional = server_cost  # costo de una cajera adicional
            ahorro_tiempo = lambda * result.metrics.Wq  # cliente-horas ahorradas
            
            breakeven_value = costo_adicional / ahorro_tiempo
            
            @printf("Con %d cajeras:\n", cajeras)
            @printf("  Tiempo total de espera: %.3f cliente-horas/hora\n", ahorro_tiempo)
            @printf("  Para justificar cajera adicional, valor tiempo > \$%.2f/cliente-hora\n", 
                   breakeven_value)
            println()
        end
    end
end

# Función para análisis de diferentes escenarios de demanda
function analisis_demanda_variable(mu, server_cost, waiting_cost)
    println("\n=== ANÁLISIS CON DEMANDA VARIABLE ===")
    println("Número óptimo de cajeras según nivel de demanda:")
    
    demandas = [5, 8, 10, 12, 15, 18, 20]  # clientes/hora
    
    println("Demanda | Cajeras | Utilización | Costo Total | Tiempo Espera")
    println("(cl/h)  | Óptimas |     (%)     |    (\$/h)   |    (min)     ")
    println("--------|---------|-------------|-------------|---------------")
    
    for lambda in demandas
        # Encontrar óptimo
        best_s = 0
        best_cost = Inf
        best_result = nothing
        
        for s in 1:8
            result = calcular_costos_retail(lambda, mu, s, server_cost, waiting_cost)
            if result.feasible && result.total_cost < best_cost
                best_cost = result.total_cost
                best_s = s
                best_result = result
            end
        end
        
        if best_result !== nothing
            @printf("%7d | %7d | %10.1f | %11.2f | %13.2f\n",
                   lambda, best_s, best_result.metrics.rho*100, 
                   best_cost, best_result.metrics.Wq*60)
        end
    end
    
    println("\n💡 Insight: La demanda determina fuertemente el staffing óptimo")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
results, optimal_s, min_cost = ejercicio_6()

# Ejecutar análisis de sensibilidad
analisis_sensibilidad_espera(10, 5, 30)

# Ejecutar análisis de break-even
analisis_breakeven(10, 5, 30)

# Ejecutar análisis de demanda variable
analisis_demanda_variable(5, 30, 100)

println("\n" * "=" ^ 60)
println("ANÁLISIS DE COSTOS TIENDA DE ROPA COMPLETADO")
println("=" ^ 60)

# Función adicional para recomendaciones gerenciales
function recomendaciones_gerenciales(optimal_s, min_cost)
    println("\n=== RECOMENDACIONES GERENCIALES ===")
    
    println("📋 DECISIÓN PRINCIPAL:")
    @printf("   ✓ Operar con %d cajeras para minimizar costos totales\n", optimal_s)
    @printf("   ✓ Costo óptimo: \$%.2f/hora (\$%.0f/día en 10h de operación)\n", 
           min_cost, min_cost * 10)
    
    println("\n🎯 IMPLEMENTACIÓN:")
    println("   • Programar siempre $optimal_s cajeras en horarios pico")
    println("   • Monitorear tiempo de espera real vs proyectado")
    println("   • Ajustar si cambia el patrón de demanda")
    
    println("\n📊 MÉTRICAS A SEGUIR:")
    println("   • Tiempo promedio de espera en cola")
    println("   • Utilización de cajeras (no debe superar 85%)")
    println("   • Quejas de clientes por tiempo de espera")
    println("   • Abandono de compras por colas largas")
    
    println("\n⚠️  CONSIDERACIONES ADICIONALES:")
    println("   • El modelo asume llegadas Poisson y servicio exponencial")
    println("   • Validar supuestos con datos reales de operación")
    println("   • Considerar variabilidad horaria y estacional")
    println("   • Evaluar impacto en satisfacción del cliente")
end

# Ejecutar recomendaciones
recomendaciones_gerenciales(optimal_s, min_cost)