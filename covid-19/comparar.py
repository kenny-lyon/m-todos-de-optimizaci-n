import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score

# Cargar el dataset
df = pd.read_excel("dataset_covid_regresion.xlsx")  # Asegúrate de que la ruta sea correcta

# Definir variables
X = df[['EDAD_PROM', 'PROP_MASCULINO']]
y = df['CASOS_DIARIOS']

# Dividir en entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

### 1. REGRESIÓN POLINOMIAL ###
poly = PolynomialFeatures(degree=2)
X_train_poly = poly.fit_transform(X_train)
X_test_poly = poly.transform(X_test)

model_poly = LinearRegression()
model_poly.fit(X_train_poly, y_train)
y_pred_poly = model_poly.predict(X_test_poly)

mse_poly = mean_squared_error(y_test, y_pred_poly)
r2_poly = r2_score(y_test, y_pred_poly)

### 2. RANDOM FOREST ###
model_rf = RandomForestRegressor(n_estimators=100, random_state=42)
model_rf.fit(X_train, y_train)
y_pred_rf = model_rf.predict(X_test)

mse_rf = mean_squared_error(y_test, y_pred_rf)
r2_rf = r2_score(y_test, y_pred_rf)

### MOSTRAR RESULTADOS ###
print("=== REGRESIÓN POLINOMIAL ===")
print(f"MSE: {mse_poly:.2f}")
print(f"R²: {r2_poly:.2f}")

print("\n=== RANDOM FOREST REGRESSOR ===")
print(f"MSE: {mse_rf:.2f}")
print(f"R²: {r2_rf:.2f}")

### GRÁFICA DE COMPARACIÓN ###
plt.figure(figsize=(10, 5))
plt.plot(y_test.values, label='Valores reales', marker='o')
plt.plot(y_pred_poly, label='Regresión Polinomial', marker='x')
plt.plot(y_pred_rf, label='Random Forest', marker='s')
plt.title("Comparación de Predicciones")
plt.xlabel("Índice de muestra")
plt.ylabel("Casos diarios")
plt.legend()
plt.tight_layout()
plt.savefig("comparacion_modelos.png")  # Guarda como imagen
plt.show()
