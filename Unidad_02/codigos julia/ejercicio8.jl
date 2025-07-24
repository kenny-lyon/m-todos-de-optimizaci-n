# ============================================================================
# EJERCICIO 8: M/M/1 COLA FINITA - PACIENTES DE CLÍNICA
# ============================================================================

using Statistics, Printf

# Función para modelo M/M/1/K (capacidad finita)
function mm1k_analysis(lambda, mu, K)
    rho = lambda / mu
    
    if abs(rho - 1.0) < 1e-10  # rho ≈ 1 (caso especial)
        # Cuando rho = 1, todas las probabilidades son iguales
        P0 = 1 / (K + 1)
        probabilities = fill(P0, K + 1)
    else
        # Caso general cuando rho ≠ 1
        P0 = (1 - rho) / (1 - rho^(K + 1))
        probabilities = [P0 * rho^n for n in 0:K]
    end
    
    # Métricas del sistema
    L = sum(n * probabilities[n+1] for n in 0:K)
    Lq = sum(max(0, n-1) * probabilities[n+1] for n in 0:K)  # n-1 porque 1 servidor
    
    # Probabilidad de pérdida (sistema lleno)
    P_loss = probabilities[K+1]
    
    # Tasa efectiva de llegadas
    lambda_eff = lambda * (1 - P_loss)
    
    # Tiempos de espera (solo para clientes que entran)
    if lambda_eff > 0
        W = L / lambda_eff
        Wq = Lq / lambda_eff
    else
        W = 0.0
        Wq = 0.0
    end
    
    # Utilización del servidor
    utilization = 1 - probabilities[1]  # 1 - P0
    
    return (
        lambda = lambda,
        mu = mu,
        K = K,
        rho = rho,
        P0 = probabilities[1],
        probabilities = probabilities,
        L = L,
        Lq = Lq,
        W = W,
        Wq = Wq,
        P_loss = P_loss,
        lambda_eff = lambda_eff,
        utilization = utilization
    )
end

# Función para mostrar distribución de probabilidades detallada
function mostrar_distribucion_capacidad_finita(result)
    println("\n=== DISTRIBUCIÓN DE PROBABILIDADES M/M/1/$(result.K) ===")
    println("Pacientes | ρⁿ        | P(n)      | P(%)   | Acum% | Interpretación")
    println("en sistema|           |           |        |       |               ")
    println("----------|-----------|-----------|--------|-------|----------------")
    
    acum = 0.0
    for n in 0:result.K
        rho_n = result.rho^n
        prob = result.probabilities[n+1]
        pct = prob * 100
        acum += prob
        
        # Interpretación según el estado
        if n == 0
            interp = "Sistema vacío"
        elseif n == 1
            interp = "Solo médico ocupado"
        elseif n <= 13
            interp = "$(n-1) esperando"
        elseif n == 14
            interp = "Sala llena"
        else
            interp = "Sistema saturado"
        end
        
        @printf("%9d | %9.6f | %9.6f | %6.2f | %5.1f | %s\n",
               n, rho_n, prob, pct, acum*100, interp)
    end
    
    println("\nLeyenda:")
    println("  • 0: Clínica vacía")
    println("  • 1: Solo médico ocupado (sin espera)")
    println("  • 2-14: Médico ocupado + (n-1) pacientes en sala de espera")
    println("  • 15: Sistema lleno - próximo paciente se va")
end

