# Reto 2

## El fallo

Para el ejercicio de `src/test/java/bdd/api_reqres/workflow.feature` quise añadir `Examples` al flujo para poder ejecutar el escenario con diferentes productos.

Primero generé el siguiente código en el `.feature`:

```gherkin
@workflow-test
Feature: Reto 2 - Flujo Comprobable

Background:
    Given url baseUrlReqres
    And header x-api-key = reqres_api_key
    And header X-Reqres-Env = 'prod'
    And header Content-Type = 'application/json'
    * def productsRequest = read('classpath:requests/request-products.json')
    * def productsSchema = read('classpath:responses/response-products-schema.json')

@post-product
Scenario Outline: Crear producto, validar schema y datos
    And path 'collections', 'products', 'records'
    And request productsRequest.productPost.<product>
    When method POST
    Then status 201
    And match response == productsSchema
    And match response.data.data.name == productsRequest.productPost.<product>.data.name
    And match response.data.data.price == productsRequest.productPost.<product>.data.price
    And match response.data.data.Category == productsRequest.productPost.<product>.data.Category
    And match response.data.data.in_stock == productsRequest.productPost.<product>.data.in_stock
    * def productId = response.data.id

Examples:
    | product         |
    | NintendoSwitch2 |
    | PlayStation5Pro |


@get-product
Scenario Outline: Consultar producto, validar schema y datos
    * call read('classpath:bdd/api_reqres/workflow.feature@post-product')
    And path 'collections', 'products', 'records', productId
    When method GET
    Then status 200
    And match response == productsSchema
    And match response.data.id == productId
    And match response.data.data.name == productsRequest.productPost.<product>.data.name
    And match response.data.data.price == productsRequest.productPost.<product>.data.price
    And match response.data.data.Category == productsRequest.productPost.<product>.data.Category
    And match response.data.data.in_stock == productsRequest.productPost.<product>.data.in_stock

Examples:
    | product         |
    | NintendoSwitch2 |
    | PlayStation5Pro |
```

El problema era que el escenario `@get-product` ejecutaba dos veces el escenario `@post-product`, una vez por cada `Example`.

Por lo tanto, `productId` se sobrescribía en cada ejecución del `POST`.

Al finalizar ambas ejecuciones del `POST`, la variable `productId` terminaba conteniendo únicamente el ID correspondiente al último `Example`, en este caso `PlayStation5Pro`.

### Durante la ejecución

#### Ejecución 1 del GET — ❌ NO OK

- El `GET` esperaba: `Nintendo Switch 2`
- El `GET` realmente consultaba: `PlayStation 5 Pro` (Esto ocurría porque `productId` había quedado con el último valor generado por el `POST`.)

En el log tenía:

```text
14:48:28.403 classpath:bdd/api_reqres/workflow.feature:38

And match response.data.data.name == productsRequest.productPost.NintendoSwitch2.data.name

match failed: EQUALS
$ | not equal (STRING:STRING)

'PlayStation 5 Pro'
'Nintendo Switch 2'

classpath:bdd/api_reqres/workflow.feature:38
```

#### Ejecución 2 del GET — ✅ OK

En la segunda ejecución, el `GET` correspondía a `PlayStation5Pro`.

Como `productId` también contenía el ID de `PlayStation5Pro`, la consulta y las validaciones coincidían correctamente.

---

# La solución

Para solucionar el problema, dejé el escenario `@post-product` sin `Examples`, ya que la ejecución del `POST` debe recibir el producto específico que corresponde a cada ejecución del `GET`.

Además, agregué el tag `@ignore`, porque ahora el escenario `@post-product` es totalmente dependiente de la llamada por el `@get-product`.

Mi solución quedó así:

```gherkin
@workflow-test
Feature: Reto 2 - Flujo Comprobable

Background:
    Given url baseUrlReqres
    And header x-api-key = reqres_api_key
    And header X-Reqres-Env = 'prod'
    And header Content-Type = 'application/json'
    * def productsRequest = read('classpath:requests/request-products.json')
    * def productsSchema = read('classpath:responses/response-products-schema.json')

@post-product @ignore
Scenario: Crear producto, validar schema y datos
    And path 'collections', 'products', 'records'
    And request productsRequest.productPost[product]
    When method POST
    Then status 201
    And match response == productsSchema
    And match response.data.data.name == productsRequest.productPost[product].data.name
    And match response.data.data.price == productsRequest.productPost[product].data.price
    And match response.data.data.Category == productsRequest.productPost[product].data.Category
    And match response.data.data.in_stock == productsRequest.productPost[product].data.in_stock
    * def productId = response.data.id


@get-product
Scenario Outline: Crear Producto, consultarlo, validar schema y datos
    * call read('classpath:bdd/api_reqres/workflow.feature@post-product') { product: <product> }
    And path 'collections', 'products', 'records', productId
    When method GET
    Then status 200
    And match response == productsSchema
    And match response.data.id == productId
    And match response.data.data.name == productsRequest.productPost[product].data.name
    And match response.data.data.price == productsRequest.productPost[product].data.price
    And match response.data.data.Category == productsRequest.productPost[product].data.Category
    And match response.data.data.in_stock == productsRequest.productPost[product].data.in_stock

Examples:
    | product         |
    | NintendoSwitch2 |
    | PlayStation5Pro |
```

### Durante la ejecución

#### Ejecución 1 del GET — ✅ OK

- El `GET` esperaba: `Nintendo Switch 2`
- El `GET` realmente consulta: `Nintendo Switch 2` (Se soluciona siendo coherente con el valor del producto que se envía al `POST` y el que se espera validar con el `GET`)

#### Ejecución 2 del GET — ✅ OK

- El `GET` esperaba: `PlayStation 5 Pro`
- El `GET` realmente consulta: `PlayStation 5 Pro` (Se soluciona siendo coherente con el valor del producto que se envía al `POST` y el que se espera validar con el `GET`)