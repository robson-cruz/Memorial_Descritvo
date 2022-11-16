library(pdftools)
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(readr)
library(sf)

## Read pdf files and convert them to text
umf_pdf <- './data/ContratoConcesso012021_umf1_flonas_amapa.pdf'
umf_txt <- pdf_text(umf_pdf)

cat(umf_txt[28]) # view a page text

## Subset pages by UMF
umf4 <- umf_txt[27:28]  # UMF 4 27-28
cat(umf4)

## Regex to extract the name of the vertices 
unlist(str_extract_all(umf4, '\\bP-\\d{2}+'))

vertex <- c(paste0('P-0', 1:9), paste0('P-', 10:29))

## Regex to extract longitude and latitude UTM
# Check out if the regex get all the 63th vertices to east and north coordinates
summary(unlist(str_extract_all(umf4, '\\bE\\s\\d{3}\\.\\d{3},\\d{2}m')))

# Did not extract east coordinate from the vertex P-42
summary(unlist(str_extract_all(umf4, '\\bN\\s\\d{3}\\.\\d{3},\\d{2}m'))) 

east <- unlist(str_extract_all(umf4, '\\bE\\s\\d{3}\\.\\d{3},\\d{2}m'))
north <- unlist(str_extract_all(umf4, '\\bN\\s\\d{3}\\.\\d{3},\\d{2}m'))


## Set a dataframe and save as csv
df <- data.frame(vértice = vertex, east = east, north = north) %>%
        mutate(east = gsub('m', '', east)) %>%
        mutate(east = parse_number(east, locale = locale(decimal_mark = ',', 
                                                         grouping_mark = '.'))) %>%
        mutate(north = gsub('m', '', north)) %>%
        mutate(north = parse_number(north, locale = locale(decimal_mark = ',', 
                                                           grouping_mark = '.')))


write.csv(df, 
          './output/vertices_umf4_flona_amapa.csv', 
          row.names = FALSE, 
          fileEncoding = 'UTF-8')

## Convert the dataframe to sf object and as shapefile
shp_points <- st_as_sf(df, coords = c('east', 'north'), crs = '31976')
st_crs(shp_points) <- 'EPSG:31976'
st_write(shp_points, './output/vertices_umf_4_flonas_amapa.shp')
