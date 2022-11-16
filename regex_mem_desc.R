## Ler memorial descritivo
# mem_desc <- pdftools::pdf_text(
#         'C:/Users/67147020278/Documents/02047.000056-2003-12/memorial_descritivo_propriedade.pdf'
# )
mem_desc <- readLines('./data/memorial_descritivo_propriedade.txt')

## Extrair vertices
vert <- stringr::str_extract(mem_desc, "(P-\\d{2}+)")
vert <- vert[!is.na(vert)]
vert <- vert[1:5]
vert

##---- Extrair Longitude ----##
# lon <- as.numeric(
#         stringr::str_extract(
#                 mem_desc, 
#                 "([Ll]ongitude\\s)(\\d{5})(\'{1}\\d{2})(\'{0,1}|\"{0,1})(\\w{3})"
#         )
# )

#-> lon grau
aux_1 <- grep('[L|longitude\\s](\\d{5})[\\W$]', mem_desc, value = TRUE, perl = TRUE)

aux_2 <- as.numeric(stringr::str_match(aux_1, '\\d{5}'))

lon_gr <- as.numeric(stringr::str_match(aux_2, '^\\d{2}'))

#-> lon min
long_min <- as.numeric(stringr::str_match(aux_2, '\\d{2}$'))

#-> lon sec
lon_sec <- as.numeric(stringr::str_match(aux_1, "[[L|l]ongitude\\s\\d{5,}\\W?](\\d{2})[\\\"]"))
lon_sec <- lon_sec[!is.na(lon_sec)]
lon_sec

##---- Extrair Latitude ----##
#-> lat grau
lat_gr <- as.numeric(stringr::str_extract(mem_desc, "[[L|l]atitude\\s]0(\\d{1})"))
lat_gr <- lat_gr[!is.na(lat_gr)]
lat_gr

# lat grau e min
# lat_grMin <- as.numeric(stringr::str_extract(mem_desc, "[[L|l]atitude\\s](^|0)(\\d+)"))
# lat_min <- as.numeric(stringr::str_extract(lat_grMin, "\\d{2}$"))
# lat_min <- lat_min[!is.na(lat_min)]
# lat_min

#-> lat minutos
lat_min <- as.numeric(stringr::str_match(mem_desc, "([L|l]atitude\\s)\\d{3}(\\d{2})\\W{1}\\d{2}\\W{1}[S$]"))
lat_min <- lat_min[!is.na(lat_min)]
lat_min

# lat segundos
lat_sec <- as.numeric(stringr::str_match(mem_desc, "([L|l]atitude\\s)\\d{5}(\\W{1})(\\d{2})(\\W{1})[S$]"))
lat_sec <- lat_sec[!is.na(lat_sec)]
lat_sec

## Gerar dataframe
df <- data.frame(
        Vertice = vert,
        Lon = paste0(lon_gr, '-', long_min, '-', lon_sec, 'W'),
        Lat = paste0(lat_gr, '-', lat_min, '-', lat_sec, 'S')
)

## Salvar como .csv
write.csv(df, 'D:/vert_cleaned_by_regex.csv', row.names = FALSE)
