#set page(
  paper: "a4",
  // margin: (x: 1.8cm, y: 1.5cm),
  numbering: "1",
)
#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "es",
  region: "AR",
)
#set par(
  justify: true,
)

#set heading(numbering: "I 1.a.")
#set math.equation(numbering: "(1)")
#set figure(numbering: "1")

#show ref: it => {
  let eq = math.equation
  let el = it.element
  if el == none or el.func() != eq { return it }
  link(el.location(), numbering(
    el.numbering,
    ..counter(eq).at(el.location())
  ))
}

#set document(title: [Trabajo Práctico 1: Redes de Hopfield])

#show title: set text(size: 17pt)
#show title: set align(center)
#show title: set block(below: 1.2em)

#title()

#align(center)[
    Franco Berni \
    110007 \
    #link("mailto:fberni@fi.uba.ar")
]

#let sgn = math.op("sgn")
#let erf = math.op("erf")

= Introducción

== Memorias asociativas y redes de Hopfield

Uno de los problemas más sencillos que pueden resolver las redes neuronales es el de la *memoria asociativa*. El entrenamiento consiste de guardar un conjunto de patrones en la red. Cuando se presenta uno nuevo, la red debe ser capaz de responder con el patrón guardado que más se asemeje al mostrado @hertz1991.

Una red de Hopfield es una *memoria asociativa direccionable por contenido* (_content addressable associative memory_). Este tipo de memoria es capaz de recordar todo el contenido aprendido sobre un patrón en particular, partiendo de información parcial o con errores en la entrada @hopfield1982. Por ejemplo, una red de este estilo entrenada con imágenes de rostros humanos sería capaz de recordar una cara completa a partir de otra imagen donde unos lentes de sol cubren los ojos.

Las redes de neuronales suelen utilizar *neuronas de McCullock-Pitts generalizadas*, las cuales computan su salida como una combinación lineal de sus entradas que luego es pasada por una función no lineal @mccullock1943. La expresión general de la salida es
$ x_i = g(sum_j w_(i j) x_j - mu_i). $

En el caso particular de las redes de Hopfield, la función no lineal es el signo, y el término constante $mu_i$ puede ignorarse. La salida de una neurona es entonces
$ x_i = sgn(sum_j w_(i j) x_j). $ <output>
Notar que las salidas de cada neurona valdrán $1$ o $-1$. La red contiene $N$ neuronas como estas, y todas se encuentran conectadas con las demás excepto consigo mismas ($w_(i i) = 0$ para todo $i$). En analogía con el término biológico, a las conexiones entre neuronas se las llama *sinapsis*.

== Entrenamiento y ejecución de una red de Hopfield

El objetivo del entrenamiento es que la red aprenda una cantidad $p$ de patrones denominados $xi_i^mu$. El entrenamiento se hace utilizando la *regla de Hebb generalizada*, que consiste en reforzar las sinapsis entre neuronas cuya activación está correlacionada positivamente (disparan a la vez, o se encuentran apagadas a la vez), y en debilitar las conexiones con correlaciones negativas (si una dispara, la otra no). Computacionalmente, cada peso $w_(i j)$ se establece inicialmente en cero ($w_(i j) := 0$). Se itera para cada valor $1 <= mu <= p$, y se actualizan los pesos según la siguiente expresión
$ w_(i j) := w_(i j) + eta xi_i^mu xi_j^mu. $ <hebb>
Es decir, se actualiza cada neurona "mostrándole" cada patrón una vez. El valor de la constante de aprendizaje $eta > 0$ es arbitrario, puesto que la utilización de la función signo en @output hará que solo interese que sea positivo, con lo que se puede tomar $eta = 1$ sin perder generalidad. Observar que si en un determinado patrón dos neuronas $i$ y $j$ disparan (o no disparan) a la vez, el término $xi_i^mu xi_j^mu$ será positivo, fortaleciendo la conexión entre dichas neuronas. Lo contrario ocurre si las neuronas tienen comportamientos opuestos en un patrón.

