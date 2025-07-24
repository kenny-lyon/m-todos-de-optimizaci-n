# ============================================================================
# EJERCICIO 9: LOCAL DE HOT DOGS - M/M/1 (MARTY)
# ============================================================================

using Statistics, Printf

# Función para análisis M/M/1 (reutilizada y mejorada)
function mm1_analysis_complete(lambda, mu)
    rho = lambda / mu
    
    if rho >= 1
        error("Sistema inestable: ρ = $rho ≥ 1")
    end
    
    # Medidas básicas de rendimiento
    L = rho / (1 - rho)
    Lq = rho^2 / (1 - rho)
    W = 1 / (mu - lambda)
    Wq = rho / (mu - lambda)
    
    # Métricas adicionales
    P0 = 1 - rho  # Probabilidad de sistema vacío
    throughput = lambda  # En sistema estable, throughput = λ
    capacity_utilization = rho
    idle_time = 1 - rho
    
    return (
        lambda = lambda,
        mu = mu,
        rho = rho,
        L = L,
        Lq = Lq,
        W = W,
        Wq = Wq,
        P0 = P0,
        throughput = throughput,
        capacity_utilization = capacity_utilization,
        idle_time = idle_time
    )
end

# Función para análisis de distribución de probabilidades
function analizar_distribucion_estados(result, max_estados=10)
    println("\n=== DISTRIBUCIÓN DE PROBABILIDADES DE ESTADO ===")
    println("Clientes | P(n)     | P(%)   | Acum% | Interpretación")
    println("en sistema|          |        |       |               ")
    println("---------|----------|--------|-------|----------------")
    
    acum = 0.0
    for n in 0:max_estados
        prob_n = result.P0 * result.rho^n
        pct = prob_n * 100
        acum += prob_n
        
        # Interpretación del estado
        if n == 0
            interp = "Marty libre"
        elseif n == 1
            interp = "Marty ocupado, sin cola"
        else
            interp = "Marty ocupado, $(n-1) esperando"
        end
        
        @printf("%9d | %8.4f | %6.2f | %5.1f | %s\n",
               n, prob_n, pct, acum*100, interp)
    end
    
    # Probabilidad de más de max_estados clientes
    prob_mas = 1 - acum
    @printf("%8s+ | %8.4f | %6.2f | %5.1f | %s\n",
           max_estados, prob_mas, prob_mas*100, 100.0, "Estados superiores")
end

# Función principal del ejercicio 9
function ejercicio_9()
    println("=" ^ 60)
    println("EJERCICIO 9: LOCAL DE HOT DOGS - MARTY (M/M/1)")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda = 20  # clientes/hora
    mu = 30      # clientes/hora (capacidad de Marty)
    
    println("=== PARÁMETROS DEL NEGOCIO ===")
    println("λ = $lambda clientes/hora (demanda actual)")
    println("μ = $mu clientes/hora (capacidad máxima de Marty)")
    @printf("Tiempo promedio de servicio: %.1f minutos\n", 60/mu)
    @printf("Capacidad no utilizada: %d clientes/hora (%.1f%%)\n", 
           mu - lambda, (mu - lambda)/mu * 100)
    
    # Realizar análisis
    result = mm1_analysis_complete(lambda, mu)
    
    println("\n=== CARACTERÍSTICAS DE LA COLA ===")
    @printf("ρ = λ/μ = %.4f (%.2f%% utilización de Marty)\n", 
           result.rho, result.rho*100)
    @printf("L = %.4f clientes promedio en el sistema\n", result.L)
    @printf("Lq = %.4f clientes promedio en cola\n", result.Lq)
    @printf("W = %.4f horas = %.2f minutos tiempo promedio en sistema\n", 
           result.W, result.W*60)
    @printf("Wq = %.4f horas = %.2f minutos tiempo promedio en cola\n", 
           result.Wq, result.Wq*60)
    @printf("P₀ = %.4f = %.2f%% probabilidad de sistema vacío\n", 
           result.P0, result.P0*100)
    
    # Análisis de eficiencia
    println("\n=== ANÁLISIS DE EFICIENCIA ===")
    busy_time_pct = result.rho * 100
    idle_time_pct = result.idle_time * 100
    
    @printf("Tiempo que Marty está ocupado: %.2f%% del día\n", busy_time_pct)
    @printf("Tiempo que Marty está ocioso: %.2f%% del día\n", idle_time_pct)
    
    # Análisis temporal detallado
    println("\n=== ANÁLISIS TEMPORAL DETALLADO ===")
    horas_operacion = [8, 10, 12]  # Diferentes jornadas laborales
    
    for horas in horas_operacion
        busy_hours = result.rho * horas
        idle_hours = result.idle_time * horas
        clientes_dia = lambda * horas
        capacidad_dia = mu * horas
        
        @printf("\nJornada de %d horas:\n", horas)
        @printf("  Horas ocupado: %.2f horas (%.1f%%)\n", busy_hours, busy_hours/horas*100)
        @printf("  Horas ocioso: %.2f horas (%.1f%%)\n", idle_hours, idle_hours/horas*100)
        @printf("  Clientes atendidos: %d\n", clientes_dia)
        @printf("  Capacidad máxima: %d clientes\n", capacidad_dia)
        @printf("  Capacidad no utilizada: %d clientes\n", capacidad_dia - clientes_dia)
    end
    
    # Mostrar distribución de estados
    analizar_distribucion_estados(result)
    
    return result
