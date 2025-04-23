from flask import Flask, render_template, request, jsonify
import re
import numpy as np

app = Flask(__name__)

def obtener_coeficientes(ecuacion, variables):
    # Normalizar la ecuación
    ecuacion = ecuacion.replace(' ', '')
    
    try:
        izquierda, derecha = ecuacion.split('=')
    except:
        raise ValueError("Formato incorrecto. Debe contener '='")
    
    # Inicializar coeficientes en 0
    coef = {v: 0 for v in variables}
    coef['constante'] = float(derecha)
    
    # Extraer términos
    terminos = re.findall(r'([+-]?\d*\.?\d*)([a-zA-Z])', izquierda)
    
    for term in terminos:
        valor, var = term
        if not valor or valor == '+':
            valor = '1'
        elif valor == '-':
            valor = '-1'
        
        if var in variables:
            coef[var] += float(valor)
        else:
            raise ValueError(f"Variable '{var}' no coincide con las demás")
    
    return [coef[v] for v in variables] + [coef['constante']]

def gauss_jordan(matriz):
    try:
        n = len(matriz)
        
        for i in range(n):
            # Pivoteo parcial
            max_row = max(range(i, n), key=lambda r: abs(matriz[r][i]))
            matriz[i], matriz[max_row] = matriz[max_row], matriz[i]
            
            pivot = matriz[i][i]
            if abs(pivot) < 1e-10:
                raise ValueError("Sistema incompatible o con infinitas soluciones")
                
            # Normalizar fila
            matriz[i] = [elem / pivot for elem in matriz[i]]
            
            # Eliminación
            for j in range(n):
                if i != j:
                    factor = matriz[j][i]
                    matriz[j] = [matriz[j][k] - factor * matriz[i][k] for k in range(n+1)]
        
        soluciones = [fila[-1] for fila in matriz]
        return soluciones
    
    except Exception as e:
        raise ValueError(str(e))

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        ecuaciones = request.form.getlist('ecuacion[]')
        
        try:
            if not ecuaciones:
                raise ValueError("No se ingresaron ecuaciones")
            
            # Detectar variables
            variables = sorted(list(set(
                char for eq in ecuaciones 
                for char in re.findall(r'[a-zA-Z]', eq.split('=')[0])
            )))
            
            if len(variables) != len(ecuaciones):
                raise ValueError(f"Se necesitan {len(variables)} ecuaciones para {len(variables)} variables")
            
            # Construir matriz
            matriz = []
            for eq in ecuaciones:
                matriz.append(obtener_coeficientes(eq, variables))
            
            # Resolver
            soluciones = gauss_jordan(matriz)
            
            resultados = {var: f"{sol:.4f}" for var, sol in zip(variables, soluciones)}
            return jsonify({'success': True, 'resultados': resultados})
            
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)})
    
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
