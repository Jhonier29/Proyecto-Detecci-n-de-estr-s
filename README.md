# Proyecto-Detecci-n-de-estr-s
En este repositorio se presentan los códigos realizados en Python y Matlab para el entrenamiento de algoritmos de machine learning y el procesamiento de las señales fisiológicas. Ademas se encuentras las tablas de datos completas con las métricas de análisis e hierparametros utilizados en la creación de los modelos.  
## Bases de datos
En la carpeta llamada Base de datos se encuentran 4 carpetas denominadas "BD1", "BD2", "BD3", "BD4" donde se encuentran archivos de valores separados por comas (.csv) con las caracteristicas extraidas a las señales de la base de datos WESAD por cada uno de los individuos desde el "S2" a "S11" y "S13" a "S17".
## Tablas de resultados
En la carpeta denominada Resultados se encuentran 2 carpetas 

### Clasificación binaria 
En la carpeta de clasificacion binaria se encuentran cinco carpetas denominadas, "Tablas BD1", "Tablas BD2", "Tablas BD3", "Tablas BD4","Validación 3 sujetos".
Al interior de estas 4 primeras carpetas se encuentran tablas las cuales estan conformadas por tres secciones asi: en la sección de la izquierda se encuentran los resultados de los algortimos cuando la division para datos de entrenamiento y validacion se hace automaticamente por el algortimos de python, esta seccion va hasta la columna llamada "n_est | learning rate", luego esta la sección del centro donde se enceuntran los resultados al validar a los algoritmos con el sujeto sacado antes del entrenamiento y por ultimo se encuentra la sección de la derecha la cual esta separada de la sección central gracias a una columna en blanco donde se encuentran los resultados de los algoritmos al reducir el numero de caracteristicas, para identificar el sujeto usado, la base de datos o el numero de caracteristicas tener encuenta la siguiente denotación:

nombre de la tabla S"#"bin_C= "x"_"z"

donde: "#" corresponde al sujeto con el cual se valido y se sacaron los resultados de la columna central y derecha de caracteristicas reducidas
                 "x" corresponde al numero de caracteristicas mas relevantes con la cual se entreno los algortimos
                 "z" corresponde a la base de datos usada 
por ejemplo la tabla denominada S2_bin_C=5_BD2.xlxs hace referencia a que se uso el sujeto S2 con un minimo de caracteristicas relevantes de 5 y la base de datos 2.

Para la carpeta "Validación 3 sujetos" se encuentran tablas de datos donde estan los resultados de los algoritmos al validarlos con 3 sujetos extraidos de la base de datos, estos resultados solo estan disponibles para la "BD1" y "BD3", para identificar que sujetos fueron extraidos se debe tener encuenta la siguiente notación:
resultadosbin_"z"_"abc" donde: "z" es la base de datos usada y
                               "a","b","c" corresponden al numero de cada sujeto usado, cabe recalcar que los sujetos extraidos son consecutivos


### Clasificación de 3 clases
lo mismo que antes pero dice tres clases 