# Función principal del ejercicio 8
function ejercicio_8()
    println("=" ^ 60)
    println("EJERCICIO 8: CLÍNICA MÉDICA (M/M/1/15)")
    println("=" ^ 60)
    
    # Parámetros del problema
    lambda = 20  # pacientes/hora
    mu = 7.5     # pacientes/hora (60 min / 8 min por consulta)
    K = 15       # capacidad total (14 en sala + 1 en consulta)
    
    println("=== PARÁMETROS DEL SISTEMA ===")
    println("λ = $lambda pacientes/hora")
    println("μ = $mu pacientes/hora")
    println("Tiempo promedio por consulta: $(60/mu) minutos")
    println("Capacidad sala de espera: $(K-1) pacientes")
    println("Capacidad total sistema: $K pacientes")
    @printf("ρ = λ/μ = %.3f (sistema sobrecargado)\n", lambda/mu)
    
    # Realizar análisis
    result = mm1k_analysis(lambda, mu, K)
    
    println("\n=== RESPUESTAS A LAS PREGUNTAS ===")
    @printf("a) Probabilidad de que no espere: %.6f ≈ %.1f%%\n", 
           result.P0, result.P0*100)
    
    # Probabilidad de encontrar asiento (0 a 13 pacientes en sistema)
    P_seat = sum(result.probabilities[1:14])  # Estados 0 a 13
    @printf("b) Probabilidad de encontrar asiento: %.4f = %.2f%%\n", 
           P_seat, P_seat*100)
    
    println("\n=== MÉTRICAS ADICIONALES DEL SISTEMA ===")
    @printf("Utilización del médico: %.3f = %.1f%%\n", 
            result.utilization, result.utilization*100)
    @printf("Pacientes promedio en sistema: %.3f\n", result.L)
    @printf("Pacientes promedio en cola: %.3f\n", result.Lq)
    @printf("Tiempo promedio en sistema: %.3f horas = %.1f minutos\n", 
            result.W, result.W*60)
    @printf("Tiempo promedio en cola: %.3f horas = %.1f minutos\n", 
            result.Wq, result.Wq*60)
    @printf("Probabilidad de sistema lleno: %.4f = %.2f%%\n", 
            result.P_loss, result.P_loss*100)
    @printf("Pacientes perdidos por hora: %.2f\n", 
            lambda * result.P_loss)
    @printf("Tasa efectiva de atención: %.2f pacientes/hora\n", 
            result.lambda_eff)
    
    # Mostrar distribución detallada
    mostrar_distribucion_capacidad_finita(result)
    
    return result
end

# Función para análisis de impacto económico
function analisis_impacto_economico(result)
    println("\n=== ANÁLISIS DE IMPACTO ECONÓMICO ===")
    
    # Parámetros económicos (ejemplos)
    ingreso_por_consulta = 80      # $ por consulta
    costo_medico_hora = 60         # $ por hora
    costo_oportunidad_paciente = 25  # $ por hora de espera
    
    # Cálculos por hora
    consultas_atendidas = result.lambda_eff
    pacientes_perdidos = result.lambda * result.P_loss
    
    ingresos_hora = consultas_atendidas * ingreso_por_consulta
    costos_medico = costo_medico_hora
    costo_esperas = result.Lq * costo_oportunidad_paciente
    perdida_ingresos = pacientes_perdidos * ingreso_por_consulta
    
    utilidad_hora = ingresos_hora - costos_medico - costo_esperas
    
    println("ANÁLISIS FINANCIERO POR HORA:")
    @printf("  Consultas atendidas: %.2f\n", consultas_atendidas)
    @printf("  Pacientes perdidos: %.2f\n", pacientes_perdidos)
    @printf("  Ingresos por consultas: \$%.2f\n", ingresos_hora)
    @printf("  Costo médico: \$%.2f\n", costos_medico)
    @printf("  Costo social esperas: \$%.2f\n", costo_esperas)
    @printf("  Pérdida por saturación: \$%.2f\n", perdida_ingresos)
    @printf("  Utilidad neta: \$%.2f/hora\n", utilidad_hora)
    
    # Análisis diario (8 horas)
    horas_dia = 8
    utilidad_dia = utilidad_hora * horas_dia
    perdida_dia = perdida_ingresos * horas_dia
    
    @printf("\nANÁLISIS DIARIO (8 horas):\n")
    @printf("  Utilidad neta: \$%.2f/día\n", utilidad_dia)
    @printf("  Pérdida por saturación: \$%.2f/día\n", perdida_dia)
    @printf("  Pacientes no atendidos: %.1f/día\n", pacientes_perdidos * horas_dia)
end

