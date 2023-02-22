# Proyecto Detección de estres
En este repositorio se presentan los códigos realizados en Python y Matlab para el entrenamiento de algoritmos de machine learning y el procesamiento de las señales fisiológicas. Ademas se encuentras las tablas de datos completas con las métricas de análisis e hierparametros utilizados en la creación de los modelos.  
## Bases de datos
En la carpeta llamada Base de datos se encuentran 4 carpetas denominadas "BD1", "BD2", "BD3", "BD4" donde se encuentran archivos de valores separados por comas (.csv) con las caracteristicas extraidas a las señales de la base de datos WESAD por cada uno de los individuos desde el "S2" a "S11" y "S13" a "S17".
## Tablas de resultados
En la carpeta denominada "Resultados" se encuentran las carpetas llamadas "Clasificación binaria" y "Clasificación de 3 clases". A continuación se describe el contenido de estas.

### Contenido
En la carpeta de "Clasificación binaria" y "Clasificación de 3 clases" se encuentran 5 carpetas denominadas, "Tablas BD1", "Tablas BD2", "Tablas BD3", "Tablas BD4","Validación 3 sujetos".
Al interior de estas 4 primeras carpetas se encuentran las tablas que estan conformadas por tres secciones, de la siguiente manera: en la sección de la izquierda, se encuentran los resultados de los algoritmos cuando la division para datos de entrenamiento y validacion se hace automaticamente por la libreria usada en python, esta seccion va hasta la columna llamada "n_est | learning rate". Luego esta la sección del centro, donde se encuentran los resultados al validar a los algoritmos con el sujeto sacado antes del entrenamiento. Por ultimo, se encuentra la sección de la derecha, la cual esta separada de la sección central gracias a una columna en blanco donde se encuentran los resultados de los algoritmos al reducir el numero de caracteristicas. Para identificar el sujeto usado, la base de datos y el numero de caracteristicas, tener encuenta la siguiente notación:

Nombre de la tabla: S"#""N"_C= "x"_"z"

Donde: "#" corresponde al sujeto con el cual se valido y se obtuvo los resultados de la columna central y derecha de caracteristicas reducidas.
  
  "x" corresponde al numero de caracteristicas relevantes las cuales quedaron despues de hacer la reducción con la cual se entreno los algoritmos.
  
  "z" corresponde a la base de datos usada.
  
  "N" corresponde a el tipo de clasificación la cual puede ser "bin" de binaria o "tri" de 3 clases.
  
 Ejemplo: la tabla denominada S2_bin_C=5_BD2.xlxs, hace referencia a que se uso el sujeto S2 en la clasificación binaria, con un minimo de caracteristicas relevantes de 5 y la base de datos 2.

Para la carpeta "Validación 3 sujetos", se encuentran tablas de datos donde estan los resultados de los algoritmos al validarlos con 3 sujetos extraidos de la base de datos, para identificar que sujetos fueron extraidos se debe tener encuenta la siguiente notación:

Nombre de la tabla: resultados"N"/"z"/"abc" 

Donde: "z" es la base de datos usada.
  
  "a","b","c" corresponden al numero de cada sujeto usado, cabe recalcar que los sujetos extraidos son consecutivos.
                               
  "N" corresponde a el tipo de clasificación.

