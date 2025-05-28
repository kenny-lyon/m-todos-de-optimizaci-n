import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Cargar el dataset
df = pd.read_excel("dataset_covid_regresion.xlsx")

# Vista previa del dataset
print(df.head())

# Ver distribución de la variable objetivo
plt.figure(figsize=(10, 5))
sns.histplot(df["CASOS_DIARIOS"], kde=True, color='skyblue')
plt.title("Distribución de casos diarios por distrito")
plt.xlabel("Casos diarios")
plt.ylabel("Frecuencia")
plt.grid(True)
plt.tight_layout()
plt.show()

# Ver relación entre edad promedio y casos
plt.figure(figsize=(10, 6))
sns.scatterplot(x="EDAD_PROM", y="CASOS_DIARIOS", data=df)
plt.title("Relación entre edad promedio y número de casos diarios")
plt.xlabel("Edad promedio")
plt.ylabel("Casos diarios")
plt.grid(True)
plt.tight_layout()
plt.show()
