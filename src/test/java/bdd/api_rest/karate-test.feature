@karate-test
Feature: plan de pruebas

  Scenario: caso de prueba tipo GET
    Given url baseUrlRegres
    And path '/users/2'
    #* header Content-Type = 'Application/json'
    When method GET
    And match response.data.id == 2
    Then status 200

  Scenario: caso de prueba tipo post
    Given url baseUrlRegres
    And path '/users'
    When request {"name": "morpheus", "job": "leader"}
    And method POST
    Then status 201

  Scenario: caso de prueba de tipo PUT
    Given url baseUrlRegres
    And path '/users/2'
    When request
    """
    {
        "name": "morpheus",
        "job": "zion resident"
    }
    """
    And method PUT
    Then status 200

  Scenario: caso de prueba tipo DELETE
    Given url baseUrlRegres
    And path '/users/2'
    When method DELETE
    Then status 204