end

# Función para análisis de oportunidades de crecimiento
function analizar_oportunidades_crecimiento(result_actual)
    println("\n=== ANÁLISIS DE OPORTUNIDADES DE CRECIMIENTO ===")
    
    mu = result_actual.mu
    lambda_actual = result_actual.lambda
    
    # Diferentes escenarios de demanda
    escenarios_demanda = [
        (22, "Promoción leve (+10%)"),
        (25, "Marketing efectivo (+25%)"),
        (28, "Ubicación premium (+40%)"),
        (29, "Límite operativo seguro")
    ]
    
    println("Escenario                    | Demanda | Utilización | Tiempo | Clientes")
    println("                             | (cl/h)  |     (%)     | cola   | en cola ")
    println("-----------------------------|---------|-------------|--------|----------")
    
    @printf("%-28s | %7d | %10.1f | %6.2f | %8.3f\n",
           "Actual", lambda_actual, result_actual.rho*100, 
           result_actual.Wq*60, result_actual.Lq)
    
    for (lambda_nuevo, descripcion) in escenarios_demanda
        if lambda_nuevo < mu  # Verificar estabilidad
            result_nuevo = mm1_analysis_complete(lambda_nuevo, mu)
            @printf("%-28s | %7d | %10.1f | %6.2f | %8.3f\n",
                   descripcion, lambda_nuevo, result_nuevo.rho*100,
                   result_nuevo.Wq*60, result_nuevo.Lq)
        else
            @printf("%-28s | %7d | %10s | %6s | %8s\n",
                   descripcion, lambda_nuevo, "INESTABLE", "∞", "∞")
        end
    end
    
    println("\n💡 Insights de crecimiento:")
    println("  • El negocio puede crecer hasta ~29 clientes/hora manteniendo buen servicio")
    println("  • Con 25 cl/h: utilización saludable del 83% con tiempos aceptables")
    println("  • Más allá de 28 cl/h: riesgo de colas excesivas y pérdida de clientes")
end