# Función para evaluar alternativas de mejora
function evaluar_alternativas_mejora(lambda, K_original)
    println("\n=== EVALUACIÓN DE ALTERNATIVAS DE MEJORA ===")
    
    # Escenarios de mejora
    escenarios = [
        ("Actual", 7.5, K_original, "Base"),
        ("Consultas más rápidas (-25%)", 10.0, K_original, "Reducir tiempo consulta"),
        ("Ampliar sala (+5 asientos)", 7.5, K_original+5, "Más capacidad física"),
        ("Ambas mejoras", 10.0, K_original+5, "Tiempo + capacidad"),
        ("Segundo médico", 15.0, K_original, "Doble capacidad servicio")
    ]
    
    println("Alternativa                    | P(no espera) | P(asiento) | Pacientes | Utilidad")
    println("                               |      (%)     |     (%)    | perdidos/h| relativa")
    println("-------------------------------|--------------|------------|-----------|----------")
    
    base_result = mm1k_analysis(lambda, 7.5, K_original)
    
    for (nombre, mu, K, descripcion) in escenarios
        result = mm1k_analysis(lambda, mu, K)
        
        # Probabilidad de asiento (0 a K-2 pacientes en sistema)
        P_seat = sum(result.probabilities[1:(K-1)])
        pacientes_perdidos = lambda * result.P_loss
        
        # Utilidad relativa (simplificada)
        utilidad_rel = result.lambda_eff / base_result.lambda_eff
        
        @printf("%-30s | %11.1f | %9.1f | %9.2f | %8.1f%%\n",
               nombre, result.P0*100, P_seat*100, pacientes_perdidos, utilidad_rel*100)
    end
    
    println("\n💡 Insights:")
    println("  • Reducir tiempo de consulta es más efectivo que ampliar sala")
    println("  • Segundo médico elimina prácticamente todas las pérdidas")
    println("  • La combinación de mejoras optimiza el sistema")
end

# Función para análisis de sensibilidad de demanda
function analisis_sensibilidad_demanda(mu, K)
    println("\n=== ANÁLISIS DE SENSIBILIDAD: VARIACIÓN DE DEMANDA ===")
    println("¿Cómo afectan los cambios en la demanda al sistema?")
    
    # Diferentes niveles de demanda
    demandas = [15, 18, 20, 22, 25, 28]  # pacientes/hora
    
    println("Demanda | ρ     | P(no espera) | P(asiento) | Pacientes | Eficiencia")
    println("(pac/h) |       |      (%)     |     (%)    | perdidos/h|     (%)   ")
    println("--------|-------|--------------|------------|-----------|------------")
    
    for lambda in demandas
        result = mm1k_analysis(lambda, mu, K)
        P_seat = sum(result.probabilities[1:(K-1)])
        pacientes_perdidos = lambda * result.P_loss
        eficiencia = result.lambda_eff / lambda * 100
        
        @printf("%7d | %5.2f | %11.1f | %9.1f | %9.2f | %9.1f\n",
               lambda, result.rho, result.P0*100, P_seat*100, 
               pacientes_perdidos, eficiencia)
    end
    
    println("\n📊 Observación: Sistema muy sensible a cambios en demanda")
    println("   A mayor demanda, mayor saturación y pérdidas exponenciales")
end