Matemáticamente, la expresión de los pesos es
$ w_(i j) = 1/N sum_(mu=1)^p xi_i^mu xi_j^mu, $ <weights>
donde por elegancia matemática se tomó $eta = N^(-1)$ en lugar de 1 para mostrar que los pesos pueden interpretarse como un promedio sobre todos los patrones de entrada.
Además, notar que @weights es simétrica entre $i$ y $j$, por lo que $w_(i j) = w_(j i)$.

Para recuperar un patrón de la memoria a partir de un patrón de entrada $zeta_i$, una forma de hacerlo es asincrónicamente. En cada iteración, se elige una neurona $i$ al azar, y se calcula su nueva salida utilizando la regla @output. Se continúa iterando hasta que ninguna de las $N$ neuronas cambia su salida $x_i$ tras aplicar dicha regla. Idealmente, la red convergerá al patrón $xi_i^mu$ que más se asemeja a la entrada $zeta_i$. Cada patrón entrenado formará un *atractor*, al menos en el caso que $p << N$ y los $xi_i^mu$ estén descorrelacionados entre sí. Los patrones de entrada que se encuentren cerca de un atractor tenderán hacia él al aplicar sucesivamente la regla de actualización.

Cabe destacar que los patrones de entrenamiento no son los únicos atractores. La red presenta *estados espurios*, a los que también puede converger la red si empieza cerca de uno. Por empezar, por la simetría en la representación, los estados inversos $-xi_i^mu$ son atractores. Además, todas las combinaciones lineales de un número impar de estados son atractores. Finalmente, si el número de estados guardados $p$ es muy grande, también aparecen _spin glass states_, que son estados espurios no formados por una combinación lineal de los $xi_i^mu$. Afortunadamente, estos últimos suelen tener regiones de atracción pequeñas @hertz1991.

La otra forma de actualización se denomina sincrónica. Esta consiste en actualizar la salida de todas las neuronas utilizando la regla @output para cada una. En este caso, puede buscarse que la red recupere el patrón en una sola iteración, es decir, una única actualización de todas las neuronas.

== Capacidad de la red <sec:capacidad>

La *capacidad de la red* es la cantidad de patrones que puede almacenar y recuperar una red sin cometer ningún error, o cometiendo una cantidad limitada de errores. Generalmente, se expresa en forma de proporción como el número de patrones $p_(max)$ almacenable, dividido por el tamaño de la red, es decir, su cantidad $N$ de neuronas.

Para simplificar el estudio, se analiza el caso en el que los patrones son puramente aleatorios, es decir, donde cada bit es $+1$ o $-1$ con igual probabilidad e independiente del resto. Además, se considera una única iteración de actualización sincrónica. Se puede demostrar @hertz1991 que para $N gt.double 1$ y $p gt.double 1$, la probabilidad $P_("error")$ de que un dado bit sea inestable (se recupere invertido) está dada por
$ P_("error") = 1/2 [1 - erf(sqrt(N/(2p)))]. $
Por ejemplo, si se desea que cada bit se recupere correctamente con un $99%$ de probabilidad ($P_("error") = 0.01$), la red será en teoría capaz de almacenar hasta $p_(max) = 0.185 N$ patrones, suponiendo $N$ grande.

= Desarrollo

== Entrenamiento de la red

El primer ejercicio consiste en entrenar una red de Hopfield a partir de imágenes binarias provistas por la cátedra. Se proveen seis imágenes de dos tamaños distintos, las cuales se muestran en la @fig:originales. La fila superior consiste de imágenes de $60 times 45$ píxeles, mientras que en la fila inferior son cuadradas de $50$ píxeles de lado.

#figure(
  placement: auto,
  image("img/originales.png", width: 100%),
  caption: [Imágenes binarias provistas por la cátedra.],
) <fig:originales>

