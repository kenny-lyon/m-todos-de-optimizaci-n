# ============================================================================
# EJERCICIO 3: McDONALD'S CON OPTIMIZACIÓN DE COSTOS
# ============================================================================

using Statistics, Printf

# Función para calcular P0 en sistema M/M/s
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

# Función para análisis M/M/s completo
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

# Función para calcular costo total
function total_cost(lambda, mu, s, server_cost, waiting_cost)
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

# Función principal del ejercicio 3
function ejercicio_3()
    println("=" ^ 60)
    println("EJERCICIO 3: McDONALD'S CON OPTIMIZACIÓN DE COSTOS")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda = 66  # clientes/hora
    mu = 30      # clientes/hora por caja
    server_cost = 9    # $/hora por caja
    waiting_cost = 30  # $/hora por cliente

    println("=== PARÁMETROS DEL PROBLEMA ===")
    println("λ = $lambda clientes/hora")
    println("μ = $mu clientes/hora por caja")
    println("Costo servidor: \$$server_cost/hora por caja")
    println("Costo espera: \$$waiting_cost/hora por cliente")
    @printf("Costo espera original: \$%.2f/min por cliente\n", waiting_cost/60)

    # Análisis para diferentes números de cajas
    println("\n=== ANÁLISIS DE COSTOS ===")
    println("Cajas | Utilización | Costo Servidores | Costo Espera | Costo Total | Factible")
    println("------|-------------|------------------|--------------|-------------|----------")
    
    results = []
    min_cost = Inf
    optimal_s = 0

    for s in 1:8
        result = total_cost(lambda, mu, s, server_cost, waiting_cost)
        
        if result.feasible
            push!(results, result)
            
            @printf("%5d | %10.1f%% | %15.2f | %11.2f | %10.2f | %8s\n",
                   s, result.metrics.rho*100, result.cost_servers, 
                   result.cost_waiting, result.total_cost, "✓")
            
            if result.total_cost < min_cost
                min_cost = result.total_cost
                optimal_s = s
            end
        else
            rho_unstable = lambda / (s * mu)
            @printf("%5d | %10.1f%% | %15s | %11s | %10s | %8s\n",
                   s, rho_unstable*100, "N/A", "N/A", "∞", "✗")
        end
    end

    # Mostrar solución óptima
    println("\n=== SOLUCIÓN ÓPTIMA ===")
    if optimal_s > 0
        optimal_result = total_cost(lambda, mu, optimal_s, server_cost, waiting_cost)
        @printf("Número óptimo de cajas: %d\n", optimal_s)
        @printf("Costo total mínimo: \$%.2f/hora\n", min_cost)
        @printf("  - Costo servidores: \$%.2f/hora (%.1f%%)\n", 
                optimal_result.cost_servers, 
                optimal_result.cost_servers/min_cost*100)
        @printf("  - Costo espera: \$%.2f/hora (%.1f%%)\n", 
                optimal_result.cost_waiting,
                optimal_result.cost_waiting/min_cost*100)

        # Mostrar métricas del sistema óptimo
        metrics = optimal_result.metrics
        println("\n=== MÉTRICAS DEL SISTEMA ÓPTIMO ===")
        @printf("  ρ = %.3f (%.1f%% utilización por caja)\n", metrics.rho, metrics.rho*100)
        @printf("  P₀ = %.4f (%.2f%% probabilidad sistema vacío)\n", metrics.P0, metrics.P0*100)
        @printf("  L = %.3f clientes promedio en sistema\n", metrics.L)
        @printf("  Lq = %.3f clientes promedio en cola\n", metrics.Lq)
        @printf("  W = %.4f horas = %.2f minutos tiempo en sistema\n", metrics.W, metrics.W*60)
        @printf("  Wq = %.4f horas = %.2f minutos tiempo en cola\n", metrics.Wq, metrics.Wq*60)
        
        # Análisis de throughput
        throughput = lambda  # todos los clientes son atendidos (sistema estable)
        @printf("  Throughput: %.0f clientes/hora\n", throughput)
        @printf("  Ingresos potenciales perdidos por espera: \$%.2f/hora\n", 
                metrics.Lq * waiting_cost)
    else
        println("ERROR: No se encontró solución factible")
    end
    
    return results, optimal_s, min_cost
end

# Función para análisis de sensibilidad de costos
function analisis_sensibilidad_costos(lambda, mu, optimal_s)
    println("\n=== ANÁLISIS DE SENSIBILIDAD ===")
    println("Impacto del cambio en el costo de espera:")
    
    server_cost = 9
    waiting_costs = [10, 20, 30, 40, 50, 75, 100]
    
    println("Costo Espera | Cajas Óptimas | Costo Total | Cambio %")
    println("(\$/h/cliente)|              |    (\$/h)   |         ")
    println("-------------|---------------|-------------|----------")
    
    base_cost = 30
    base_result = total_cost(lambda, mu, optimal_s, server_cost, base_cost)
    
    for wc in waiting_costs
        # Encontrar óptimo para este costo
        best_s = 0
        best_cost = Inf
        
        for s in 1:8
            result = total_cost(lambda, mu, s, server_cost, wc)
            if result.feasible && result.total_cost < best_cost
                best_cost = result.total_cost
                best_s = s
            end
        end
        
        cambio = ((best_cost - base_result.total_cost) / base_result.total_cost) * 100
        
        @printf("%12d | %13d | %11.2f | %+8.1f%%\n", 
               wc, best_s, best_cost, cambio)
    end
    
    println("\n📊 Conclusión: El costo de espera influye significativamente en el número óptimo de cajas")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
results, optimal_s, min_cost = ejercicio_3()

# Ejecutar análisis de sensibilidad
if optimal_s > 0
    analisis_sensibilidad_costos(66, 30, optimal_s)
end

println("\n" * "=" ^ 60)
println("OPTIMIZACIÓN McDONALD'S COMPLETADA")
println("=" ^ 60)

# Función adicional para visualizar el trade-off
function mostrar_tradeoff(results)
    println("\n=== ANÁLISIS DE TRADE-OFF ===")
    println("Visualización del balance costo-servicio:")
    
    for result in results
        if result.feasible
            bar_servers = "█" ^ Int(round(result.cost_servers / 10))
            bar_waiting = "░" ^ Int(round(result.cost_waiting / 10))
            
            @printf("Cajas %d: Servidores %s Espera %s Total: \$%.0f\n",
                   result.servers, bar_servers, bar_waiting, result.total_cost)
        end
    end
    
    println("\nLeyenda: █ = Costo servidores, ░ = Costo espera")
    println("El óptimo balancea ambos costos eficientemente")
end

# Mostrar visualización del trade-off
mostrar_tradeoff(results)