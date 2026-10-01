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
    And path 'collections','products','records'
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
    And path 'collections','products','records',productId
    When method GET
    Then status 200
    And match response == productsSchema
    And match response.data.id == productId
    And match response.data.data.name == productsRequest.productPost[product].data.name
    And match response.data.data.price == productsRequest.productPost[product].data.price
    And match response.data.data.Category == productsRequest.productPost[product].data.Category
    And match response.data.data.in_stock == productsRequest.productPost[product].data.in_stock
    Examples:
      | product           |
      | NintendoSwitch2   |
      | PlayStation5Pro   |