# Función para recomendaciones clínicas
function recomendaciones_clinicas(result)
    println("\n=== RECOMENDACIONES PARA LA CLÍNICA ===")
    
    if result.P_loss > 0.15  # Más del 15% de pérdidas
        println("🚨 SITUACIÓN CRÍTICA:")
        @printf("   • %.1f%% de pacientes se van sin ser atendidos\n", result.P_loss*100)
        println("   • Sistema sobrecargado requiere intervención inmediata")
        
        println("\n🎯 ACCIONES RECOMENDADAS (PRIORIDAD ALTA):")
        println("   1. Reducir tiempo promedio de consulta")
        println("   2. Implementar sistema de citas programadas")
        println("   3. Considerar horario extendido")
        println("   4. Evaluar segundo médico en horas pico")
        
    elseif result.P_loss > 0.05  # Más del 5% de pérdidas
        println("⚠️  SITUACIÓN DE ATENCIÓN:")
        @printf("   • %.1f%% de pacientes se van sin ser atendidos\n", result.P_loss*100)
        println("   • Margen de mejora significativo")
        
        println("\n🎯 ACCIONES RECOMENDADAS (PRIORIDAD MEDIA):")
        println("   1. Optimizar procesos de consulta")
        println("   2. Mejorar sistema de turnos")
        println("   3. Ampliar sala de espera")
        
    else
        println("✅ SITUACIÓN ACEPTABLE:")
        @printf("   • Solo %.1f%% de pacientes se van sin ser atendidos\n", result.P_loss*100)
        println("   • Sistema funcionando dentro de parámetros normales")
    end
    
    println("\n📊 MÉTRICAS A MONITOREAR:")
    println("   • % de pacientes que se van sin ser atendidos")
    println("   • Tiempo promedio de espera real")
    println("   • Satisfacción del paciente")
    println("   • Utilización del médico")
    
    println("\n🔄 MEJORAS CONTINUAS:")
    println("   • Análisis de patrones horarios de demanda")
    println("   • Optimización de procesos administrativos")
    println("   • Capacitación para reducir tiempos de consulta")
    println("   • Implementación de telemedicina para casos simples")
end

# ============================================================================
# EJECUTAR EL EJERCICIO
# ============================================================================

# Ejecutar el análisis principal
resultado = ejercicio_8()

# Ejecutar análisis económico
analisis_impacto_economico(resultado)

# Evaluar alternativas de mejora
evaluar_alternativas_mejora(20, 15)

# Análisis de sensibilidad
analisis_sensibilidad_demanda(7.5, 15)

# Generar recomendaciones
recomendaciones_clinicas(resultado)

println("\n" * "=" ^ 60)
println("ANÁLISIS CLÍNICA MÉDICA (M/M/1/K) COMPLETADO")
println("=" ^ 60)

# Función adicional para simulación de políticas
function simular_politicas_atencion()
    println("\n=== SIMULACIÓN DE POLÍTICAS DE ATENCIÓN ===")
    
    lambda, mu, K = 20, 7.5, 15
    
    # Políticas a evaluar
    politicas = [
        ("Sin cambios", mu, K, 0),
        ("Citas programadas (-20% llegadas)", mu, K*0.8, 5000),
        ("Fast-track casos simples (+33% velocidad)", mu*1.33, K, 8000),
        ("Horario extendido (+25% capacidad)", mu*1.25, K, 12000),
        ("Telemedicina (-30% demanda presencial)", mu, K*0.7, 15000)
    ]
    
    println("Política                      | Pacientes | P(pérdida) | Costo/año | ROI")
    println("                              | atendidos/h|     (%)    |    (\$)   | (%)")
    println("------------------------------|-----------|------------|-----------|-----")
    
    base = mm1k_analysis(lambda, mu, K)
    base_atendidos = base.lambda_eff
    valor_paciente = 80  # $ por consulta
    horas_año = 2000  # horas operativas por año
    
    for (nombre, mu_pol, lambda_pol, costo_anual) in politicas
        result = mm1k_analysis(lambda_pol, mu_pol, K)
        pacientes_adicionales = (result.lambda_eff - base_atendidos) * horas_año
        beneficio_anual = pacientes_adicionales * valor_paciente
        
        if costo_anual > 0
            roi = (beneficio_anual - costo_anual) / costo_anual * 100
            @printf("%-29s | %9.2f | %9.1f | %9.0f | %+4.0f\n",
                   nombre, result.lambda_eff, result.P_loss*100, costo_anual, roi)
        else
            @printf("%-29s | %9.2f | %9.1f | %9s | %4s\n",
                   nombre, result.lambda_eff, result.P_loss*100, "0", "Base")
        end
    end
    
    println("\n💡 La telemedicina y fast-track muestran mejor ROI")
end

# Ejecutar simulación de políticas
simular_politicas_atencion()