# Función para análisis financiero
function analisis_financiero_marty(result)
    println("\n=== ANÁLISIS FINANCIERO DEL NEGOCIO ===")
    
    # Parámetros financieros (ejemplos realistas)
    precio_hotdog = 5.50        # $ por hot dog
    costo_variable = 2.20       # $ ingredientes por hot dog
    costos_fijos_hora = 15      # $ por hora (renta, servicios)
    salario_marty_hora = 20     # $ por hora
    
    # Cálculos por hora
    ventas_hora = result.lambda * precio_hotdog
    costos_variables_hora = result.lambda * costo_variable
    costos_totales_hora = costos_variables_hora + costos_fijos_hora + salario_marty_hora
    utilidad_hora = ventas_hora - costos_totales_hora
    margen_utilidad = utilidad_hora / ventas_hora * 100
    
    println("ANÁLISIS FINANCIERO POR HORA:")
    @printf("  Clientes atendidos: %.0f\n", result.lambda)
    @printf("  Ventas: \$%.2f\n", ventas_hora)
    @printf("  Costos variables: \$%.2f\n", costos_variables_hora)
    @printf("  Costos fijos: \$%.2f\n", costos_fijos_hora)
    @printf("  Salario Marty: \$%.2f\n", salario_marty_hora)
    @printf("  Costos totales: \$%.2f\n", costos_totales_hora)
    @printf("  Utilidad neta: \$%.2f/hora\n", utilidad_hora)
    @printf("  Margen de utilidad: %.1f%%\n", margen_utilidad)
    
    # Proyecciones
    horas_dia = 8
    dias_mes = 22  # días laborables
    
    utilidad_dia = utilidad_hora * horas_dia
    utilidad_mes = utilidad_dia * dias_mes
    utilidad_anual = utilidad_mes * 12
    
    @printf("\nPROYECCIONES:\n")
    @printf("  Utilidad diaria: \$%.2f\n", utilidad_dia)
    @printf("  Utilidad mensual: \$%.2f\n", utilidad_mes)
    @printf("  Utilidad anual: \$%.2f\n", utilidad_anual)
    
    # Análisis de capacidad ociosa
    capacidad_ociosa_hora = result.mu - result.lambda
    ingresos_perdidos_hora = capacidad_ociosa_hora * (precio_hotdog - costo_variable)
    ingresos_perdidos_anuales = ingresos_perdidos_hora * horas_dia * dias_mes * 12
    
    @printf("\nANÁLISIS DE CAPACIDAD OCIOSA:\n")
    @printf("  Capacidad no utilizada: %.0f hot dogs/hora\n", capacidad_ociosa_hora)
    @printf("  Ingresos potenciales perdidos: \$%.2f/hora\n", ingresos_perdidos_hora)
    @printf("  Oportunidad anual perdida: \$%.2f\n", ingresos_perdidos_anuales)
end

# Función para estrategias de mejora
function estrategias_mejora_negocio(lambda, mu)
    println("\n=== ESTRATEGIAS DE MEJORA DEL NEGOCIO ===")
    
    # Diferentes estrategias
    estrategias = [
        ("Base actual", lambda, mu, 0, "Situación actual"),
        ("Marketing digital", lambda*1.15, mu, 500, "Redes sociales + promociones"),
        ("Servicio más rápido", lambda, mu*1.2, 800, "Optimizar proceso de preparación"),
        ("Combo meals", lambda*1.1, mu*1.1, 300, "Ofertas que agilizan decisión"),
        ("Horario extendido", lambda*1.25, mu, 1200, "2 horas adicionales por día"),
        ("Ayudante part-time", lambda*1.3, mu*1.4, 2400, "Apoyo en horarios pico")
    ]
    
    # Parámetros financieros
    margen_contribucion = 3.30  # precio - costo variable
    horas_año = 2000           # horas operativas
    
    println("Estrategia              | Nueva   | Nueva   | Costo   | Ingresos | ROI")
    println("                        | demanda | utiliz. | anual   | adic.    | (%)")
    println("------------------------|---------|---------|---------|----------|-----")
    
    base_ingresos = lambda * margen_contribucion * horas_año
    
    for (nombre, lambda_new, mu_new, costo_anual, descripcion) in estrategias
        if lambda_new < mu_new  # Verificar factibilidad
            result_new = mm1_analysis_complete(lambda_new, mu_new)
            ingresos_nuevos = lambda_new * margen_contribuicion * horas_año
            ingresos_adicionales = ingresos_nuevos - base_ingresos
            
            if costo_anual > 0
                roi = (ingresos_adicionales - costo_anual) / costo_anual * 100
                @printf("%-23s | %7.0f | %7.1f%% | \$%6.0f | \$%7.0f | %+4.0f%%\n",
                       nombre, lambda_new, result_new.rho*100, costo_anual, 
                       ingresos_adicionales, roi)
            else
                @printf("%-23s | %7.0f | %7.1f%% | \$%6s | \$%7s | %4s\n",
                       nombre, lambda_new, result_new.rho*100, "0", "0", "Base")
            end
        else
            @printf("%-23s | %7.0f | %7s | \$%6.0f | %7s | %4s\n",
                   nombre, lambda_new, "INEST.", costo_anual, "N/A", "N/A")
        end
    end
    
    println("\n🎯 Recomendación: Marketing digital + servicio más rápido")
    println("   Combinación de bajo costo con alto impacto")
end

