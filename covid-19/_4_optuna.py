import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import optuna

from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import mean_squared_error, r2_score

# === 1. CARGAR DATOS ===
df = pd.read_excel("dataset_covid_regresion.xlsx")

# === 2. PREPARAR DATOS ===
df_encoded = df.copy()
le_distrito = LabelEncoder()
le_dia = LabelEncoder()
df_encoded["DISTRITO"] = le_distrito.fit_transform(df_encoded["DISTRITO"])
df_encoded["DIA_SEMANA"] = le_dia.fit_transform(df_encoded["DIA_SEMANA"])

X = df_encoded.drop(columns=["CASOS_DIARIOS", "FECHA_RESULTADO"])
y = df_encoded["CASOS_DIARIOS"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# === 3. DEFINIR FUNCIÓN OBJETIVO PARA OPTUNA ===
def objetivo(trial):
    params = {
        "n_estimators": trial.suggest_int("n_estimators", 50, 300),
        "max_depth": trial.suggest_int("max_depth", 3, 20),
        "min_samples_split": trial.suggest_int("min_samples_split", 2, 10),
        "min_samples_leaf": trial.suggest_int("min_samples_leaf", 1, 10),
        "max_features": trial.suggest_categorical("max_features", ["sqrt", "log2", None])
    }
    modelo_opt = RandomForestRegressor(**params, random_state=42)
    modelo_opt.fit(X_train, y_train)
    y_pred = modelo_opt.predict(X_test)
    return mean_squared_error(y_test, y_pred)

# === 4. OPTIMIZAR ===
estudio = optuna.create_study(direction="minimize")
estudio.optimize(objetivo, n_trials=30)

# === 5. ENTRENAR MODELO FINAL ===
print("\n🔍 Mejores parámetros encontrados:")
print(estudio.best_params)

modelo_final = RandomForestRegressor(**estudio.best_params, random_state=42)
modelo_final.fit(X_train, y_train)
y_pred_final = modelo_final.predict(X_test)

# === 6. EVALUACIÓN FINAL ===
mse_final = mean_squared_error(y_test, y_pred_final)
r2_final = r2_score(y_test, y_pred_final)

print(f"\n✅ Error cuadrático medio optimizado (MSE): {mse_final:.2f}")
print(f"✅ R² optimizado: {r2_final:.2f}")

# === 7. GRÁFICO REAL VS PREDICHO ===
plt.figure(figsize=(10, 6))
sns.scatterplot(x=y_test, y=y_pred_final, alpha=0.6, color='green')
plt.plot([y.min(), y.max()], [y.min(), y.max()], 'r--')
plt.title("Valores reales vs predichos (Random Forest + Optuna)")
plt.xlabel("Casos reales")
plt.ylabel("Casos predichos")
plt.grid(True)
plt.tight_layout()
plt.show()
