from flask import Flask, render_template, request, jsonify
import re
import numpy as np

app = Flask(__name__)

def obtener_numeros(ecuacion):
    try:
        izquierda, derecha = ecuacion.split("=")
        
        if izquierda[0] not in "+-":
            izquierda = "+" + izquierda  

        terminos = re.findall(r'[+-](?:\d*\.?\d*)?[a-zA-Z]', izquierda)
        coeficientes = []

        for termino in terminos:
            match = re.match(r'([+-]?\d*\.?\d*)[a-zA-Z]', termino)
            numero = match.group(1)

            if numero in ["+", "-"]:  
                numero += "1"
            coeficientes.append(float(numero))
        coeficientes.append(float(derecha))
        return coeficientes
    except Exception as e:
        raise ValueError(f"Error al procesar la ecuación: {ecuacion}. Formato correcto: '2x + 3y = 9'")

def gauss_jordan(matriz, n):
    try:
        # Copia para no modificar la original
        mat = np.copy(matriz)
        
        for i in range(n):
            # Pivoteo parcial para evitar división por cero
            max_row = np.argmax(np.abs(mat[i:, i])) + i
            mat[[i, max_row]] = mat[[max_row, i]]
            
            pivot = mat[i][i]
            if pivot == 0:
                raise ValueError("El sistema no tiene solución única")
                
            mat[i] = mat[i] / pivot
            for j in range(n):
                if i != j:
                    mat[j] = mat[j] - mat[i] * mat[j][i]
        return mat[:, -1]
    except Exception as e:
        raise ValueError(f"Error en el cálculo: {str(e)}")

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        ecuaciones = request.form.getlist('ecuacion[]')
        if not ecuaciones:
            return jsonify({'success': False, 'error': 'No se ingresaron ecuaciones'})
        
        try:
            variables = sorted(set(re.findall(r'[a-zA-Z]', ' '.join(ecuaciones))))
            
            if len(ecuaciones) != len(variables):
                raise ValueError(f"Se necesitan {len(variables)} ecuaciones para {len(variables)} variables")
            
            A = []
            for eq in ecuaciones:
                res = obtener_numeros(eq)
                A.append(res[:-1])  # Coeficientes
                
            B = [eq[-1] for eq in A]  # Términos independientes
            A = np.array(A, dtype=float)
            
            soluciones = gauss_jordan(np.column_stack((A, B)), len(variables))

            resultados = {var: f"{sol:.4f}" for var, sol in zip(variables, soluciones)}
            return jsonify({'success': True, 'resultados': resultados})
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)})

    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)