package test.steps

import com.jayway.jsonpath.JsonPath
import io.cucumber.datatable.DataTable
import io.cucumber.java.en.And
import io.cucumber.java.en.Given
import io.cucumber.java.en.Then
import io.cucumber.java.en.When
import org.assertj.core.api.Assertions.assertThat
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.util.LinkedMultiValueMap
import org.springframework.web.client.RestTemplate
import test.common.ContextVariables
import test.common.ContextVariables.getString
import test.common.HttpMethodNotFoundException

class HttpSteps {
    private val restTemplate = RestTemplate()
    private lateinit var headers: HttpHeaders
    private lateinit var responseBody: String
    private lateinit var bodyRequest: String
    private lateinit var urlPath: String
    private lateinit var formDataBodyRequest: LinkedMultiValueMap<String, Any>
    private lateinit var httpMethod: HttpMethod
    private lateinit var httpStatusCode: String

    @Given("a http request with body:")
    fun setBodyRequest(body: String) {
        bodyRequest = getString(body)
    }

    @And("url path {string}")
    fun setUrlPath(path: String) {
        urlPath = getString(path)
    }

    @And("http method {string}")
    fun setHttpMethod(method: String) {
        fun toHttpMethod(method: String): HttpMethod {
            return when (method) {
                "GET" -> HttpMethod.GET
                "POST" -> HttpMethod.POST
                "PUT" -> HttpMethod.PUT
                "DELETE" -> HttpMethod.DELETE
                else -> throw HttpMethodNotFoundException(method)
            }
        }
        httpMethod = toHttpMethod(method)
    }

    @And("a http request with form-data body:")
    fun setBodyInFormData(bodyTable: Map<String, List<String?>>) {
        formDataBodyRequest = LinkedMultiValueMap()

        bodyTable.forEach { map ->
            map.value.filterNotNull().forEach { formDataBodyRequest.add(map.key, ContextVariables[it]) }
        }
    }

    @And("header(s)")
    fun setHttpHeaders(table: DataTable) {
        headers = HttpHeaders()

        table.asMap().forEach { (key, value) -> headers.add(key, getString(value)) }
    }

    @Then("the JSONPath value {string} from response is saved into {string}")
    fun setSessionToken(jsonPath: String, name: String) {
        val value = JsonPath.read<String>(responseBody, jsonPath)

        ContextVariables[name] = value
    }

    @When("request is performed")
    fun performRequest() {
        val response = restTemplate.postForEntity(urlPath, HttpEntity(bodyRequest, headers), String::class.java)

        httpStatusCode = response.statusCodeValue.toString()
        responseBody = requireNotNull(response.body)
    }

    @When("multipart request is performed")
    fun performMultipartFileRequest() {
        val response = restTemplate.postForEntity(urlPath, HttpEntity(formDataBodyRequest, headers), String::class.java)

        httpStatusCode = response.statusCodeValue.toString()
        response.body?.let { responseBody = it }
    }

    @Then("http status code {string} is returned")
    fun assertHttpStatusCode(statusCode: String) {
        assertThat(httpStatusCode).isEqualTo(statusCode)
    }

    @Then("http status code {string} is returned with body:")
    fun assertHttpStatusCodeAndBodyResponse(statusCode: String, body: String) {
        assertThat(httpStatusCode).isEqualTo(statusCode)
        assertThat(responseBody).isEqualTo(body)
    }
}
