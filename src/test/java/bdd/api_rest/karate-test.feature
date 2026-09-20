@karate-test
Feature: plan de pruebas

  Background:
    Given url baseUrlReqres
    * def userId = 2
    * def requests = read('classpath:requests/request-regres.json')

  Scenario: obtener usuario
    And path 'users', userId
    #* header Content-Type = 'Application/json'
    When method GET
    And match response.data.id == userId
    Then status 200

  Scenario: Crear usuario
    And path 'users'
    And request requests.userPost
    When method POST
    Then status 201

  Scenario: Actualizar usuario
    And path 'users', userId
    And request requests.userPut
    When method PUT
    Then status 200

  Scenario: Eliminar usuario
    And path 'users', userId
    When method DELETE
    Then status 204
