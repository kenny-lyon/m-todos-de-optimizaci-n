import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.ensemble import RandomForestRegressor

# Cargar el archivo Excel antes de todo
df = pd.read_excel("dataset_covid_regresion.xlsx")
# Codificar variables categóricas
df_encoded = df.copy()
le_distrito = LabelEncoder()
le_dia = LabelEncoder()

df_encoded["DISTRITO"] = le_distrito.fit_transform(df_encoded["DISTRITO"])
df_encoded["DIA_SEMANA"] = le_dia.fit_transform(df_encoded["DIA_SEMANA"])

# Separar variables
X = df_encoded.drop(columns=["CASOS_DIARIOS", "FECHA_RESULTADO"])
y = df_encoded["CASOS_DIARIOS"]

# Dividir en entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Entrenar modelo XGBoost
modelo = RandomForestRegressor(random_state=42)  # ✅ esta es 
modelo.fit(X_train, y_train)

# Predicción y evaluación
y_pred = modelo.predict(X_test)

# Evaluación
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)
print(f"Error cuadrático medio (MSE): {mse:.2f}")
print(f"Coeficiente de determinación (R²): {r2:.2f}")

# Gráfico real vs predicho
plt.figure(figsize=(10, 6))
sns.scatterplot(x=y_test, y=y_pred, alpha=0.6)
plt.plot([y.min(), y.max()], [y.min(), y.max()], 'r--')  # línea ideal
plt.title("Valores reales vs predichos (XGBoost)")
plt.xlabel("Casos reales")
plt.ylabel("Casos predichos")
plt.grid(True)
plt.tight_layout()
plt.show()