Se programó una red de Hopfield utilizando el lenguaje _Python_, en el entorno _Colab_ de Google. La red calcula sus pesos durante una etapa de entrenamiento según la regla de Hebb mostrada en @hebb. Para recuperar un patrón a partir de una entrada, utiliza una actualización asincrónica de sus neuronas según la expresión @output.

Cada neurona se corresponde con un píxel de las imágenes. El color blanco se corresponde a una neurona apagada ($-1$), mientras que el negro se corresponde con una neurona activa ($1$).

Hasta que se especifique lo contrario, se trabaja únicamente con las imágenes de la fila superior de la @fig:originales, en una red de Hopfield de tamaño $N = 2700 = 60 times 45$.

=== Verificación del aprendizaje

Una vez entrenada la red de Hopfield con las imágenes de la paloma, el Quijote y el torero, es interesante verificar si efectivamente la red fue capaz de aprender dichos patrones. Para ello, se introducirá cada una de las tres imágenes como entrada y se ejecutará el algoritmo para recuperar un patrón de la red. El resultado esperado es, obviamente, la misma imagen de entrada sin cambios. Si esto no ocurrienra, significaría que los patrones de entrenamiento no son atractores, y la memoria no podrá ser correctamente direccionada.

La @fig:verificacion muestra los patrones que se recuperan al utilizar como entrada los patrones de entrenamiento. Se observa que el recupero es perfecto ---lo cual también se verificó programáticamente---, demostrando que los patrones fueron correctamente memorizados y son puntos fijos para la aplicación del algoritmo de @output.

#figure(
  placement: auto,
  image("img/verificacion.png", width: 100%),
  caption: [Patrones recuperados utilizando como entrada los patrones de entrenamiento.],
) <fig:verificacion>

=== Evolución de la red

La utilidad de las memorias asociativas direccionables por contenido es poder recuperar un patrón de entrenamiento a partir de información parcial o con errores. Para verificar las capacidades de la red de Hopfield entrenada anteriormente de recuperar los patrones, se realizaron diferentes modificaciones de las imágenes y se utilizaron como entradas a la red.

Como primer ejemplo, se eliminó una porción de la imagen de la paloma y se ejecutó el algoritmo de recuperación de la red. La @fig:eliminado muestra la entrada utilizada, la imagen recuperada por la red tras converger, y un paso intermedio de la recuperación que muestra la evolución. Se observa que a medida que se ejecuta la red, la información faltante del patrón reaparece, para luego converger al patrón correcto.

#figure(
  placement: auto,
  image("img/eliminado.png", width: 100%),
  caption: [Evolución de la red ante un patrón con información eliminada.],
) <fig:eliminado>

El segundo ejemplo consistió del agregado de un rectángulo negro que cubre parte de la imagen del torero. La imagen utilizada como entrada, así como la salida obtenida y un estado intermedio se muestran en la @fig:tapado. Nuevamente, la red es capaz de correctamente recordar el patrón original, "limpiando" progresivamente los píxeles agregados.

#figure(
  placement: auto,
  image("img/tapado.png", width: 100%),
  caption: [Evolución de la red ante un patrón con una parte cubierta.],
) <fig:tapado>

Como tercer ejemplo, se agregó ruido aleatorio a la imagen del Quijote. En particular, se invirtieron aleatoriamente los píxeles del patrón original con una probabilidad independiente para cada uno de $0.2$. La @fig:ruido muestra la imagen de entrada, un paso intermedio de la evolución de la red, y la salida obtenida. Vemos que se logra correctamente recuperar la imagen original.

#figure(
  placement: auto,
  image("img/ruido.png", width: 100%),
  caption: [Evolución de la red ante un patrón afectado por ruido aleatorio.],
) <fig:ruido>

