# Simulador de Filas Simples

Este simulador é capaz de realizar simulações de filas simples. Ele foi desenvolvido por Kin Max Piamolini Gusmão como tarefa do Módulo 3 da disciplina de Simulação e Métodos Analíticos do 7º semestre do curso de Bacharelado em Ciência da Computação da Escola Politécnica da Pontifícia Universidade Universidade Católica do Rio Grande do Sul, ministrada pelo Prof. Dr. Afonso Henrique Corrêa Sales no período de 2020/1.

## Pré-Requisito

Este simulador foi descrito na linguagem de programação Ruby na versão 2.5.1. Por isso, para se utilizar o simulador, é necessário primeiramente ter o ambiente de desenvolvimento Ruby instalado em sua máquina.

### Sistemas GNU/Linux de distribuição Ubuntu/Debian

Para o caso de sistemas Linux executando distribuições Ubuntu ou Debian, o Ruby pode ser instalado através do gerenciador de pacotes ```apt-get```, com o seguinte comando:

```$ sudo apt-get install ruby-full```

### Sistemas Mac OS X e macOS

Para sistemas Mac OS X ou macOS, pode ser utilizado o gerenciador de pacotes Homebrew, da seguinte forma:

```$ brew install ruby```

### Sistemas Windows

Para sistemas Windows, o Ruby pode ser facilmente instalado através de um instalador, disponível em:

https://rubyinstaller.org/

### Outros Sistemas Operacionais

Para outros sistemas operacionais não listados aqui, o método de instalação pode ser encontrado em:

https://www.ruby-lang.org/pt/documentation/installation/

## Entrada

A entrada para o simulador é realizada através de um arquivo YAML no seguinte formato:

```
{
  "randoms": 100000,
  "queues":
  [
    {
      "label": "Q1",
      "capacity": 3,
      "servers": 2,
      "min_arrival": 2.0,
      "max_arrival": 3.0,
      "min_service": 2.0,
      "max_service": 5.0
    },
    {
      "label": "Q2",
      "capacity": 3,
      "servers": 1,
      "min_service": 3.0,
      "max_service": 5.0
    }
  ],
  "first_entry":
  {
    "queue": "Q1",
    "time": 2.5
  },
  "network":
  [
    {
      "source": "Q1",
      "destination": "Q2",
      "probability": 1.0
    }
  ]
}

```

O parâmetro ```randoms``` indica a quantidade de números pseudo-aleatórios a serem gerados e utilizados na simulação.

O parâmetro ```queues``` indica as filas presentes no modelo. No caso de uma fila siomples, haverá apenas uma. No caso de uma rede, mais de uma fila.

Cada fila possui seus parâmetros: o  parâmetro ```label``` é o identificador da fila. É uma string obrigatória e deve ser única por fila, ou o simulador não funcionará corretamente. O parâmetro ```capacity``` é um inteiro e indica a capacidade máxima de clientes na fila. O parâmetro ```servers``` é um inteiro indica a quantidade de servidores na fila. Os parâmetros ```min_arrival``` e ```max_arrival``` são números de ponto flutuante e representam, respectivamente, os intervalos mínimo e máximo para chegada de clientes na fila. Os parâmetros ```min_service``` e ```max_service``` são númertos de ponto flutuante e representam, respectivamente, os intervalos mínimo e máximo para atendimento de clientes na fila. Vale ressaltar que, em caso de filas em tandem, em que a única entrada de uma fila é a saída de outra, a fila cuja a entrada é a saída da outra não precisa ter os parâmetros ```min_arrival``` e ```max_arrival```, sendo não obrigatórios nesse caso.

O parâmetro ```first_entry``` indica o instante de tempo em que ocorre a primeira entrada na fila. Nele, é necessário definir o identificador da fila em que ocorre a primeira entrada, através do parâmetro ```queue``` e o instante de tempo em que a entrada ocorre, através do parâmetro ```time```

Por fim, há o parâmetro ```network```. Esse parâmetro é utilizado para definir redes de filas, sejam essas com probabilidades de roteamento ou em tandem. No caso de filas simples, esse parâmetro deve ser passado como um array vazio, na forma ```"network": []```. Caso hajam redes de filas no modelo, é necessário informar no parâmetro ```network``` um array de conexões entre as filas. Cada conexão é definida por três parâmetros: o parâmetro ```source``` é uma string com o identificador de uma fila e indica a fila de origem na conexão. O parâmetro ```destination```  é uma string com o identificador de uma fila e indica a fila de destino na conexão. O parâmetro ```probability``` é um número de ponto flutuante e representa a probabilidade do fluxo ocorrer por aquela conexão. No momento, esta funcionalidade ainda não foi implementada. Como com filas em tandem a conexão sempre ocorre, a probabilidade é 1.

## Execução

Para executar o simulador, é primeiramente necessário se ter o caminho do arquivo JSON de configuração. Após isso, basta executar o comando abaixo dentro da pasta do projeto:

```ruby simulator.rb <caminho do arquivo JSON de configuração>```

## Saída

A saída do simulador é dada pela média de 5 execuções realizadas com os parâmetros fornecidos no arquivo JSON. A cada execução, é utilizada uma nova semente (baseada no timestamp do relógio da CPU) para a geração dos números pseudo-aleatórios.

A saída do simulador possui o seguinte formato:

```
Results:

=======================================================

Queue Q1 - G/G/2/3

State               Time                Probability         
0                   1965.9751           2.0639 %
1                   53288.1112          55.9426 %
2                   39502.5711          41.4703 %
3                   498.3313            0.5232 %

Total               95254.9887          100.0%

Average Losses: 0.0

=======================================================

Queue Q2 - G/G/1/3

State               Time                Probability         
0                   6.8904              0.0072 %
1                   477.8732            0.5017 %
2                   37423.121           39.2873 %
3                   57347.104           60.2038 %

Total               95254.9886          100.0%

Average Losses: 14273.4


Simulation Time: 7.4345 seconds

```

Podemos ver que a saída é dividida por fila do modelo. Para cada fila temos o identificador da fila e uma representação em notação de Kendall da fila (G/G/2/3, por exemplo). Abaixo, temos as informações pertinentes à simulação executada.

Na primeira coluna, temos os estados da fila, ou seja, os números possíveis de cliente na fila.

Na segunda coluna, temos o tempo passado em cada estado.

Na terceira e última coluna, temos a probabilidade (%) de cada estado ocorrer.

Abaixo, temos o total de tempo da simulação.

Abaixo do total, temos a média de clientes perdidos na fila

Finalmente, temos o tempo real de computação em que a simulação ocorreu.

## Avaliação

### Filas Simples

Os arquivos de configuração das duas filas simples criados na etapa anterior foram atualizados parta o novo formato, estando agora nos arquivos ```simples1.json``` e ```simples2.json```. As suas execuções também foram repetidas, para garantir retrocompatibilidade com modelos de filas simples. Eles foram executados com os seguintes comandos:

```
$ ruby simulator.rb simples1.json
$ ruby simulator.rb simples2.json
```

Os resultados das execuções para filas simples podem ser encontrados no arquivo ```resultados_simples.txt```

### Filas em Tandem

Também foi criado um arquivo de configuração de uma rede de filas em tandem, conforme foi pedido no enunciado da etapa atual do trabalho. Esta configuração está no arquivo ```tandem1.json```, e foi executada com o seguinte comando:

```
$ ruby simulator.rb tandem1.json
```

O resultado com a rede de filas em tandem definida pode ser encontrado no arquivo ```resultados_tandem.json```.