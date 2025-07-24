# ============================================================================
# EJERCICIO 2: MODELO M/G/1 - PLANTA DE ENSAMBLE
# ============================================================================

using Statistics, Printf

# Función para análisis M/G/1 usando fórmula Pollaczek-Khinchine
function mg1_analysis(lambda, mean_service, std_service)
    # Conversión a horas
    E_S = mean_service / 60  # Tiempo promedio de servicio en horas
    sigma_S = std_service / 60  # Desviación estándar en horas
    
    mu = 1 / E_S  # Tasa de servicio
    rho = lambda / mu  # Factor de utilización
    
    if rho >= 1
        error("Sistema inestable: ρ = $rho ≥ 1")
    end
    
    # Coeficiente de variación al cuadrado
    Cv2 = (sigma_S / E_S)^2
    
    # Fórmula Pollaczek-Khinchine para Wq
    Wq = (rho^2 * (1 + Cv2)) / (2 * (1 - rho)) * E_S
    
    # Otras medidas
    W = Wq + E_S
    Lq = lambda * Wq
    L = lambda * W
    
    return (
        rho = rho,
        mu = mu,
        Cv2 = Cv2,
        Wq_hours = Wq,
        Wq_minutes = Wq * 60,
        W_hours = W,
        W_minutes = W * 60,
        Lq = Lq,
        L = L,
        mean_service = mean_service,
        std_service = std_service
    )
end

# Función principal del ejercicio 2
function ejercicio_2()
    println("=" ^ 60)
    println("EJERCICIO 2: MODELO M/G/1 - PLANTA DE ENSAMBLE")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda = 5  # trabajos por hora

    println("=== ANÁLISIS M/G/1 - PLANTA DE ENSAMBLE ===")
    println("Tasa de llegadas: $lambda trabajos/hora\n")

    # Diseño A
    println("DISEÑO A:")
    diseño_A = mg1_analysis(lambda, 6.0, 3.0)
    @printf("  Tiempo promedio servicio: %.1f min\n", diseño_A.mean_service)
    @printf("  Desviación estándar: %.1f min\n", diseño_A.std_service)
    @printf("  Tasa de servicio: %.1f trabajos/hora\n", diseño_A.mu)
    @printf("  Factor utilización: %.3f (%.1f%%)\n", diseño_A.rho, diseño_A.rho*100)
    @printf("  Coef. variación²: %.3f\n", diseño_A.Cv2)
    @printf("  Tiempo en cola: %.3f min\n", diseño_A.Wq_minutes)
    @printf("  Tiempo en sistema: %.3f min\n", diseño_A.W_minutes)
    @printf("  Número en cola: %.3f trabajos\n", diseño_A.Lq)
    @printf("  Número en sistema: %.3f trabajos\n", diseño_A.L)

    println("\nDISEÑO B:")
    diseño_B = mg1_analysis(lambda, 6.25, 0.6)
    @printf("  Tiempo promedio servicio: %.2f min\n", diseño_B.mean_service)
    @printf("  Desviación estándar: %.1f min\n", diseño_B.std_service)
    @printf("  Tasa de servicio: %.1f trabajos/hora\n", diseño_B.mu)
    @printf("  Factor utilización: %.3f (%.1f%%)\n", diseño_B.rho, diseño_B.rho*100)
    @printf("  Coef. variación²: %.4f\n", diseño_B.Cv2)
    @printf("  Tiempo en cola: %.3f min\n", diseño_B.Wq_minutes)
    @printf("  Tiempo en sistema: %.3f min\n", diseño_B.W_minutes)
    @printf("  Número en cola: %.3f trabajos\n", diseño_B.Lq)
    @printf("  Número en sistema: %.3f trabajos\n", diseño_B.L)

    # Comparación detallada
    println("\n=== COMPARACIÓN DE DISEÑOS ===")
    diferencia_tiempo = diseño_B.W_minutes - diseño_A.W_minutes
    porcentaje_dif = (diferencia_tiempo) / diseño_A.W_minutes * 100
    
    @printf("Diferencia en tiempo total: %.3f min\n", diferencia_tiempo)
    @printf("Porcentaje de diferencia: %.1f%%\n", porcentaje_dif)
    
    # Análisis de variabilidad
    println("\n=== ANÁLISIS DE VARIABILIDAD ===")
    @printf("Diseño A - Alta variabilidad (Cv² = %.3f):\n", diseño_A.Cv2)
    @printf("  Impacto: Mayor tiempo de espera debido a incertidumbre\n")
    @printf("Diseño B - Baja variabilidad (Cv² = %.4f):\n", diseño_B.Cv2)
    @printf("  Impacto: Servicio más predecible pero ligeramente más lento\n")

    # Recomendación
    println("\n=== RECOMENDACIÓN ===")
    if diseño_A.W_minutes < diseño_B.W_minutes
        println("✓ DISEÑO A es superior:")
        @printf("  - %.1f%% más rápido en tiempo total\n", abs(porcentaje_dif))
        @printf("  - Mejor throughput general\n")
        println("  - Recomendado para maximizar productividad")
    else
        println("✓ DISEÑO B es superior:")
        @printf("  - %.1f%% más rápido en tiempo total\n", abs(porcentaje_dif))
        @printf("  - Mayor consistencia en tiempos\n")
        println("  - Recomendado para mayor predictibilidad")
    end
    
    return (diseño_A=diseño_A, diseño_B=diseño_B, diferencia=diferencia_tiempo)
end

# Función adicional para análisis de sensibilidad
function analisis_sensibilidad_mg1(lambda, mean_service)
    println("\n=== ANÁLISIS DE SENSIBILIDAD ===") 
    println("Impacto de la variabilidad en el tiempo de servicio:")
    println("Media fija: $mean_service min, λ = $lambda trabajos/hora")
    println()
    
    # Diferentes niveles de variabilidad
    std_values = [0.1, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0]
    
    println("Desv.Std | Cv²    | Wq (min) | W (min) | Impacto Wq")
    println("---------|--------|----------|---------|------------")
    
    base_result = mg1_analysis(lambda, mean_service, std_values[1])
    
    for std_val in std_values
        result = mg1_analysis(lambda, mean_service, std_val)
        impacto = ((result.Wq_minutes - base_result.Wq_minutes) / base_result.Wq_minutes) * 100
        
        @printf("%8.1f | %6.3f | %8.3f | %7.3f | %+7.1f%%\n", 
               std_val, result.Cv2, result.Wq_minutes, result.W_minutes, impacto)
    end
    
    println("\n📊 Conclusión: La variabilidad tiene un impacto significativo en los tiempos de espera")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
resultado = ejercicio_2()

# Ejecutar análisis de sensibilidad adicional
analisis_sensibilidad_mg1(5, 6.0)

println("\n" * "=" ^ 60)
println("ANÁLISIS M/G/1 COMPLETADO")
println("=" ^ 60)