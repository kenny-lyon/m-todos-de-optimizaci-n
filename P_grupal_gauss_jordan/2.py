import re
import numpy as np

def obtener_numeros(ecuacion):
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

def gauss_jordan(matriz, n):
    print("Matriz inicial:")
    print(matriz)

    for i in range(n):
        matriz[i] = matriz[i] / matriz[i][i]
        for j in range(n):
            if i != j:
                matriz[j] = matriz[j] - matriz[i] * matriz[j][i]

    return matriz[:, -1]  

def main():
    print("=== Resolución por el método de Gauss-Jordan ===")
    print("Ingresa una ecuación por línea. Ejemplo: 2x + 3y = 9")
    print("Cuando termines, escribe 'fin'\n")

    ecuaciones = []
    while True:
        entrada = input(f"Ecuación {len(ecuaciones)+1}: ")
        if entrada.lower() == 'fin':
            break
        ecuaciones.append(entrada)

    variables = sorted(set(re.findall(r'[a-zA-Z]', ecuaciones[0])))
    print(f"\nVariables encontradas: {variables}\n")

    A = []
    for eq in ecuaciones:
        res = obtener_numeros(eq)
        A.append(res)  
        

    A = np.array(A, dtype=float)
    soluciones = gauss_jordan(A, len(variables))

    print("\nSolución del sistema:")
    for var, sol in zip(variables, soluciones):
        print(f"{var} = {sol:.2f}")

if __name__ == "__main__":
    main()