Sin embargo, la red presenta limitaciones. Si una gran parte de la imagen se encuentra cubierta, la habilidad para recuperar patrones disminuye considerablemente. Se muestra un ejemplo en la @fig:muy_tapado, donde la gran parte de la figura del torero se encuentra cubierta. La imagen recuperada no es la del torero, sino una versión invertida del patrón de la paloma. Esto se debe a que este último patrón tiene muchos píxeles en negro, por lo que está muy correlacionado con la entrada, y la red evoluciona hacia este atractor en lugar del deseado.

#figure(
  placement: auto,
  image("img/muy-tapado.png", width: 100%),
  caption: [Evolución de la red ante un patrón afectado con una gran porción cubierta.],
) <fig:muy_tapado>

=== Estados espurios

Para evaluar los problemas que presentan las redes de Hopfield, ahora nos centraremos en los estados espurios. Estos consisten de estados de la red que son estables ante las actualizaciones de la red, y que se presentan principalmente en dos tipos: los inversos de los patrones deseados, y las combinaciones lineales de un número impar de patrones.

Si se introduce como patrón de entrada una imagen completamente en negro, el patrón de salida no resulta ser ninguno de los deseados. Como se observa en @fig:invertido, la salida de la red es el inverso de la imagen de la paloma. Esto es esperable, dado que la imagen inversa es prácticamente toda negra y comparte muchos píxeles con la entrada, por lo que la red evoluciona hacia ese estado que es el más cercano. También se había observado esto en la @fig:muy_tapado un resultado similar al cubrir la imagen del torero con un rectángulo negro grande.

#figure(
  placement: auto,
  image("img/invertido.png", width: 100%),
  caption: [Evolución de la red ante un patrón completamente negro.],
) <fig:invertido>

El segundo experimento realizado fue para demostrar que los estados que son combinaciones lineales de tres patrones son estables. La combinación usada como entrada fue
$ zeta_i = -xi_i^0 + xi_i^1 + xi_i^2, $
y, junto con el resultado y un paso intermedio, se muestra en la @fig:mezcla. Vemos que no hay ningún cambio en la imagen, recuperando exactamente la misma combinación lineal que fue introducida inicialmente.

#figure(
  placement: auto,
  image("img/mezcla.png", width: 100%),
  caption: [Evolución de la red ante una combinación lineal de tres patrones.],
) <fig:mezcla>

=== Incremento del número de patrones

En esta parte, se reentrenó una nueva red de Hopfield con $N = 3000$ neuronas. Se utilizaron las seis imágenes disponibles (ver la @fig:originales), las cuales fueron expandidas con espacios en blanco hasta completar un tamaño de $60 times 50$ píxeles.

Para evaluar el desempeño de esta nueva red, se introdujeron como entrada los seis patrones de entrenamiento en forma sucesiva, y se observó la salida de la red para cada uno. En la @fig:seis se muestran las imágenes originales utilizadas para entrenar y como entrada, así como la salida de la red para cada una de ellas. Observamos que, salvo para la última imagen, ninguno de los patrones recuperados coincide con los $xi_i^mu$. Esto significa que la red fue incapaz de aprender, y los patrones de entrenamiento no son atractores (con la excepción de `v.bmp`). Sin embargo, notar que los patrones obtenidos sí se asemejan a los esperados, con errores en solo algunos de los píxeles. Es decir, no se trata de patrones completamente diferentes, como sí se observó en la @fig:muy_tapado.

La incapacidad de la red para aprender estos patrones se debe principalmente a que hay una alta correlación entre ellas, y hay un número mayor de patrones a aprender. Teóricamente, si las imágenes estuvieran descorrelacionadas entre sí, la capacidad de la red sería mucho más grande que la cantidad de patrones $p = 6$ que estamos intentando almacenar. Al no cumplirse esto, la capacidad real se ve severamente afectada. En el caso de la última imagen, el recupero es correcto dado que se encuentra lo suficientemente "lejos" de los demás estados, por lo que la red tiene mayor facilidad en aprenderlo sin confundirlo con los demás.

