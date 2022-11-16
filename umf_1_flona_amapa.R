library(pdftools)
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(readr)
library(sf)

## Read pdf files and convert them to text
umf_pdf <- './data/ContratoConcesso012021_umf1_flonas_amapa.pdf'
umf_txt <- pdf_text(umf_pdf)

cat(umf_txt[19]) # view a page text

## Subset pages by UMF
umf1 <- umf_txt[17:19]  # UMF 1 17-19
cat(umf1)

## Regex to extract the name of the vertices 
unlist(str_extract_all(umf1, '\\bP-\\s*?\\d{2}+'))

vertex <- c(paste0('P-0', 1:9), paste0('P-', 10:63))

## Regex to extract longitude and latitude UTM
# Check out if the regex get all the 63th vertices to east and north coordinates
summary(unlist(str_extract_all(umf1, '\\bE\\s*?(\\d{3}\\.\\d{3},\\d{2})m')))

# Did not extract east coordinate from the vertex P-42
summary(unlist(str_extract_all(umf1, '\\bN\\s*?(\\d{3}\\.\\d{3},\\d{2})m\\b'))) 


#east <- unlist(str_extract_all(umf1, '\\bE\\s?\\d{3}\\.\\d{3},\\d{2}m'))
#north <- unlist(str_extract_all(umf1, '^?\\bN\\s\\d{3}\\.\\d{3},\\d{2}m'))

## Try another way
summary(unlist(str_extract_all(umf1, '\\b\\d{3}\\.\\d{3},\\d{2}m')))
east_north <- unlist(str_extract_all(umf1, '\\b\\d{3}\\.\\d{3},\\d{2}m'))

# Convert the character vector into a dataframe and match the odd rows to north
# and even rows to east coordinates.
east_north_df <- data.frame(coord = east_north)
odd_and_even_rows <- seq_len(nrow(east_north_df)) %% 2
east <- east_north_df[odd_and_even_rows == 0, ]
north <- east_north_df[odd_and_even_rows == 1, ]

## Set the final dataframe and save as csv
df <- data.frame(vértice = vertex, east = east, north = north) %>%
        mutate(east = gsub('m', '', east)) %>%
        mutate(east = parse_number(east, locale = locale(decimal_mark = ',', 
                                                         grouping_mark = '.'))) %>%
        mutate(north = gsub('m', '', north)) %>%
        mutate(north = parse_number(north, locale = locale(decimal_mark = ',', 
                                                           grouping_mark = '.')))
        

write.csv(df, 
           './output/vertices_umf1_flona_amapa.csv', 
           row.names = FALSE, 
           fileEncoding = 'UTF-8')

## Convert the vertices to shapefile
shp_points <- st_as_sf(df, coords = c('east', 'north'), crs = '31976')
st_crs(shp_points) <- 'EPSG:31976'
st_write(shp_points, 'vertices_umf_1_flonas_amapa.shp')