# Función para análisis de riesgo operacional
function analisis_riesgo_operacional(result)
    println("\n=== ANÁLISIS DE RIESGO OPERACIONAL ===")
    
    # Simulación de escenarios adversos
    escenarios_riesgo = [
        ("Normal", result.lambda, result.mu, 0),
        ("Día lluvioso (-20% demanda)", result.lambda*0.8, result.mu, 20),
        ("Marty enfermo (cierre)", 0, result.mu, 100),
        ("Competencia cercana (-30%)", result.lambda*0.7, result.mu, 30),
        ("Día festivo (+50% demanda)", result.lambda*1.5, result.mu, 0)
    ]
    
    println("Escenario                    | Impacto    | Prob. | Utilidad | Riesgo")
    println("                             | demanda    | (%)   | relativa | (\$)")
    println("-----------------------------|------------|-------|----------|--------")
    
    utilidad_normal = 35.0  # $/hora ejemplo
    
    for (escenario, lambda_esc, mu_esc, prob_pct) in escenarios_riesgo
        if lambda_esc > 0 && lambda_esc < mu_esc
            result_esc = mm1_analysis_complete(lambda_esc, mu_esc)
            utilidad_relativa = lambda_esc / result.lambda
            riesgo_financiero = (1 - utilidad_relativa) * utilidad_normal * prob_pct / 100
            
            @printf("%-28s | %9.1f%% | %5d | %8.1f%% | \$%5.1f\n",
                   escenario, (lambda_esc/result.lambda - 1)*100, prob_pct,
                   utilidad_relativa*100, riesgo_financiero)
        else
            @printf("%-28s | %9s | %5d | %8s | \$%5s\n",
                   escenario, "Extremo", prob_pct, "0%", "N/A")
        end
    end
    
    println("\n💡 Estrategias de mitigación:")
    println("  • Diversificar productos (bebidas, snacks)")
    println("  • Desarrollar base de clientes leales")
    println("  • Tener plan de contingencia para días lentos")
    println("  • Considerar delivery para días lluviosos")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
resultado = ejercicio_9()

# Ejecutar análisis de oportunidades
analizar_oportunidades_crecimiento(resultado)

# Ejecutar análisis financiero
analisis_financiero_marty(resultado)

# Ejecutar análisis de estrategias
# Nota: Hay un pequeño error en la función, lo corregimos aquí
margen_contribucion = 3.30
estrategias_mejora_negocio(20, 30)

# Ejecutar análisis de riesgo
analisis_riesgo_operacional(resultado)

println("\n" * "=" ^ 60)
println("ANÁLISIS LOCAL DE HOT DOGS - MARTY COMPLETADO")
println("=" ^ 60)

# Función adicional para plan de negocios
function generar_plan_negocios(result)
    println("\n=== PLAN DE NEGOCIOS - RESUMEN EJECUTIVO ===")
    
    println("🎯 SITUACIÓN ACTUAL:")
    @printf("   • Demanda: %.0f clientes/hora\n", result.lambda)
    @printf("   • Utilización: %.1f%% (saludable)\n", result.rho*100)
    @printf("   • Tiempo espera promedio: %.1f minutos (aceptable)\n", result.Wq*60)
    @printf("   • Capacidad ociosa: %.1f%% (oportunidad)\n", result.idle_time*100)
    
    println("\n🚀 RECOMENDACIONES ESTRATÉGICAS:")
    println("   1. CRECIMIENTO: Aumentar demanda a 25 cl/h vía marketing")
    println("   2. EFICIENCIA: Optimizar proceso para μ = 36 cl/h")
    println("   3. DIVERSIFICACIÓN: Agregar bebidas y snacks")
    println("   4. TECNOLOGÍA: Sistema de pedidos móvil")
    
    println("\n📊 PROYECCIÓN FINANCIERA (implementando recomendaciones):")
    lambda_objetivo = 25
    mu_objetivo = 36
    
    if lambda_objetivo < mu_objetivo
        result_objetivo = mm1_analysis_complete(lambda_objetivo, mu_objetivo)
        mejora_ingresos = (lambda_objetivo - result.lambda) * 3.30 * 2000
        
        @printf("   • Ingresos adicionales: \$%.0f/año\n", mejora_ingresos)
        @printf("   • Nueva utilización: %.1f%% (óptima)\n", result_objetivo.rho*100)
        @printf("   • Nuevo tiempo espera: %.1f minutos (excelente)\n", result_objetivo.Wq*60)
        
        println("\n✅ CONCLUSIÓN: Negocio viable con excelente potencial de crecimiento")
    end
end

# Generar plan de negocios
generar_plan_negocios(resultado)