#figure(
  placement: auto,
  image("img/seis.png", width: 100%),
  caption: [Patrones recuperados utilizando como entrada los patrones de entrenamiento.],
) <fig:seis>

== Capacidad de la red

En esta sección se analiza la capacidad de almancenamiento de las redes de Hopfield, utilizando únicamente patrones generados aleatoriamente. Los experimentos se realizaron con actualizaciones sincrónicas de todas las neuronas. Se hizo una única iteración sincrónica, para comparar con los resultados teóricos esperados que se mencionaron en la @sec:capacidad.

=== Almacenamiento de patrones pseudoaleatorios

Como primer análisis de la capacidad de una red de Hopfield, se estudió su comportamiento para patrones pseudoaleatorios independientes. El procedimiento fue el siguiente. Se entrena a la red con un patrón pseudoaleatorio, y se verifica que la misma sea capaz de memorizarlo. De ser así, se le enseña a la red un segundo patrón, y se verifican que _ambos_ patrones hayan sido aprendidos. Esto se repite, agergando cada vez más patrones, hasta que se llegue a un límite $p_(max)$ donde la red comience a cometer demasiados errores. Se considera que la red ha aprendido los patrones mostrados si la proporción de bits erróneos entre el total de $N p$ bits es menor a un umbral $P_("error")$.

Análisis teóricos para $N gt.double 1$ y $p gt.double 1$ permiten obtener una expresión para la capacidad, definida como la relación $frac(p_(max), N, style: "horizontal")$ en función del valor de $P_("error")$. En la segunda columna de la @tab:capacidades se muestran algunas capacidades según el umbral de error elegido.

#figure(
  placement:auto,
  table(
    align: left,
    columns: 3,
    stroke: none,
    table.hline(),
    table.header([$P_("error")$], [$frac(p_(max), N, style: "horizontal")$ @hertz1991], [$frac(hat(p)_(max), N, style: "horizontal")$]),
    table.hline(),
    [0.001 ], [0.105], [0.100(15)],
    [0.0036], [0.138], [0.138(11)],
    [0.01  ], [0.185], [0.183(8)],
    [0.05  ], [0.37],  [0.368(8)],
    [0.1   ], [0.61],  [0.610(9)],
    table.hline(),
  ),
  caption: [Capacidad teórica y estimada de la red para patrones aleatorios.],
) <tab:capacidades>

Las capacidades $frac(hat(p)_(max), N, style: "horizontal")$ obtenidas experimentalmente, utilizando $N = 200$ y promediando 10 repeticiones diferentes, se muestran en la tercera columna de la @tab:capacidades. También se muestra el desvío estándar de las simulaciones. Se observa que las capacidades estimadas son muy cercanas a las teóricas, coincidiendo dentro de los márgenes de error obtenidos. Vemos que si se desean recuperar patrones aleatorios con una tasa de error en los bits menor al diez porciento, solo se podrán almacenar una cantidad de patrones $p$ más de cinco veces más chica que el número de neuronas utilizadas. Cabe destacar que si los patrones no son perfectamente aleatorios, cosa que suele suceder en la realidad, la capacidad se verá reducida respecto de estos límites teóricos.

=== Almacenamiento de patrones correlacionados

Para estudiar qué ocurre si los patrones a almacenar no son completamente azarosos, se propone el siguiente método para la generación de patrones correlacionados. Se genera en primer lugar un patrón padre $X_i$ pseudoaleatoriamente. Luego, se genera una secuencia $Y^k_i$ de patrones hijos, donde cada bit es igual al correspondiente bit de $X_i$ con probabilidad $p$, o se invierte con probabilidad $1-p$. Los patrones a enseñar, y con los cuales se evaluará la capacidad de la red, son los de la secuencia de hijos.

