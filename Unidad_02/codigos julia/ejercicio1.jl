# ============================================================================
# EJERCICIO 1: DEPÓSITOS Y RETIROS MULTI-SKILL
# ============================================================================

using Statistics, Printf

# Función para calcular medidas M/M/1
function mm1_metrics(lambda, mu)
    rho = lambda / mu
    if rho >= 1
        error("Sistema inestable: ρ = $rho ≥ 1")
    end
    
    L = rho / (1 - rho)
    Lq = rho^2 / (1 - rho)
    W = 1 / (mu - lambda)
    Wq = rho / (mu - lambda)
    
    return (rho=rho, L=L, Lq=Lq, W=W, Wq=Wq)
end

# Función para calcular medidas M/M/2
function mm2_metrics(lambda, mu)
    rho = lambda / (2 * mu)
    if rho >= 1
        error("Sistema inestable: ρ = $rho ≥ 1")
    end
    
    # Probabilidad de sistema vacío
    P0 = 1 / (1 + (lambda/mu) + (lambda/mu)^2 / (2*(1-rho)))
    
    # Número promedio en cola
    Lq = ((lambda/mu)^2 * rho) / (2 * (1-rho)^2) * P0
    
    # Otras medidas
    Wq = Lq / lambda
    W = Wq + 1/mu
    L = lambda * W
    
    return (rho=rho, L=L, Lq=Lq, W=W, Wq=Wq, P0=P0)
end

# Función principal del ejercicio 1
function ejercicio_1()
    println("=" ^ 60)
    println("EJERCICIO 1: DEPÓSITOS Y RETIROS MULTI-SKILL")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda1, lambda2 = 16, 14  # Llegadas por hora
    mu = 20                    # Servicio por hora

    println("=== SISTEMA ACTUAL (Dos colas M/M/1 separadas) ===")

    # Sistema de depósitos (Clara)
    depositos = mm1_metrics(lambda1, mu)
    println("Depósitos (Clara):")
    @printf("  ρ = %.3f (%.1f%% utilización)\n", depositos.rho, depositos.rho*100)
    @printf("  L = %.3f clientes en sistema\n", depositos.L)
    @printf("  Lq = %.3f clientes en cola\n", depositos.Lq)
    @printf("  W = %.3f horas = %.1f minutos en sistema\n", depositos.W, depositos.W*60)
    @printf("  Wq = %.3f horas = %.1f minutos en cola\n", depositos.Wq, depositos.Wq*60)

    # Sistema de retiros (Carmen)
    retiros = mm1_metrics(lambda2, mu)
    println("\nRetiros (Carmen):")
    @printf("  ρ = %.3f (%.1f%% utilización)\n", retiros.rho, retiros.rho*100)
    @printf("  L = %.3f clientes en sistema\n", retiros.L)
    @printf("  Lq = %.3f clientes en cola\n", retiros.Lq)
    @printf("  W = %.3f horas = %.1f minutos en sistema\n", retiros.W, retiros.W*60)
    @printf("  Wq = %.3f horas = %.1f minutos en cola\n", retiros.Wq, retiros.Wq*60)

    # Tiempo promedio ponderado sistema actual
    tiempo_actual = (lambda1 * depositos.W * 60 + lambda2 * retiros.W * 60) / (lambda1 + lambda2)

    println("\n=== SISTEMA MULTI-SKILL (Una cola M/M/2) ===")

    # Sistema conjunto
    lambda_total = lambda1 + lambda2
    conjunto = mm2_metrics(lambda_total, mu)
    println("Sistema conjunto:")
    @printf("  λ total = %d/hora\n", lambda_total)
    @printf("  ρ = %.3f (%.1f%% utilización por servidor)\n", conjunto.rho, conjunto.rho*100)
    @printf("  L = %.3f clientes en sistema\n", conjunto.L)
    @printf("  Lq = %.3f clientes en cola\n", conjunto.Lq)
    @printf("  W = %.3f horas = %.3f minutos en sistema\n", conjunto.W, conjunto.W*60)
    @printf("  Wq = %.3f horas = %.3f minutos en cola\n", conjunto.Wq, conjunto.Wq*60)

    # Comparación
    println("\n=== COMPARACIÓN DE RESULTADOS ===")
    @printf("Tiempo promedio actual: %.2f minutos\n", tiempo_actual)
    @printf("Tiempo promedio multi-skill: %.3f minutos\n", conjunto.W*60)
    @printf("Mejora: %.2f minutos (%.1f%% reducción)\n", 
            tiempo_actual - conjunto.W*60, 
            (tiempo_actual - conjunto.W*60)/tiempo_actual*100)
    
    return (depositos=depositos, retiros=retiros, conjunto=conjunto, 
            tiempo_actual=tiempo_actual)
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis
resultado = ejercicio_1()

println("\n" * "=" ^ 60)
println("ANÁLISIS COMPLETADO")
println("=" ^ 60)