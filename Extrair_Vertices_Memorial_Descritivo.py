# Carregar pacotes
from pdfminer.high_level import extract_text # Ler pdf
from babel.numbers import parse_decimal  # Formatação Numérica
import pandas as pd  # Manipular dados
import matplotlib.pyplot as plt  # Gráficos e Mapas
import contextily  # Base de dados geográficos


# Ler como texto texto apenas as páginas 26, 27 e 28 do arquivo pdf 
pdf_txt = extract_text('./ContratoConcesso012021_umf1_flonas_amapa.pdf', page_numbers=[26, 27, 28])


# Mostrar o conteúdo das páginas selecionadas
print(pdf_txt)


# Capturando Padrões
# importar o pacote "re" para usar com regex
import re

# Regex para extração dos nomes dos vértices
vert = re.findall("[A-Z]+-\s*?\d{2}", pdf_txt)
print(vert)


vert = []

for i in range(1, 10):
    vert.append('P-0'+str(i))
    
for i in range(10, 30):
    vert.append('P-'+str(i))


print(vert)
print()
print(len(vert))


# Agora resta capturar o padrão das coordenadas UTM Leste e Norte.
norte = re.findall(r'\bN\s*?(\d{3}\.\d{3},\d{2})m\b', pdf_txt)

# converter para formato numérico
norte = [parse_decimal(i, locale='pt_BR') for i in norte]
    
print(norte)
print(len(norte))


leste = re.findall(r'\bE\s*?(\d{3}\.\d{3},\d{2})m\b', pdf_txt)

leste = [parse_decimal(i, locale='pt_BR') for i in leste]

print(leste)
print(len(leste))


# Gerar um dataframe e Salvar os dados
df = pd.DataFrame({
    'vertice': vert,
    'leste': leste,
    'norte': norte
})

# Mostrar os dados
display(df.head())


df.to_csv('vertices.csv', index=False)
df.to_excel('vertices.xlsx', index=False)


# Visualizar os dados
# Configurar o tamanho do mapa
plt.rcParams['figure.figsize'] = [15, 10]

# gerar o mapa
fig, map = plt.subplots()
map.plot(df['leste'], df['norte'], '*', color='red', markersize=8)
contextily.add_basemap(map, crs='EPSG:31976')
plt.show()