Una forma equivalente de definir a los $Y^k_i$ es de la siguiente manera:
$ Y^k_i = Z^k_i X_i, $
donde
$ Z^k_i = cases(
  +1 "con probabilidad" q,
  -1 "con probabilidad" 1-q,
). $
Entonces, como los valores medios de las $Y^k_i$ son nulos y sus desvíos estándar son unitarios, la correlación entre dos patrones $Y^(k_1)_i$ e $Y^(k_2)_i$ estará dada por
$ rho = EE[Y^(k_1)_i Y^(k_2)_i] = EE[Z^(k_1)_i Z^(k_2)_i (X_i)^2]
= EE[Z^(k_1)_i Z^(k_2)_i] = EE[Z^(k_1)_i] EE[Z^(k_2)_i] = (2q - 1)^2. $
Por lo tanto, puede despejarse fácilmente la probabilidad $q$ necesaria para la generación de los patrones hijos en función de la correlación deseada como
$ q = (sqrt(rho) + 1) / 2. $

En la @fig:correlacionadas se muestra la capacidad de la red estimada para los mismos umbrales de error $P_("error")$ que en la parte anterior, pero variando la correlación entre patrones entre $0.1$ y $0.7$. Se agrega como comparación el valor teórico para el caso descorrelacionado. Notar que se utilizaron diferentes cantidades de neuronas $N$ para cada correlación, con el objetivo de minimizar el tiempo de cómputo, pero obteniendo errores bajos.

Vemos que a medida que la correlación crece, la capacidad de la red se ve sevramente afectada. Por ejemplo, para una correlación entre patrones de $0.7$, la capacidad de la red si se toleran errores en $10 %$ de los bits, es unas diez veces menor que para una tasa estricta de $P_("error") = 0.001$ con una correlación baja ($rho = 0.1$). También se destaca que el decrecimiento de la capacidad es prácticamente exponencial (notar la escala logarítmica) a medida que crece la correlación.

#figure(
  placement: auto,
  image("img/correlacionadas.png", width: 100%),
  caption: [Capacidad estimada de la red en función de la correlación $rho$ entre patrones.],
) <fig:correlacionadas>

Lo que se deduce de este análisis es que si los patrones son lo suficientemente "parecidos" entre sí, la red es incapaz de aprender cada patrón por separado y los confunde. Una interpretación es que los mínimos de la función energía pasan a estar tan cerca, que los patrones dejan de ser atractores. Además, algunas de las suposiciones que se realizan para simplificar el estudio de la capacidad se ven violadas cuando hay alta correlación, lo que invalida los resultados.

== Eliminación aleatoria de interconexiones

=== Efectos sobre el error de recupero



#figure(
  placement:auto,
  table(
    align: left,
    columns: 2,
    stroke: none,
    table.hline(),
    table.header([$p_("desc")$], [$P_("error")$]),
    table.hline(),
      [0.010], [0.010(73)],
      [0.100], [0.060(164)],
      [0.300], [0.140(225)],
      [0.750], [0.359(225)],
      [0.900], [0.458(142)],
    table.hline(),
  ),
  caption: [Error de recupero para diferentes probabilidades de desconexión entre neuronas.],
) <tab:desconexiones-err>

=== Efectos sobre la capacidad de la red

#figure(
  placement:auto,
  table(
    align: left,
    columns: 2,
    stroke: none,
    table.hline(),
    table.header([$p_("desc")$], [$frac(hat(p)_(max), N, style: "horizontal")$]),
    table.hline(),
      [0.010], [0.187(07)],
      [0.100], [0.165(58)],
      [0.300], [0.128(86)],
      [0.750], [0.044(79)],
      [0.900], [0.013(47)],
    table.hline(),
  ),
  caption: [Capacidad de la red para diferentes probabilidades de desconexión entre neuronas.],
) <tab:desconexiones-cap>

#bibliography("refs.bib")
